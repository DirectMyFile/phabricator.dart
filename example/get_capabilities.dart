import "package:phabricator/client.dart";

main(List<String> args) async {
  var client = new ConduitClient(args[0], token: args[1]);

  var map = await client.callMethod("conduit.getcapabilities", {});
  print(map);

  ConduitUtils.closeHttpClient();
}
