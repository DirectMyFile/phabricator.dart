part of phabricator.client;

class DiffusionRepository extends ConduitObject<Map<String, dynamic>> {
  String name;
  String vcs;
  String callsign;
  String shortName;
  String status;

  bool isImporting;
  String spacePHID;

  int dateCreated;
  int dateModified;

  Map<String, dynamic> policy;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;

    id = input["id"];
    phid = input["phid"];

    name = input["name"];
    vcs = input["vcs"];
    callsign = input["callsign"];
    shortName = input["shortName"];
    status = input["status"];
    isImporting = input["isImporting"];
    spacePHID = input["spacePHID"];
    dateCreated = input["dateCreated"];
    dateModified = input["dateModified"];
    policy = input["policy"];
  }
}

class DiffusionRepositoryConduitService extends
  SearchableConduitService<DiffusionRepository> {
  @override
  String get group => "diffusion.repository";

  DiffusionRepositoryConduitService(ConduitClient client) : super(client, "REPO");
}
