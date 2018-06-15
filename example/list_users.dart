import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var cursor = await client.user.search();
  var results = await cursor.fetchAll();

  for (var result in results) {
    var user = result.item;

    print("${user.realname}");
    print("  PHID: ${result.phid}");
  }

  ConduitUtils.closeHttpClient();
}
