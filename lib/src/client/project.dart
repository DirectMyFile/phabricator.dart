part of phabricator.client;

class ProjectStatus implements ConduitEncodable {
  static const ProjectStatus ANY = const ProjectStatus("status-any");
  static const ProjectStatus OPEN = const ProjectStatus("status-open");
  static const ProjectStatus CLOSED = const ProjectStatus("status-closed");
  static const ProjectStatus ACTIVE = const ProjectStatus("status-active");
  static const ProjectStatus ARCHIVED = const ProjectStatus("status-archived");

  final String id;

  const ProjectStatus(this.id);

  @override
  encode() => id;
}

class ProjectConduitService extends ConduitService {
  ProjectConduitService(ConduitClient client) : super(client);

  @override
  String get group => "project";

  Future<Map<String, Project>> query({
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
    var out = {};

    if (result is Map) {
      for (String key in result.keys) {
        var project = new Project();
        project.decode(result[key]);
        out[key] = project;
      }
    }

    return out;
  }
}

class Project extends ConduitObject<Map<String, dynamic>> {
  String id;
  String phid;
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

    id = json["id"];
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
}
