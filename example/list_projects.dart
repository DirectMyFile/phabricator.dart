import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var cursor = await client.project.search();
  var results = await cursor.fetchAll();

  for (var result in results) {
    var project = result.item;
    print("${project.name}");
    print("  PHID: ${project.phid}");
  }

  ConduitUtils.closeHttpClient();
}
