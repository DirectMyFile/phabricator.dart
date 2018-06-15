part of phabricator.client;

class User extends ConduitObject<Map<String, dynamic>> {
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

class UserConduitService extends SearchableConduitService<User> {
  UserConduitService(ConduitClient client) : super(client, "USER");

  @override
  String get group => "user";

  Future<LoggedInUser> whoAmI() async  {
    var user = new LoggedInUser();
    var whoAmI = await callMethod("whoami", {});
    user.decode(whoAmI);
    return user;
  }

  Future<LoggedInUser> getCurrentUser() => whoAmI();
}
