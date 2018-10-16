import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var cursor = await client.file.search();
  var results = await cursor.fetchAll();

  for (var result in results) {
    var file = result.item;
    print("${file.name}");
    print("  PHID: ${file.phid}");
  }

  ConduitUtils.closeHttpClient();
}
