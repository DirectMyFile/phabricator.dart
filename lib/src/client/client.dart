part of phabricator.client;

abstract class ConduitService {
  final ConduitClient client;

  ConduitService(this.client);

  String get group;

  Future<dynamic> callMethod(String method, Map<String, dynamic> params) async {
    var prefix = "${group}.";
    if (!method.startsWith(prefix)) {
      method = "${prefix}${method}";
    }

    return await client.callMethod(method, params);
  }
}

class ConduitClient {
  final Uri baseUri;

  String token;

  ConduitClient.forUri(this.baseUri, {this.token});

  factory ConduitClient(String url, {String token}) {
    return new ConduitClient.forUri(Uri.parse(url), token: token);
  }

  Future<dynamic> callMethod(String method, Map<String, dynamic> params) async {
    var out = new Map<String, dynamic>.from(params);

    if (token != null) {
      out["api.token"] = token;
    }

    return ConduitUtils.handleResponse(await ConduitUtils.httpClient.post(
      baseUri.resolve("/api/${method}"),
      body: out
    ));
  }

  Future<String> ping() async {
    return await callMethod("conduit.ping", {});
  }

  ProjectConduitService _project;
  ProjectConduitService get project =>
    _project == null ? _project = new ProjectConduitService(this) : _project;
}
