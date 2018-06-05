part of phabicator.client;

class ShortUrl extends ConduitObject<Map<String, dynamic>> {
  String name;
  String alias;
  String longUrl;
  String shortUrl;
  String description;
  String spacePHID;

  int dateCreated;
  int dateModified;

  Map<String, dynamic> policy;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;

    name = input["name"];
    alias = input["alias"];

    if (input["urls"] is Map) {
      longUrl = input["urls"]["long"];
      shortUrl = input["urls"]["short"];
    }

    description = input["description"];
    spacePHID = input["spacePHID"];

    dateCreated = input["dateCreated"];
    dateModified = input["dateModified"];

    policy = input["policy"];
  }
}

class PhurlConduitService extends SearchableConduitService<ShortUrl> {
  @override
  String get group => "phurls";

  PhurlConduitService(ConduitClient client) : super(client, "URL");
}
