part of phabricator.client;

typedef T ConduitTypeFactory<T, O>(O data);

final Map<String, ConduitTypeFactory> _typeFactories = <String, ConduitTypeFactory>{
  "REPO": (data) => new DiffusionRepository()..decode(data),
  "TASK": (data) => new ManiphestTask()..decode(data),
  "URL": (data) => new ShortUrl()..decode(data)
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
    return _typeFactories[type](input);
  }
  return input;
}

dynamic crawlAndApplyConduitTypes(input) {
  if (input is Map) {
    if (input["type"] is String) {
      input = mapConduitType(input["type"], input);
    }

    var out = {};
    for (var key in input.keys.toList()) {
      var value = input[key];
      out[key] = crawlAndApplyConduitTypes(value);
    }

    return input;
  } else if (input is List) {
    return input.map(crawlAndApplyConduitTypes).toList();
  } else {
    return input;
  }
}
