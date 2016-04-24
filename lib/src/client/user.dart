part of phabricator.client;

class User extends ConduitObject<Map<String, dynamic>> {
  String phid;
  String username;
  String realname;
  String image;
  String uri;
  List<String> roles;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;

    phid = input["phid"];
    username = input["userName"];
    realname = input["realName"];
    image = input["image"];
    uri = input["uri"];
    roles = input["roles"];
  }
}

class LoggedInUser extends User {
  String primaryEmail;

  @override
  void decode(Map<String, dynamic> input) {
    super.decode(input);
    primaryEmail = input["primaryEmail"];
  }
}

class UserConduitService extends ConduitService {
  UserConduitService(ConduitClient client) : super(client);

  @override
  String get group => "whoami";

  Future<LoggedInUser> whoAmI() async  {
    var user = new LoggedInUser();
    user.decode(await callMethod("whoami", {}));
    return user;
  }

  Future<LoggedInUser> getCurrentUser() => whoAmI();
}
