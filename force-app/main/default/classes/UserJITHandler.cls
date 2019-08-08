public with sharing class UserJITHandler {
	private SamlModel payload;

	public UserJITHandler(SamlModel payload) {
		this.payload = payload;
	}

	public User createUser() {
		return createUser(null);
	}
	public User createUser(Id contactId) {
		User newUser = createStubUser();
		newUser = updateUser(newUser);

		newUser.Username = payload.user.username;
		newUser.FederationIdentifier = payload.user.federationIdentifier;
		newUser.Alias = payload.user.getAlias();
		newUser.ContactId = contactId;

		return newUser;
	}

	public User updateUser(User u) {
		u.Email = payload.user.email;
		u.FirstName = payload.user.firstName;
		u.LastName = payload.user.lastName;
		u.CommunityNickname = payload.user.communityNickname;

		u.ProfileId = getProfileId();

		return u;
	}

	public Id enqueueUserUpdate(User u) {
		AsyncUserUpdate updateAction = new AsyncUserUpdate(u);
		return System.enqueueJob(updateAction);
	}

	private User createStubUser() {
		return new User(
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Chicago');
	}

	private Id getProfileId() {
		if (!String.isBlank(payload.user.profileName)) {
			Profile p = queryOneProfileByName(payload.user.profileName);
			return p.Id;
		}
		return UserInfo.getProfileId();
	}

	private Profile queryOneProfileByName(String name) {
		return [
			SELECT Id
			FROM Profile
			WHERE Name = :name
			LIMIT 1];
	}

	public class AsyncUserUpdate implements Queueable {
		private User newUser;

		public AsyncUserUpdate(User u) {
			this.newUser = u;
		}

		public void execute(QueueableContext ctx) {
			update newUser;
		}
	}
}
