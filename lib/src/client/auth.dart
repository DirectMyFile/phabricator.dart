part of phabricator.client;

class AuthConduitService extends ConduitService {
  @override
  String get group => "auth";

  AuthConduitService(ConduitClient client) : super(client);
}
