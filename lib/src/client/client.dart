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

final JsonEncoder _jsonEncoder = new JsonEncoder(
  (x) {
    if (x is ConduitObject &&
        x.json is Map &&
        x.json["phid"] is String) {
      return x.json["phid"];
    }

    return x;
  }
);

final ContentType _formContentType = new ContentType("application", "x-www-form-urlencoded");

class ConduitClient {
  final Uri baseUri;

  String token;

  ConduitClient.forUri(this.baseUri, {this.token});

  factory ConduitClient(String url, {String token}) {
    return new ConduitClient.forUri(Uri.parse(url), token: token);
  }

  Future<dynamic> callMethod(String method, Map<String, dynamic> params) async {
    var fullParams = new Map<String, dynamic>.from(params);
    var url = baseUri.resolve("/api/${method}");

    if (token != null) {
      if (fullParams["__conduit__"] is! Map) {
        fullParams["__conduit__"] = {};
      }

      fullParams["__conduit__"] = {
        "token": token
      };
    }

    var request = await ConduitUtils.httpClient.postUrl(url);
    request.headers.contentType = _formContentType;

    var jsonParamsContent = _jsonEncoder.convert(fullParams);
    request.write("output=json&params=${Uri.encodeComponent(jsonParamsContent)}");
    var response = await request.close();
    return ConduitUtils.handleResponse(response);
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

  AlmanacService _almanac;
  AlmanacService get almanac =>
    _almanac == null ?
        _almanac = new AlmanacService(this) :
        _almanac;

  AuthConduitService _auth;
  AuthConduitService get auth =>
    _auth == null ?
      _auth = new AuthConduitService(this) :
      _auth;

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

  MacroConduitService _macro;
  MacroConduitService get macro =>
    _macro == null ?
      _macro = new MacroConduitService(this) :
      _macro;

  PhabulousConduitService _phabulous;
  PhabulousConduitService get phabulous =>
    _phabulous == null ?
      _phabulous = new PhabulousConduitService(this) :
      _phabulous;

  PhurlConduitService _phurl;
  PhurlConduitService get phurl =>
    _phurl == null ?
      _phurl = new PhurlConduitService(this) :
      _phurl;
}
