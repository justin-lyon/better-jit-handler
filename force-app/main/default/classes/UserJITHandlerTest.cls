@isTest
private class UserJITHandlerTest {

	static TestMethod void createUser_givenInternal_shouldGetNewUser() {
		Id samlSsoProviderId = '00100000000000a';
		Id communityId = null;
		Id portalId = null;

		User samlUser = JITTestUtil.createUser(JITTestUtil.LAST_NAME, UserInfo.getProfileId());

		Map<String, String> attributes = JITTestUtil.getAttributes(
			new Account(),
			new Contact(),
			samlUser);

		SamlModel payload = new SamlModel(
			samlSsoProviderId,
			communityId,
			portalId,
			JITTestUtil.FEDERATION_IDENTIFIER,
			attributes,
			JITTestUtil.SAML_ASSERTION);

		UserJITHandler handler = new UserJITHandler(payload);
		Test.startTest();

			User newUser = handler.createUser();

		Test.stopTest();

		System.assertEquals(samlUser.Email, newUser.Email);
		System.assertEquals(null, newUser.ContactId);
	}

	static TestMethod void createUser_givenExternal_shouldGetNewUser() {
		Id samlSsoProviderId = '00100000000000a';
		Id communityId = '09a00000000000c';
		Id portalId = null;
		Id contactId = '00300000000000c';

		User samlUser = JITTestUtil.createUser(JITTestUtil.LAST_NAME, UserInfo.getProfileId());

		Map<String, String> attributes = JITTestUtil.getAttributes(
			new Account(),
			new Contact(),
			samlUser);

		SamlModel payload = new SamlModel(
			samlSsoProviderId,
			communityId,
			portalId,
			JITTestUtil.FEDERATION_IDENTIFIER,
			attributes,
			JITTestUtil.SAML_ASSERTION);

		UserJITHandler handler = new UserJITHandler(payload);
		Test.startTest();

			User newUser = handler.createUser(contactId);

		Test.stopTest();

		System.assertEquals(samlUser.Email, newUser.Email);
		System.assertEquals(contactId, newUser.ContactId);
	}

	static TestMethod void updateUser_givenUser_shouldGetNewUser() {
		Id samlSsoProviderId = '00100000000000a';
		Id communityId = '09a00000000000c';
		Id portalId = null;
		Id contactId = '00300000000000c';

		User samlUser = JITTestUtil.createUser(JITTestUtil.LAST_NAME, UserInfo.getProfileId());

		Map<String, String> attributes = JITTestUtil.getAttributes(
			new Account(),
			new Contact(),
			samlUser);

		String newFirstName = JITTestUtil.FIRST_NAME + '2';
		attributes.put('User.FirstName', newFirstName);

		SamlModel payload = new SamlModel(
			samlSsoProviderId,
			communityId,
			portalId,
			JITTestUtil.FEDERATION_IDENTIFIER,
			attributes,
			JITTestUtil.SAML_ASSERTION);

		UserJITHandler handler = new UserJITHandler(payload);
		Test.startTest();

			User newUser = handler.updateUser(samlUser);

		Test.stopTest();

		System.assertEquals(newFirstName, newUser.FirstName);
	}

	static TestMethod void enqueueUserUpdate_givenUser_shouldUpdateUser() {
		Id samlSsoProviderId = '00100000000000a';
		Id communityId = '09a00000000000c';
		Id portalId = null;
		Id contactId = '00300000000000c';

		User newUser = JITTestUtil.createUser(JITTestUtil.LAST_NAME, UserInfo.getProfileId());
		insert newUser;

		Map<String, String> attributes = JITTestUtil.getAttributes(
			new Account(),
			new Contact(),
			newUser);

		String newFirstName = JITTestUtil.FIRST_NAME + '2';
		newUser.firstName = newFirstName;

		SamlModel payload = new SamlModel(
			samlSsoProviderId,
			communityId,
			portalId,
			JITTestUtil.FEDERATION_IDENTIFIER,
			attributes,
			JITTestUtil.SAML_ASSERTION);

		UserJITHandler handler = new UserJITHandler(payload);
		Test.startTest();

			Id jobId = handler.enqueueUserUpdate(newUser);

		Test.stopTest();

		User updatedUser = JITTestUtil.queryOneUserById(newUser.Id);
		System.assertNotEquals(null, jobId);
		System.assertEquals(newFirstName, updatedUser.FirstName);
	}
}