@isTest
private class AccountJITHandlerTest {
	@TestSetup
	static void makeData(){
		Account partnerAccount = JITTestUtil.createAccount(JITTestUtil.ACCOUNT_NAME);
		partnerAccount.AccountNumber = JITTestUtil.ACCOUNT_NUMBER;
		insert partnerAccount;
	}

	static TestMethod void getAccount_givenNewAccount_shouldGetNewAccount() {
		Id samlSsoProviderId = '00100000000000a';
		Id communityId = null;
		Id portalId = null;

		User samlUser = JITTestUtil.createUser(JITTestUtil.LAST_NAME, UserInfo.getProfileId());
		Account newAccount = JITTestUtil.queryOneAccount();

		Map<String, String> attributes = JITTestUtil.getAttributes(
			newAccount,
			new Contact(),
			samlUser);

		String newAccountName = newAccount.Name + '2';
		attributes.put('Account.Name', newAccountName);

		SamlModel payload = new SamlModel(
			samlSsoProviderId,
			communityId,
			portalId,
			JITTestUtil.FEDERATION_IDENTIFIER,
			attributes,
			JITTestUtil.SAML_ASSERTION);

		AccountJITHandler handler = new AccountJITHandler(payload);
		Test.startTest();

			Account updatedAccount = handler.getAccount();

		Test.stopTest();

		System.assertNotEquals(newAccount.Name, updatedAccount.Name);
		System.assertEquals(newAccountName, updatedAccount.Name);
		System.assertEquals(null, updatedAccount.Id);
	}

	static TestMethod void getAccount_givenExistingAccount_shouldGetUpdatedAccount() {
		Id samlSsoProviderId = '00100000000000a';
		Id communityId = null;
		Id portalId = null;

		User samlUser = JITTestUtil.createUser(JITTestUtil.LAST_NAME, UserInfo.getProfileId());
		Account existingAccount = JITTestUtil.queryOneAccount();

		Map<String, String> attributes = JITTestUtil.getAttributes(
			existingAccount,
			new Contact(),
			samlUser);

		attributes.put('User.Account', existingAccount.Id);

		SamlModel payload = new SamlModel(
			samlSsoProviderId,
			communityId,
			portalId,
			JITTestUtil.FEDERATION_IDENTIFIER,
			attributes,
			JITTestUtil.SAML_ASSERTION);

		AccountJITHandler handler = new AccountJITHandler(payload);
		Test.startTest();

			Account updatedAccount = handler.getAccount();

		Test.stopTest();

		System.assertEquals(existingAccount.Name, updatedAccount.Name);
		System.assertNotEquals(null, updatedAccount.Id);
	}
}