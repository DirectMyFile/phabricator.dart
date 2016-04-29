import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var tasks = await client.maniphest.query();

  for (ManiphestTask task in tasks) {
    print("- (${task.objectName}): ${task.title}");
  }

  ConduitUtils.closeHttpClient();
}
