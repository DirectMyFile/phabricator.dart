library phabricator.credential;

import "dart:async";
import "dart:convert";
import "dart:io";

import "client.dart";

class ArcanistHostConfig {
  final String apiUrl;
  final Map<String, dynamic> json;

  ArcanistHostConfig(this.apiUrl, this.json);

  String getConfigOption(String key) =>
    json[key];

  String get token => getConfigOption("token");
  bool get hasToken => token is String;

  String get baseUrl {
    if (apiUrl.endsWith("/api/")) {
      return apiUrl.substring(0, apiUrl.length - 5);
    }
    
    if (apiUrl.endsWith("/api")) {
      return apiUrl.substring(0, apiUrl.length - 4);
    }

    return apiUrl;
  }
}

class ArcanistUserConfig {
  static Future<ArcanistUserConfig> loadFromFile(File file) async {
    var content = await file.readAsString();
    return new ArcanistUserConfig(const JsonDecoder().convert(content));
  }

  final Map<String, dynamic> json;

  ArcanistUserConfig(this.json);

  bool get hasAnyHosts =>
    json["hosts"] is Map && json["hosts"].isNotEmpty;

  ArcanistHostConfig getHostByApiUrl(String apiUrl)  {
    if (apiUrl == null || apiUrl.isEmpty) {
      return null;
    }

    if (!apiUrl.endsWith("/")) {
      apiUrl += "/";
    }

    var hosts = json["hosts"];

    if (hosts == null) {
      return null;
    }

    var subsection = hosts[apiUrl];

    if (subsection != null) {
      return new ArcanistHostConfig(apiUrl, subsection);
    }

    return null;
  }

  ArcanistHostConfig getHostByUrl(String url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    if (!url.endsWith("/")) {
      url += "/";
    }

    if (!url.endsWith("/api/")) {
      url += "api/";
    }

    return getHostByApiUrl(url);
  }

  ArcanistHostConfig get defaultHost => getHostByUrl(defaultHostUrl);

  String getConfigOption(String key) =>
    json["config"] is! Map ? null : json["config"][key];

  String get defaultHostUrl => getConfigOption("default");
}

Future<ArcanistUserConfig> getArcanistUserConfig() async {
  var home = Platform.environment["HOME"];

  if (home == null || home.isEmpty) {
    home = Platform.environment["USERPROFILE"];
  }

  if (home == null) {
    throw new Exception("Failed to determine platform home directory.");
  }

  var path = home;

  if (!path.endsWith(Platform.pathSeparator)) {
    path += Platform.pathSeparator;
  }

  var file = new File("${path}.arcrc");

  if (!(await file.exists())) {
    throw new Exception("Arcanist configuration file ${file.path} does not exist.");
  }

  return await ArcanistUserConfig.loadFromFile(file);
}

Future<ConduitClient> createDefaultConduitClient({String host}) async {
  var config = await getArcanistUserConfig();

  if (host == null) {
    host = config.defaultHostUrl;
  }

  if (host == null) {
    throw new Exception("Arcanist configuration does not have a default host.");
  }

  var hostConfig = config.getHostByUrl(host);

  if (hostConfig == null) {
    throw new Exception("Arcanist host ${host} was not configured.");
  }

  return new ConduitClient(
    hostConfig.baseUrl,
    token: hostConfig.token
  );
}
