part of phabricator.client;

typedef T ConduitTypeFactory<T, O>(O data);

final Map<String, ConduitTypeFactory> _typeFactories = <String, ConduitTypeFactory>{
  "REPO": (data) => new DiffusionRepository()..decode(data),
  "TASK": (data) => new ManiphestTask()..decode(data),
  "URL": (data) => new ShortUrl()..decode(data),
  "USER": (data) => new User()..decode(data),
  "PROJECT": (data) => new Project()..decode(data)
};

void registerConduitType(String type, ConduitTypeFactory typeFactory) {
  _typeFactories[type] = typeFactory;
}

void unregisterConduitType(String type) {
  _typeFactories.remove(type);
}

bool hasConduitType(String type) {
  return _typeFactories.containsKey(type);
}

dynamic mapConduitType(String type, dynamic input) {
  if (hasConduitType(type)) {
    var fields = input;
    if (fields["fields"] is Map) {
      fields = fields["fields"];
    }
    var result = _typeFactories[type](fields);

    if (result is ConduitObject) {
      if (result.id == null) {
        result.id = input["id"];
      }

      if (result.phid == null) {
        result.phid = input["phid"];
      }
    }

    return result;
  }
  return input;
}

dynamic crawlAndApplyConduitTypes(input) {
  if (input is Map) {
    var map = input;
    if (input["type"] is String) {
      input = mapConduitType(input["type"], map);
    }

    if (input is Map) {
      var out = {};
      for (var key in input.keys.toList()) {
        var value = input[key];
        out[key] = crawlAndApplyConduitTypes(value);
      }
    }

    if (input is ConduitObject) {
      if (input.id is! int) {
        input.id = map["id"];
      }

      if (input.phid is! String) {
        input.phid = map["phid"];
      }
    }

    return input;
  } else if (input is List) {
    return input.map(crawlAndApplyConduitTypes).toList();
  } else {
    return input;
  }
}
