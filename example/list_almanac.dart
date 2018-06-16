import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();

  var cursor = await client.almanac.device.search(attachments: {
    "properties": true,
    "interfaces": true
  });

  var results = await cursor.fetchAll();

  for (var result in results) {
    var device = result.item;
    print("${device.name}:");
    var properties = result.getAttachment("properties");

    print("  Properties:");
    for (var property in properties) {
      var key = property["key"];
      var value = property["value"];
      print("    ${key}: ${value}");
    }

    var ifaceResult = await client.almanac.interface.search(
      constraints: {
        "devicePHIDs": [device.phid]
      }
    );

    var interfaces = await ifaceResult.fetchAll();

    print("  Interfaces:");
    for (var iresult in interfaces) {
      var iface = iresult.item;

      var networkResults = await client.almanac.network.search(
        constraints: {
          "phids": [iface.networkPHID]
        }
      );

      print("    ${iface.id}:");

      if (networkResults.isNotEmpty) {
        var network = networkResults.first.item;
        print("      Network: ${network.name}");
      }

      print("      Address: ${iface.address}");
      print("      Port: ${iface.port}");
    }
  }

  ConduitUtils.closeHttpClient();
}
