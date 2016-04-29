import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var symbols = await client.diffusion.findSymbols(name: args[0]);

  for (DiffusionSymbol symbol in symbols) {
    print("- ${symbol.name}");
  }

  ConduitUtils.closeHttpClient();
}
