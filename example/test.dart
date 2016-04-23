import "package:phabricator/client.dart";

main(List<String> args) async {
  var client = new ConduitClient(args[0], token: args[1]);

  var cursor = await client.project.query();
  var projects = await cursor.fetchAll();

  for (Project project in projects) {
    print("- ${project.name}");
    print("  PHID: ${project.phid}");
  }

  ConduitUtils.closeHttpClient();
}
