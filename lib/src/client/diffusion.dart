part of phabricator.client;

class DiffusionSymbol extends ConduitObject<Map<String, dynamic>> {
  String name;
  String context;
  String type;
  String language;
  String path;
  int line;
  String uri;
  String repositoryPhid;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;

    name = input["name"];
    context = input["context"];
    type = input["type"];
    language = input["language"];
    path = input["path"];
    line = ConduitUtils.asInt(input["line"]);
    uri = input["uri"];
    repositoryPhid = input["repositoryPHID"];
  }
}

class DiffusionConduitService extends ConduitService {
  DiffusionConduitService(ConduitClient client) : super(client);

  @override
  String get group => "diffusion";

  Future<List<DiffusionSymbol>> findSymbols({
    String name,
    String prefix,
    String context,
    String language,
    String type,
    String repositoryPhid
  }) async {
    var params = {};
    ConduitUtils.put({
      "name": name,
      "namePrefix": prefix,
      "context": context,
      "language": language,
      "type": type,
      "repositoryPHID": repositoryPhid
    }, params);
    var result = await callMethod("findsymbols", params);
    var out = <DiffusionSymbol>[];

    if (result is Map) {
      for (String key in result.keys) {
        var symbol = new DiffusionSymbol();
        symbol.decode(result[key]);
        out.add(symbol);
      }
    }

    return out;
  }

  DiffusionRepositoryConduitService _repository;

  DiffusionRepositoryConduitService get repository {
    if (_repository != null) {
      return _repository;
    }

    return _repository = new DiffusionRepositoryConduitService(client);
  }
}
