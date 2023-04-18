@isTest
private class ContactJITHandlerTest {
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

  static testMethod void getContact_givenNewContact_shouldGetNewContact() {
    Id samlSsoProviderId = '00100000000000a';
    Id communityId = null;
    Id portalId = null;

    String newLastName = JITTestUtil.LAST_NAME + '2';
    Contact newPartnerContact = JITTestUtil.createContact(newLastName);
    User samlUser = JITTestUtil.createUser(
      newLastName,
      UserInfo.getProfileId()
    );

    Map<String, String> attributes = JITTestUtil.getAttributes(
      new Account(),
      newPartnerContact,
      samlUser
    );

    SamlModel payload = new SamlModel(
      samlSsoProviderId,
      communityId,
      portalId,
      JITTestUtil.FEDERATION_IDENTIFIER,
      attributes,
      JITTestUtil.SAML_ASSERTION
    );

    ContactJITHandler handler = new ContactJITHandler(
      payload,
      '001000000000000'
    );
    Test.startTest();

    Contact newContact = handler.getContact();

    Test.stopTest();

    System.assertEquals(newPartnerContact.LastName, newContact.LastName);
    System.assertEquals(null, newContact.Id);
  }

  static testMethod void getContact_givenExistingContact_shouldUpdateContact() {
    Id samlSsoProviderId = '00100000000000a';
    Id communityId = null;
    Id portalId = null;

    Contact existingContact = JITTestUtil.queryOneContact();
    User samlUser = JITTestUtil.createUser(
      JITTestUtil.LAST_NAME,
      UserInfo.getProfileId()
    );

    Map<String, String> attributes = JITTestUtil.getAttributes(
      new Account(),
      existingContact,
      samlUser
    );
    System.assertNotEquals(null, existingContact.Id);
    attributes.put('User.Contact', existingContact.Id);

    SamlModel payload = new SamlModel(
      samlSsoProviderId,
      communityId,
      portalId,
      JITTestUtil.FEDERATION_IDENTIFIER,
      attributes,
      JITTestUtil.SAML_ASSERTION
    );

    ContactJITHandler handler = new ContactJITHandler(
      payload,
      existingContact.AccountId
    );
    Test.startTest();

    Contact newContact = handler.getContact();

    Test.stopTest();

    System.assertEquals(existingContact.LastName, newContact.LastName);
    System.assertNotEquals(null, newContact.Id);
    System.assertEquals(existingContact.Id, newContact.Id);
  }
}
