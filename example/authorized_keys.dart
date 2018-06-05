import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();
  var currentUser = await client.user.getCurrentUser();
  var cursor = await client.auth.getAuthorizedKeys([currentUser.phid]);
  var lines = await cursor.fetchAll();
  print(lines.join("\n"));
  ConduitUtils.closeHttpClient();
}
