part of phabricator.client;

class GenericAlmanacObject extends ConduitObject<Map<String, dynamic>> {
  String name;

  int dateCreated;
  int dateModified;

  DateTime get dateCreatedTimestamp =>
      dateCreated == null ? null :
      new DateTime.fromMillisecondsSinceEpoch(dateCreated * 1000);

  DateTime get dateModifiedTimestamp =>
      dateModified == null ? null :
      new DateTime.fromMillisecondsSinceEpoch(dateModified * 1000);

  Map<String, dynamic> policy;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;

    id = input["id"];
    phid = input["phid"];

    name = input["name"];
    dateCreated = input["dateCreated"];
    dateModified = input["dateModified"];
    policy = input["policy"];
  }
}

class AlmanacDevice extends GenericAlmanacObject {
}

class AlmanacNetwork extends GenericAlmanacObject {
}

class AlmanacInterface extends GenericAlmanacObject {
  String devicePHID;
  String networkPHID;

  String address;
  int port;

  @override
  void decode(Map<String, dynamic> input) {
    super.decode(input);

    address = input["address"];
    port = input["port"];

    devicePHID = input["devicePHID"];
    networkPHID = input["networkPHID"];
  }
}

class AlmanacProjectsAddTransaction extends ConduitTransaction<List<String>> {
  final List<String> value;

  AlmanacProjectsAddTransaction(this.value);

  @override
  String get type => "projects.add";
}

class AlmanacProjectsRemoveTransaction extends ConduitTransaction<List<String>> {
  final List<String> value;

  AlmanacProjectsRemoveTransaction(this.value);

  @override
  String get type => "projects.remove";
}

class AlmanacProjectsSetTransaction extends ConduitTransaction<List<String>> {
  final List<String> value;

  AlmanacProjectsSetTransaction(this.value);

  @override
  String get type => "projects.set";
}

class AlmanacPropertySetTransaction extends ConduitTransaction<Map<String, String>> {
  final Map<String, String> value;

  AlmanacPropertySetTransaction(this.value);

  @override
  String get type => "property.set";
}

class AlmanacPropertyDeleteTransaction extends ConduitTransaction<List<String>> {
  final List<String> value;

  AlmanacPropertyDeleteTransaction(this.value);

  @override
  String get type => "property.delete";
}

class AlmanacDeviceService extends EditableConduitService<AlmanacDevice> {
  AlmanacDeviceService(ConduitClient client) : super(client, "ADEV");

  @override
  String get group => "almanac.device";
}

class AlmanacAddressTransaction extends ConduitTransaction<String> {
  final String value;

  AlmanacAddressTransaction(this.value);

  @override
  String get type => "address";
}

class AlmanacDeviceTransaction extends ConduitTransaction<String> {
  final String value;

  AlmanacDeviceTransaction(this.value);

  @override
  String get type => "device";
}

class AlmanacNetworkTransaction extends ConduitTransaction<String> {
  final String value;

  AlmanacNetworkTransaction(this.value);

  @override
  String get type => "network";
}

class AlmanacPortTransaction extends ConduitTransaction<int> {
  final int value;

  AlmanacPortTransaction(this.value);

  @override
  String get type => "port";
}

class AlmanacInterfaceService extends EditableConduitService<AlmanacInterface> {
  AlmanacInterfaceService(ConduitClient client) : super(client, "AINT");

  @override
  String get group => "almanac.interface";
}

class AlmanacNetworkService extends EditableConduitService<AlmanacNetwork> {
  AlmanacNetworkService(ConduitClient client) : super(client, "ANET");

  @override
  String get group => "almanac.network";
}

class AlmanacService extends ConduitService {
  AlmanacService(ConduitClient client) : super(client);

  @override
  String get group => "almanac";

  AlmanacDeviceService _device;

  AlmanacDeviceService get device =>
      _device == null ?
      _device = new AlmanacDeviceService(client) :
      _device;

  AlmanacInterfaceService _interface;

  AlmanacInterfaceService get interface =>
      _interface == null ?
      _interface = new AlmanacInterfaceService(client) :
      _interface;

  AlmanacNetworkService _network;

  AlmanacNetworkService get network =>
      _network == null ?
      _network = new AlmanacNetworkService(client) :
      _network;
}
