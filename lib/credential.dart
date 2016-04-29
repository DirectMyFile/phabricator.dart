library phabricator.credential;

import "dart:async";
import "dart:convert";
import "dart:io";

import "client.dart";

class CredentialHost {
  String url;
  String token;

  Map encode() {
    return {
      "url": url,
      "token": token
    };
  }

  void decode(Map m) {
    url = m["url"];
    token = m["token"];
  }
}

class CredentialStore {
  String defaultHostName;
  Map<String, CredentialHost> hosts = {};

  void load(Map m) {
    if (m["defaultHost"] is String) {
      defaultHostName = m["defaultHost"];
    }

    if (m["hosts"] is Map) {
      Map hostMap = m["hosts"];
      for (String key in hostMap.keys) {
        if (hostMap[key] is Map) {
          var host = new CredentialHost();
          host.decode(hostMap[key]);
          hosts[key] = host;
        }
      }
    }
  }

  Future loadFromFile(File file) async {
    if (await file.exists()) {
      var content = await file.readAsString();
      load(const JsonDecoder().convert(content));
    } else {
      await file.create(recursive: true);
      await file.writeAsString(const JsonEncoder.withIndent("  ").convert({
        "defaultHost": null,
        "hosts": {}
      }) + "\n");
    }
  }

  CredentialHost get defaultHost {
    if (defaultHostName != null) {
      return hosts[defaultHostName];
    }
    return null;
  }
}

Future<CredentialStore> loadDefaultCredentialStore() async {
  var path = Platform.environment["PHABRICATOR_CREDENTIAL_STORE"];

  if (path == null) {
    var home = Platform.environment["HOME"];
    if (home != null) {
      path = "${home}/.phabricator/credentials.json";
    }
  }

  var store = new CredentialStore();

  if (path == null) {
    return store;
  }

  await store.loadFromFile(new File(path));

  return store;
}

Future<ConduitClient> createDefaultConduitClient() async {
  var store = await loadDefaultCredentialStore();
  var host = store.defaultHost;
  return new ConduitClient(host.url, token: host.token);
}
