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

class DiffusionRepositoryConduitService extends ConduitService {  
  @override
  String get group => "diffusion.repository";

  DiffusionRepositoryConduitService(ConduitClient client) : super(client);

  Future<ConduitCursor<ConduitSearch<DiffusionRepository>>> search({
    String queryKey,
    Map<String, dynamic> constraints,
    Map<String, bool> attachments,
    String order,
    String before,
    String after,
    int limit,
    int offset
  }) async {
    var params = {};

    ConduitUtils.put({
      "queryKey": queryKey,
      "constraints": constraints,
      "attachments": attachments,
      "order": order,
      "before": before,
      "after": after,
      "limit": limit,
      "offset": offset
    }, params);

    var result = await callMethod("search", params);
    var cursor = new ConduitCursor.create(result, convert: (input) {
      return new ConduitSearch()
        ..decode(input, new DiffusionRepository());
    });

    cursor.setNextCallback(() async {
      return await search(
        queryKey: queryKey,
        constraints: constraints,
        attachments: attachments,
        order: order,
        before: before,
        after: after,
        limit: limit,
        offset: cursor.after
      );
    });

    return cursor;
  }
}
