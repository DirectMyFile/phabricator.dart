import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var capabilities = await client.getCapabilities();

  for (var type in capabilities.types) {
    print("${type}:");
    var caps = capabilities.getCapabilities(type);
    for (var cap in caps) {
      print("  ${cap}");
    }
  }

  ConduitUtils.closeHttpClient();
}
