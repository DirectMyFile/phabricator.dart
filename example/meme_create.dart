import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var url = await client.macro.createMeme(
    args[0],
    upperText: args.length >= 1 ? args[1] : null,
    lowerText: args.length >= 2 ? args[2] : null
  );

  print(url);

  ConduitUtils.closeHttpClient();
}
