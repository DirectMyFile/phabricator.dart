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

  Future<ConduitCapabilities> getCapabilities() async {
    var result = await callMethod("conduit.getcapabilities", {});
    return new ConduitCapabilities()..decode(result);
  }

  Future<ConduitMethodQueryResult> getMethods() async {
    var result = await callMethod("conduit.query", {});
    return new ConduitMethodQueryResult()..decode(result);
  }

  ProjectConduitService _project;
  ProjectConduitService get project =>
    _project == null ?
      _project = new ProjectConduitService(this) :
      _project;

  ConpherenceConduitService _conpherence;

  ConpherenceConduitService get conpherence =>
    _conpherence == null ?
      _conpherence = new ConpherenceConduitService(this) :
      _conpherence;

  FileConduitService _file;

  FileConduitService get file =>
    _file == null ?
      _file = new FileConduitService(this) :
      _file;

  HarbormasterConduitService _harbormaster;

  HarbormasterConduitService get harbormaster =>
    _harbormaster == null ?
      _harbormaster = new HarbormasterConduitService(this) :
      _harbormaster;

  DiffusionConduitService _diffusion;

  DiffusionConduitService get diffusion =>
    _diffusion == null ?
      _diffusion = new DiffusionConduitService(this) :
      _diffusion;

  ManiphestConduitService _maniphest;

  ManiphestConduitService get maniphest =>
    _maniphest == null ?
      _maniphest = new ManiphestConduitService(this) :
      _maniphest;

  UserConduitService _user;

  UserConduitService get user =>
    _user == null ?
      _user = new UserConduitService(this) :
      _user;
}
