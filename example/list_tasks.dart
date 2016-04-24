import "package:phabricator/client.dart";

main(List<String> args) async {
  var client = new ConduitClient(args[0], token: args[1]);

  var tasks = await client.maniphest.query();

  for (ManiphestTask task in tasks) {
    print("- (${task.objectName}): ${task.title}");
  }

  ConduitUtils.closeHttpClient();
}
