part of phabricator.client;

class ConduitMethodDescriptor extends ConduitObject<Map<String, dynamic>> {
  String method;
  String description;
  Map<String, String> params;
  String returns;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;

    description = input["description"];
    params = input["params"];
    returns = input["return"];
  }
}

class ConduitMethodQueryResult extends ConduitObject<Map<String, Map<String, dynamic>>> {
  Map<String, ConduitMethodDescriptor> methods = {};

  @override
  void decode(Map<String, Map<String, dynamic>> input) {
    json = input;

    for (var method in input.keys) {
      methods[method] = new ConduitMethodDescriptor()
        ..decode(input[method])
        ..method = method;
    }
  }

  bool hasMethod(String method) => methods.containsKey(method);

  Set<String> get methodNames => methods.keys;
  ConduitMethodDescriptor getMethod(String method) => methods[method];
}

class ConduitCapabilities extends ConduitObject<Map<String, List<String>>> {
  List<String> authentication;
  List<String> signatures;
  List<String> input;
  List<String> output;

  @override
  void decode(Map<String, List<String>> input) {
    json = input;

    authentication = input["authentication"];
    signatures = input["signatures"];
    
    this.input = input["input"];
    this.output = input["output"];
  }

  bool hasAuthenticationCapability(String capability) =>
    authentication != null && authentication.contains(capability);

  bool hasSignatureCapability(String capability) =>
    signatures != null && signatures.contains(capability);

  bool hasInputCapability(String capability) =>
    input != null && input.contains(capability);

  bool hasOutputCapability(String capability) =>
    output != null && output.contains(capability);

  bool hasCapability(String type, String capability) =>
    json.containsKey(type) && json[type].contains(capability);

  Set<String> get types => json.keys;

  List<String> getCapabilities(String type) => json.containsKey(type) ? json[type] : [];
}
