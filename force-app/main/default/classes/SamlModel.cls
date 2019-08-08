/**
 * SamlModel.cls
 * Provided the attributes map from Saml, Model the attributes into Apex Objects for consumption.
 */
public class SamlModel {
	public class SamlParseException extends Exception {}

	public Id userId {get; private set;}
	public Id samlSsoProviderId {get; private set;}
	public Id communityId {get; private set;}
	public Id portalId {get; private set;}
	public String federationIdentifier {get; private set;}
	public String samlAssertion {get; private set;}

	public UserModel user {get; private set;}
	public ContactModel contact {get; private set;}
	public AccountModel account {get; private set;}

	public SamlModel(
			Id samlSsoProviderId,
			Id communityId,
			Id portalId,
			String federationIdentifier,
			Map<String, String> attributes,
			String samlAssertion) {

		this(
			null,
			samlSsoProviderId,
			communityId,
			portalId,
			federationIdentifier,
			attributes,
			samlAssertion);
	}

	public SamlModel(
			Id userId,
			Id samlSsoProviderId,
			Id communityId,
			Id portalId,
			String federationIdentifier,
			Map<String, String> attributes,
			String samlAssertion) {

		this.userId = userId;
		this.samlSsoProviderId = samlSsoProviderId;
		this.communityId = communityId;
		this.portalId = portalId;
		this.federationIdentifier = federationIdentifier;
		this.samlAssertion = samlAssertion;

		validateAttributes(attributes);

		this.user = new UserModel(attributes, federationIdentifier);
		this.user.id = userId;
		this.contact = new ContactModel(attributes);
		this.account = new AccountModel(attributes);
	}

	public class UserModel {
		public String id {get;set;}
		public String username {get; private set;}
		public String federationIdentifier {get; private set;}
		public String email {get; private set;}
		public String firstName {get; private set;}
		public String lastName {get; private set;}
		public String profileName {get; private set;}
		public String communityNickname {get; private set;}
		public String contactId {get; private set;}
		public String accountId {get; private set;}

		public UserModel(Map<String, String> attributes, String fedId) {
			this.username = attributes.containsKey('User.Username')
				? attributes.get('User.Username') : null;
			this.email = attributes.containsKey('User.Email')
				? attributes.get('User.Email') : null;
			this.firstName = attributes.containsKey('User.FirstName')
				? attributes.get('User.FirstName') : null;
			this.lastName = attributes.containsKey('User.LastName')
				? attributes.get('User.LastName') : null;
			this.communityNickname = attributes.containsKey('User.CommunityNickname')
				? attributes.get('User.CommunityNickname') : null;
			this.profileName = attributes.containsKey('User.ProfileId')
				? attributes.get('User.ProfileId') : null;
			this.contactId = attributes.containsKey('User.Contact')
				? attributes.get('User.Contact') : null;
			this.accountId = attributes.containsKey('User.Account')
				? attributes.get('User.Account') : null;

			if(fedId != null) {
				this.federationIdentifier = fedId;
			} else if(attributes.containsKey('User.FederationIdentifier')) {
				this.federationIdentifier = attributes.get('User.FederationIdentifier');
			}
		}

		public String getAlias() {
			String alias = '';
			if(String.isBlank(firstName)) {
				alias = lastName;
			} else {
				alias = firstName.charAt(0) + lastName;
			}

			if(alias.length() > 5) {
				alias = alias.substring(0, 5);
			}
			return alias.toLowerCase();
		}

		public User getRecord() {
			return new User(
				Id = this.id,
				Username = this.username,
				FederationIdentifier = this.federationIdentifier,
				Email = this.email,
				FirstName = this.firstName,
				LastName = this.lastName);
		}
	}

	public class ContactModel {
		public Id contactId {get; private set;}
		public String email {get; private set;}
		public String phone {get; private set;}
		public String firstName {get; private set;}
		public String lastName {get; private set;}

		public ContactModel(Map<String, String> attributes) {
			this.contactId = attributes.containsKey('User.Contact')
				? attributes.get('User.Contact') : null;
			this.email = attributes.containsKey('Contact.Email')
				? attributes.get('Contact.Email') : null;
			this.phone = attributes.containsKey('Contact.Phone')
				? attributes.get('Contact.Phone') : null;
			this.firstName = attributes.containsKey('Contact.FirstName')
				? attributes.get('Contact.FirstName') : null;
			this.lastName = attributes.containsKey('Contact.LastName')
				? attributes.get('Contact.LastName') : null;
		}
	}

	public class AccountModel {
		public String accountNumber {get; private set;}
		public String name {get; private set;}

		public AccountModel(Map<String, String> attributes) {

			this.accountNumber = attributes.containsKey('Account.AccountNumber')
				? attributes.get('Account.AccountNumber') : null;

			if(attributes.containsKey('Account.Name')) {
				this.name = attributes.get('Account.Name');
			} else if(attributes.containsKey('User.Account')) {
				this.name = attributes.get('User.Account');
			}
		}
	}

	private void validateAttributes(Map<String, String> attributes) {
		if(this.federationIdentifier == null && !attributes.containsKey('User.FederationIdentifier')) {
			throw new SamlParseException('SAML must provide a Federation Identifier.');
		}

		if(attributes.containsKey('User.FederationIdentifier') && this.federationIdentifier != attributes.get('User.FederationIdentifier')) {
			throw new SamlParseException('Federation Identifier mismatch in SAML Payload.');
		}
	}
}