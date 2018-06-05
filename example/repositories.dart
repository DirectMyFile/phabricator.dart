import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

main(List<String> args) async {
  var client = await createDefaultConduitClient();
  var cursor = await client.diffusion.repository.search();

  var results = await cursor.fetchAll();
  
  for (var result in results) {
    print(result.item.name);
  }

  ConduitUtils.closeHttpClient();
}
