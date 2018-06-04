import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var cursor = await client.project.query();
  var projects = await cursor.fetchAll();

  for (Project project in projects) {
    print("${project.name}");
    print("  PHID: ${project.phid}");
  }

  ConduitUtils.closeHttpClient();
}
