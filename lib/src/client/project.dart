part of phabricator.client;

class ProjectStatus implements ConduitEncodable {
  static const ProjectStatus ANY = const ProjectStatus("status-any");
  static const ProjectStatus OPEN = const ProjectStatus("status-open");
  static const ProjectStatus CLOSED = const ProjectStatus("status-closed");
  static const ProjectStatus ACTIVE = const ProjectStatus("status-active");
  static const ProjectStatus ARCHIVED = const ProjectStatus("status-archived");

  static ProjectStatus decode(String input) {
    var status = const {
      "status-any": ANY,
      "status-open": OPEN,
      "status-closed": CLOSED,
      "status-active": ACTIVE,
      "status-archived": ARCHIVED
    }[input];

    if (status == null) {
      status = new ProjectStatus(input);
    }

    return status;
  }

  final String id;

  const ProjectStatus(this.id);

  @override
  encode() => id;
}

class ProjectConduitService extends SearchableConduitService<Project> {
  ProjectConduitService(ConduitClient client) : super(client, "PROJECT");

  @override
  String get group => "project";

  Future<ConduitCursor<Project>> query({
    List<int> ids,
    List<String> names,
    List<String> phids,
    List<String> slugs,
    List<String> icons,
    List<String> colors,
    List<String> members,
    int limit,
    int offset
  }) async {
    var params = {};

    ConduitUtils.put({
      "ids": ids,
      "names": names,
      "phids": phids,
      "slugs": slugs,
      "icons": icons,
      "colors": colors,
      "members": members,
      "limit": limit,
      "offset": offset
    }, params);

    var result = await callMethod("query", params);
    var data = result["data"];
    var cursor = result["cursor"];

    var out = <Project>[];

    if (data is Map) {
      for (String key in data.keys) {
        var project = new Project();
        project.decode(data[key]);
        out.add(project);
      }
    }

    var list = new ConduitCursor<Project>(out);

    list
      ..limit = cursor["limit"]
      ..after = cursor["after"]
      ..before = cursor["before"]
      ..offset = offset == null ? 0 : offset;

    list.next = () async {
      if (list.after != null) {
        return await query(
          ids: ids,
          names: names,
          phids: phids,
          slugs: slugs,
          icons: icons,
          colors: colors,
          members: members,
          limit: limit,
          offset: list.after
        );
      }
    };

    return list;
  }
}

class Project extends ConduitObject<Map<String, dynamic>> {
  ProjectStatus status;
  String name;
  String profileImagePhid;
  String icon;
  String color;
  List<String> members;
  List<String> slugs;

  String dateCreated;
  String dateModified;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;

    id = ConduitUtils.asInt(json["id"]);
    status = ProjectStatus.decode(json["status"]);
    phid = json["phid"];
    name = json["name"];
    profileImagePhid = json["profileImagePHID"];
    icon = json["icon"];
    color = json["color"];
    members = json["members"];
    slugs = json["slugs"];
    dateCreated = json["dateCreated"];
    dateModified = json["dateModified"];
  }

  @override
  String toString() => "Project(name: ${name}, phid: ${phid})";
}
