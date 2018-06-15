import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var cursor = await client.maniphest.search();
  var results = await cursor.fetchAll();

  for (var result in results) {
    var task = result.item;

    print("${task.title}");
    print("  PHID: ${task.phid}");
  }

  ConduitUtils.closeHttpClient();
}
