public with sharing class ContactJITHandler {
  private SamlModel payload;
  private Id accountId;

  public ContactJITHandler(SamlModel payload, Id accountId) {
    this.payload = payload;
    this.accountId = accountId;
  }

  public Contact getContact() {
    Contact userContact;
    try {
      userContact = queryOneContactById(payload.user.contactId);
      userContact = updateContact(userContact);
    } catch (QueryException qex) {
      userContact = updateContact(new Contact());
    }
    return userContact;
  }

  private Contact updateContact(Contact con) {
    con.Email = payload.contact.email;
    con.FirstName = payload.contact.firstName;
    con.LastName = payload.contact.lastName;
    con.AccountId = accountId;

    return con;
  }

  private Contact queryOneContactById(Id contactId) {
    return [
      SELECT Id
      FROM Contact
      WHERE Id = :contactId
      LIMIT 1
    ];
  }
}
