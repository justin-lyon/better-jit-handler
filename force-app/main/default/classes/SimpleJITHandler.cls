global class SimpleJITHandler implements Auth.SamlJitHandler {
  private static final String ATTR_ERROR = 'Expected the following attributes on {!OBJECT}: ';
  private class JITException extends Exception {
  }

  global User createUser(
    Id samlSsoProviderId,
    Id communityId,
    Id portalId,
    String federationIdentifier,
    Map<String, String> attributes,
    String samlAssertion
  ) {
    SamlModel payload = new SamlModel(
      samlSsoProviderId,
      communityId,
      portalId,
      federationIdentifier,
      attributes,
      samlAssertion
    );

    User newUser;
    UserJITHandler userHandler = new UserJITHandler(payload);

    if (isExternalUser(payload)) {
      AccountJITHandler accountHandler = new AccountJITHandler(payload);
      Account userAccount = accountHandler.getAccount();
      upsert userAccount;

      ContactJITHandler contactHandler = new ContactJITHandler(
        payload,
        userAccount.Id
      );
      Contact userContact = contactHandler.getContact();
      upsert userContact;

      newUser = userHandler.createUser(userContact.Id);
    } else {
      newUser = userHandler.createUser();
    }

    return newUser;
  }

  global void updateUser(
    Id userId,
    Id samlSsoProviderId,
    Id communityId,
    Id portalId,
    String federationIdentifier,
    Map<String, String> attributes,
    String samlAssertion
  ) {
    SamlModel payload = new SamlModel(
      userId,
      samlSsoProviderId,
      communityId,
      portalId,
      federationIdentifier,
      attributes,
      samlAssertion
    );

    User existingUser = queryOneUserById(payload.userId);
    UserJITHandler userHandler = new UserJITHandler(payload);
    User updatedUser = userHandler.updateUser(existingUser);

    if (isExternalUser(payload)) {
      AccountJITHandler accountHandler = new AccountJITHandler(payload);
      Account userAccount = accountHandler.getAccount();
      upsert userAccount;

      ContactJITHandler contactHandler = new ContactJITHandler(
        payload,
        userAccount.Id
      );
      Contact userContact = contactHandler.getContact();
      upsert userContact;
    }

    userHandler.enqueueUserUpdate(updatedUser);
  }

  private User queryOneUserById(Id userId) {
    return [
      SELECT Id
      FROM User
      WHERE Id = :userId
      LIMIT 1
    ];
  }

  private Boolean isExternalUser(SamlModel payload) {
    return payload.communityId != null || payload.portalId != null;
  }
}
