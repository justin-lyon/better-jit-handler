public with sharing class AccountJITHandler {
	private SamlModel payload;

	public AccountJITHandler(SamlModel payload) {
		this.payload = payload;
	}

	public Account getAccount() {
		Account userAccount;
		try {
			userAccount = queryOneAccountById(payload.user.accountId);
			userAccount = updateAccount(userAccount);
		} catch(QueryException qex) {
			userAccount = updateAccount(new Account());
		}
		return userAccount;
	}

	private Account updateAccount(Account acc) {
		acc.Name = payload.account.name;
		acc.AccountNumber = payload.account.accountNumber;

		return acc;
	}

	private Account queryOneAccountById(Id accountId) {
		return [
			SELECT Id
			FROM Account
			WHERE Id = :accountId
			LIMIT 1];
	}
}
