@isTest
public with sharing class JITTestUtil {
  public static final String EMAIL_SUFFIX = '@test.test';
  public static final String USERNAME_SUFFIX = '.env';
  public static final String TIMEZONE_SID_KEY_CHICAGO = 'America/Chicago';
  public static final String TIMEZONE_SID_KEY_NEWYORK = 'America/New_York';
  public static final String DEFAULT_LANGUAGE = 'en_US';
  public static final String DEFAULT_ENCODING = 'UTF-8';
  public static final String PROFILE_ADMIN = 'System Administrator';
  public static final String FEDERATION_IDENTIFIER = 'abc123';
  public static final String SAML_ASSERTION = 'iamasamlassertion';
  public static final String FIRST_NAME = 'joe';
  public static final String LAST_NAME = 'Sanchez';
  public static final String PHONE = '4405551234';
  public static final String ACCOUNT_NAME = 'The Council of Ricks';
  public static final String ACCOUNT_NUMBER = 'ACC123';

  public static Account createAccount(String name) {
    return new Account(Name = name);
  }

  public static Contact createContact(String lastName) {
    return new Contact(
      FirstName = FIRST_NAME,
      LastName = lastName,
      Email = buildEmailFromLastName(lastName),
      Phone = PHONE
    );
  }

  public static User createUser(String lastName, Id profileId) {
    String email = buildEmailFromLastName(lastName);
    String alias = buildAlias(FIRST_NAME, lastName);

    return new User(
      FirstName = FIRST_NAME,
      LastName = lastName,
      Email = email,
      ProfileId = profileId,
      UserName = email + USERNAME_SUFFIX,
      Alias = alias,
      TimeZoneSidKey = TIMEZONE_SID_KEY_NEWYORK,
      LocaleSidKey = DEFAULT_LANGUAGE,
      LanguageLocaleKey = DEFAULT_LANGUAGE,
      EmailEncodingKey = DEFAULT_ENCODING
    );
  }

  public static String buildEmailFromLastName(String lastName) {
    return (lastName + EMAIL_SUFFIX).toLowerCase();
  }

  public static String buildAlias(String firstName, String lastName) {
    String alias = '';
    if (String.isBlank(firstName)) {
      alias = lastName;
    } else {
      alias = firstName.charAt(0) + lastName;
    }

    if (alias.length() > 5) {
      alias = alias.substring(0, 5);
    }
    return alias.toLowerCase();
  }

  public static Map<String, String> getAttributes(
    Account acc,
    Contact con,
    User u
  ) {
    String email = buildEmailFromLastName(u.LastName);
    return new Map<String, String>{
      'User.UserName' => u.UserName,
      'User.Email' => u.Email,
      'User.FirstName' => u.FirstName,
      'User.LastName' => u.LastName,
      'User.CommunityNickname' => 'squanch',
      'User.ProfileId' => PROFILE_ADMIN,
      'User.FederationIdentifier' => FEDERATION_IDENTIFIER,
      'Account.AccountNumber' => acc.AccountNumber,
      'Account.Name' => acc.Name,
      'Contact.Email' => con.Email,
      'Contact.Phone' => con.Phone,
      'Contact.FirstName' => con.FirstName,
      'Contact.LastName' => con.LastName
    };
  }

  public static Account queryOneAccount() {
    return [
      SELECT Id, AccountNumber, Name
      FROM Account
      LIMIT 1
    ];
  }

  public static Contact queryOneContact() {
    return [
      SELECT Id, Email, FirstName, LastName, Phone, AccountId
      FROM Contact
      LIMIT 1
    ];
  }

  public static Account queryOneAccountByName(String name) {
    return [
      SELECT Id, AccountNumber, Name
      FROM Account
      WHERE Name = :name
      LIMIT 1
    ];
  }

  public static Account queryOneAccountById(Id accountId) {
    return [
      SELECT Id, AccountNumber, Name
      FROM Account
      WHERE Id = :accountId
      LIMIT 1
    ];
  }

  public static Contact queryOneContactByUser(Id contactId) {
    return [
      SELECT Id, Email, FirstName, LastName, Phone, AccountId
      FROM Contact
      WHERE Id = :contactId
      LIMIT 1
    ];
  }

  public static Profile queryOneProfileByName(String name) {
    return [
      SELECT Id, Name
      FROM Profile
      WHERE Name = :name
      LIMIT 1
    ];
  }

  public static UserRole queryOneRoleByName(String name) {
    return [
      SELECT Id, Name
      FROM UserRole
      WHERE Name = :name
      LIMIT 1
    ];
  }

  public static User queryOneUserById(Id userId) {
    return [
      SELECT Id, FirstName, LastName, Email, ContactId
      FROM User
      WHERE Id = :userId
      LIMIT 1
    ];
  }
}
