part of phabricator.client;

class ManiphestStatus implements ConduitEncodable {
  static const ManiphestStatus ANY = const ManiphestStatus("status-any");
  static const ManiphestStatus OPEN = const ManiphestStatus("status-open");
  static const ManiphestStatus CLOSED = const ManiphestStatus("status-closed");
  static const ManiphestStatus ACTIVE = const ManiphestStatus("status-active");
  static const ManiphestStatus ARCHIVED = const ManiphestStatus("status-archived");

  static ManiphestStatus decode(String input) {
    var status = const {
      "status-any": ANY,
      "status-open": OPEN,
      "status-closed": CLOSED,
      "status-active": ACTIVE,
      "status-archived": ARCHIVED
    }[input];

    if (status == null) {
      status = new ManiphestStatus(input);
    }

    return status;
  }

  final String id;

  const ManiphestStatus(this.id);

  @override
  encode() => id;

  @override
  String toString() => "ManiphestStatus(${id})";
}

class ManiphestTask extends ConduitObject<Map<String, dynamic>> {
  int id;
  String phid;
  String authorPhid;
  String ownerPhid;
  List<String> ccPhids;
  ManiphestStatus status;
  String statusName;
  bool isClosed;
  String priority;
  String priorityColor;
  String title;
  String description;
  String uri;
  Map<String, dynamic> auxiliary;
  String objectName;
  String dateCreated;
  String dateModified;
  List<String> dependsOnTaskPhids;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;

    id = ConduitUtils.asInt(input["id"]);
    phid = input["phid"];
    authorPhid = input["authorPHID"];
    ownerPhid = input["ownerPHID"];
    ccPhids = input["ccPHIDs"];
    status = ManiphestStatus.decode(input["status"]);
    statusName = input["statusName"];
    isClosed = input["isClosed"];
    priority = input["priority"];
    priorityColor = input["priorityColor"];
    title = input["title"];
    description = input["description"];
    uri = input["uri"];
    auxiliary = input["auxiliary"];
    objectName = input["objectName"];
    dateCreated = input["dateCreated"];
    dateModified = input["dateModified"];
    dependsOnTaskPhids = input["dependsOnTaskPHIDs"];
  }
}

class ManiphestConduitService extends ConduitService {
  ManiphestConduitService(ConduitClient client) : super(client);

  @override
  String get group => "maniphest";

  Future<ManiphestTask> info(int id) async {
    var task = new ManiphestTask();
    task.decode(await callMethod("info", {
      "task_id": id
    }));
    return task;
  }

  Future<List<ManiphestTask>> query({
    List<int> ids,
    List<String> phids,
    List<String> owners,
    List<String> authors,
    List<String> projects,
    List<String> ccs,
    String fullText,
    status,
    String order,
    int limit,
    int offset
  }) async {
    var params = {};

    ConduitUtils.put({
      "ids": ids,
      "phids": phids,
      "ownerPHIDs": owners,
      "authorPHIDs": authors,
      "projectPHIDs": projects,
      "ccPHIDs": ccs,
      "fullText": fullText,
      "status": status,
      "order": order,
      "limit": limit,
      "offset": offset
    }, params);

    var data = await callMethod("query", params);

    var out = <ManiphestTask>[];

    if (data is Map) {
      for (String key in data.keys) {
        var task = new ManiphestTask();
        task.decode(data[key]);
        out.add(task);
      }
    }

    return out;
  }
}
