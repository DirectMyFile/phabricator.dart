import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var methods = await client.getMethods();

  for (var name in methods.methodNames) {
    var method = methods.getMethod(name);
    print("${name}:");
    
    if (method.params.isNotEmpty) {
      print("  Parameters:");
      for (var paramName in method.params.keys) {
        print("    ${paramName}: ${method.params[paramName]}");
      }
    }

    print("  Result Type: ${method.returns}");
  }

  ConduitUtils.closeHttpClient();
}
