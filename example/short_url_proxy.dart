import "dart:io";

import "package:phabricator/client.dart";
import "package:phabricator/credential.dart";

ConduitClient client;

final ContentType _htmlContentType = new ContentType("text", "html", charset: "utf-8");

main(List<String> args) async {
  int port = 2000;

  if (args.isNotEmpty) {
    port = int.parse(args[0]);
  }

  client = await createDefaultConduitClient();
  await client.ping();

  var server = await HttpServer.bind("0.0.0.0", port);

  print("Short URL server listening on port ${port}");

  await server.listen((request) async {
    try {
      await handleRequest(request, request.response);
    } catch (e, stack) {
      print("[ERROR] ${e}\nTrace: ${stack}");

      await request.response.close();
    }
  }, onError: (e, stack) {
    print("[ERROR] ${e}\nTrace: ${stack}");
  }, cancelOnError: false).asFuture();

  ConduitUtils.closeHttpClient();
}

handleRequest(HttpRequest request, HttpResponse response) async {
  var alias = request.uri.path.substring(1);
  var cursor = await client.phurl.search(constraints: {
    "aliases": [alias]
  });

  if (cursor.isEmpty) {
    response.statusCode = 404;
    response.headers.contentType = _htmlContentType;
    response.writeln("<h3>Short URL not found.</h3>");
    await response.close();
    return;
  }

  var entry = cursor[0];
  var longUrl = entry.item.longUrl;
  print("[Short Link Handler] ${alias} => ${longUrl}");

  await request.response.redirect(Uri.parse(longUrl));
}
