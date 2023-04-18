@isTest
private class SimpleJITHandlerTest {
  private static final String CUSTOMER_PROFILE_NAME = 'Customer Community Plus Login User';
  private static final String ROLE_PARTNER = 'Partner Manager';

  @TestSetup
  static void makeData() {
    Account partnerAccount = JITTestUtil.createAccount(
      JITTestUtil.ACCOUNT_NAME
    );
    partnerAccount.AccountNumber = JITTestUtil.ACCOUNT_NUMBER;
    insert partnerAccount;

    Contact partnerContact = JITTestUtil.createContact(JITTestUtil.LAST_NAME);
    partnerContact.AccountId = partnerAccount.Id;
    insert partnerContact;
  }

  static testMethod void createUser_givenAccountAndContact_shouldGetNewUser() {
    Id samlSsoProviderId = '00100000000000a';
    Id communityId = '09a00000000000c';
    Id portalId = null;

    Account partnerAccount = JITTestUtil.queryOneAccount();
    Contact partnerContact = JITTestUtil.queryOneContact();

    Profile admin = JITTestUtil.queryOneProfileByName(
      JITTestUtil.PROFILE_ADMIN
    );
    User samlUser = JITTestUtil.createUser(JITTestUtil.LAST_NAME, admin.Id);
    Map<String, String> attributes = JITTestUtil.getAttributes(
      partnerAccount,
      partnerContact,
      samlUser
    );
    attributes.put('User.Account', partnerAccount.Id);
    attributes.put('User.Contact', partnerContact.Id);
    attributes.put('User.ProfileId', admin.Name);

    SimpleJITHandler handler = new SimpleJITHandler();
    Test.startTest();

    User newUser = handler.createUser(
      samlSsoProviderId,
      communityId,
      portalId,
      JITTestUtil.FEDERATION_IDENTIFIER,
      attributes,
      JITTestUtil.SAML_ASSERTION
    );

    Test.stopTest();

    Account existingAccount = JITTestUtil.queryOneAccountByName(
      partnerAccount.Name
    );
    Contact existingContact = JITTestUtil.queryOneContactByUser(
      newUser.ContactId
    );

    System.assertEquals(samlUser.Email, newUser.Email);
    System.assertNotEquals(null, existingAccount.Id);
    System.assertNotEquals(null, existingContact.Id);
    System.assertEquals(newUser.ContactId, existingContact.Id);
    System.assertEquals(existingContact.AccountId, existingAccount.Id);
  }

  static testMethod void createUser_givenAccount_shouldGetNewUserAndContact() {
    Id samlSsoProviderId = '00100000000000a';
    Id communityId = '09a00000000000c';
    Id portalId = null;

    String lastName = JITTestUtil.LAST_NAME + '2';
    Account partnerAccount = JITTestUtil.queryOneAccount();
    Contact newPartnerContact = JITTestUtil.createContact(lastName);
    newPartnerContact.AccountId = partnerAccount.Id;

    Profile admin = JITTestUtil.queryOneProfileByName(
      JITTestUtil.PROFILE_ADMIN
    );
    User samlUser = JITTestUtil.createUser(lastName, admin.Id);
    Map<String, String> attributes = JITTestUtil.getAttributes(
      partnerAccount,
      newPartnerContact,
      samlUser
    );
    attributes.put('User.Account', partnerAccount.Id);
    attributes.put('User.ProfileId', admin.Name);

    SimpleJITHandler handler = new SimpleJITHandler();
    Test.startTest();

    User newUser = handler.createUser(
      samlSsoProviderId,
      communityId,
      portalId,
      JITTestUtil.FEDERATION_IDENTIFIER,
      attributes,
      JITTestUtil.SAML_ASSERTION
    );

    Test.stopTest();

    Account existingAccount = JITTestUtil.queryOneAccountByName(
      partnerAccount.Name
    );
    Contact newContact = JITTestUtil.queryOneContactByUser(newUser.ContactId);

    System.assertEquals(samlUser.Email, newUser.Email);
    System.assertNotEquals(null, existingAccount.Id);
    System.assertNotEquals(null, newContact.Id);
    System.assertEquals(newUser.ContactId, newContact.Id);
    System.assertEquals(newContact.AccountId, existingAccount.Id);
  }

  static testMethod void createUser_givenBrandNewExternal_shouldGetNewAccountContactAndUser() {
    Id samlSsoProviderId = '00100000000000a';
    Id communityId = '09a00000000000c';
    Id portalId = null;

    String accountName = JITTestUtil.ACCOUNT_NAME + '2';
    String lastName = JITTestUtil.LAST_NAME + '2';
    Account newPartnerAccount = JITTestUtil.createAccount(accountName);
    Contact newPartnerContact = JITTestUtil.createContact(lastName);
    newPartnerContact.AccountId = newPartnerAccount.Id;

    Profile admin = JITTestUtil.queryOneProfileByName(
      JITTestUtil.PROFILE_ADMIN
    );
    User samlUser = JITTestUtil.createUser(lastName, admin.Id);
    Map<String, String> attributes = JITTestUtil.getAttributes(
      newPartnerAccount,
      newPartnerContact,
      samlUser
    );
    attributes.put('User.ProfileId', admin.Name);

    SimpleJITHandler handler = new SimpleJITHandler();
    Test.startTest();

    User newUser = handler.createUser(
      samlSsoProviderId,
      communityId,
      portalId,
      JITTestUtil.FEDERATION_IDENTIFIER,
      attributes,
      JITTestUtil.SAML_ASSERTION
    );

    Test.stopTest();

    Account existingAccount = JITTestUtil.queryOneAccountByName(
      newPartnerAccount.Name
    );
    Contact newContact = JITTestUtil.queryOneContactByUser(newUser.ContactId);

    System.assertEquals(samlUser.Email, newUser.Email);
    System.assertNotEquals(null, existingAccount.Id);
    System.assertNotEquals(null, newContact.Id);
    System.assertEquals(newUser.ContactId, newContact.Id);
    System.assertEquals(newContact.AccountId, existingAccount.Id);
  }

  static testMethod void updateUser_givenExistingExternal_shouldGetUpdatedAccountContactAndUser() {
    Id samlSsoProviderId = '00100000000000a';
    Id communityId = '09a00000000000c';
    Id portalId = null;

    Account existingAccount = JITTestUtil.queryOneAccount();
    Contact existingContact = JITTestUtil.queryOneContact();

    Profile partnerProfile = JITTestUtil.queryOneProfileByName(
      CUSTOMER_PROFILE_NAME
    );
    UserRole partnerRole = JITTestUtil.queryOneRoleByName(ROLE_PARTNER);
    User existingUser = JITTestUtil.createUser('sanchez', partnerProfile.Id);
    existingUser.ContactId = existingContact.Id;
    //existingUser.UserRoleId = partnerRole.Id;
    insert existingUser;

    Map<String, String> attributes = JITTestUtil.getAttributes(
      existingAccount,
      existingContact,
      existingUser
    );
    attributes.put('User.Account', existingAccount.Id);
    attributes.put('User.Contact', existingContact.Id);
    attributes.put('User.ProfileId', partnerProfile.Name);

    String newFirstName = 'Rick';
    String newAccountNumber = 'ACC456';
    attributes.put('User.FirstName', newFirstName);
    attributes.put('Contact.FirstName', newFirstName);
    attributes.put('Account.AccountNumber', newAccountNumber);

    SimpleJITHandler handler = new SimpleJITHandler();
    Test.startTest();

    handler.updateUser(
      existingUser.Id,
      samlSsoProviderId,
      communityId,
      portalId,
      JITTestUtil.FEDERATION_IDENTIFIER,
      attributes,
      JITTestUtil.SAML_ASSERTION
    );

    Test.stopTest();

    User updatedUser = JITTestUtil.queryOneUserById(existingUser.Id);
    Contact updatedContact = JITTestUtil.queryOneContactByUser(
      existingUser.ContactId
    );
    Account updatedAccount = JITTestUtil.queryOneAccountById(
      updatedContact.AccountId
    );

    System.assertEquals(existingUser.email, updatedUser.Email);
    System.assertNotEquals(existingUser.FirstName, updatedUser.FirstName);

    System.assertNotEquals(existingUser.FirstName, updatedUser.FirstName);
    System.assertNotEquals(existingContact.FirstName, updatedContact.FirstName);
    System.assertNotEquals(
      existingAccount.AccountNumber,
      updatedAccount.AccountNumber
    );

    System.assertEquals(newFirstName, updatedUser.FirstName);
    System.assertEquals(newFirstName, updatedContact.FirstName);
    System.assertEquals(newAccountNumber, updatedAccount.AccountNumber);
  }

  static testMethod void createUser_givenNewInternal_shouldGetNewUser() {
    Id samlSsoProviderId = '00100000000000a';
    Id communityId = null;
    Id portalId = null;

    Profile admin = JITTestUtil.queryOneProfileByName(
      JITTestUtil.PROFILE_ADMIN
    );
    User samlUser = JITTestUtil.createUser(JITTestUtil.LAST_NAME, admin.Id);
    Map<String, String> attributes = JITTestUtil.getAttributes(
      new Account(),
      new Contact(),
      samlUser
    );
    attributes.put('User.ProfileId', admin.Name);

    SimpleJITHandler handler = new SimpleJITHandler();
    Test.startTest();

    User newUser = handler.createUser(
      samlSsoProviderId,
      communityId,
      portalId,
      JITTestUtil.FEDERATION_IDENTIFIER,
      attributes,
      JITTestUtil.SAML_ASSERTION
    );

    Test.stopTest();

    System.assertEquals(samlUser.Email, newUser.Email);
    System.assertEquals(null, newUser.ContactId);
  }

  static testMethod void updateUser_givenExistingInternal_shouldGetUpdatedUser() {
    Id samlSsoProviderId = '00100000000000a';
    Id communityId = null;
    Id portalId = null;

    Profile admin = JITTestUtil.queryOneProfileByName(
      JITTestUtil.PROFILE_ADMIN
    );
    User existingUser = JITTestUtil.createUser(JITTestUtil.LAST_NAME, admin.Id);
    insert existingUser;
    Map<String, String> attributes = JITTestUtil.getAttributes(
      new Account(),
      new Contact(),
      existingUser
    );
    attributes.put('User.ProfileId', admin.Name);

    String newFirstName = 'Rick';
    attributes.put('User.FirstName', newFirstName);

    SimpleJITHandler handler = new SimpleJITHandler();
    Test.startTest();

    handler.updateUser(
      existingUser.Id,
      samlSsoProviderId,
      communityId,
      portalId,
      JITTestUtil.FEDERATION_IDENTIFIER,
      attributes,
      JITTestUtil.SAML_ASSERTION
    );

    Test.stopTest();

    User updatedUser = JITTestUtil.queryOneUserById(existingUser.Id);
    System.assertEquals(existingUser.Email, updatedUser.Email);
    System.assertEquals(null, updatedUser.ContactId);
    System.assertNotEquals(existingUser.FirstName, updatedUser.FirstName);
    System.assertEquals(newFirstName, updatedUser.FirstName);
  }
}
