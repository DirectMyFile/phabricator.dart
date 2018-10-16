import "dart:io";

import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  if (args.length != 2) {
    print("Usage: upload <name> <path>");
    exit(1);
  }
  var client = await createDefaultConduitClient();
  var file = new File(args[1]);

  if (!(await file.exists())) {
    print("[ERROR] File does not exist: ${args[1]}");
    exit(1);
  }

  var name = args[0];
  if (name.trim().isEmpty) {
    name = "file";
  }

  var bytes = await file.readAsBytes();
  var phid = await client.file.upload(bytes, name: name);
  print(phid);
  ConduitUtils.closeHttpClient();
}
