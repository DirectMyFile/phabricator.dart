part of phabricator.client;

class MacroConduitService extends ConduitService {
  @override
  String get group => "macro";

  MacroConduitService(ConduitClient client) : super(client);

  Future<String> createMeme(String macroName, {
    String upperText,
    String lowerText
  }) async {
    return (await callMethod("creatememe", {
      "macroName": macroName,
      "upperText": upperText,
      "lowerText": lowerText
    }))["uri"];
  }
}
