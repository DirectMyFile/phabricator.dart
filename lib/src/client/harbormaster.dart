part of phabricator.client;

class HarbormasterConduitService extends ConduitService {
  HarbormasterConduitService(ConduitClient client) : super(client);

  @override
  String get group => "harbormaster";

  Future<dynamic> createArtifact(
    String buildTarget,
    String artifactKey,
    String artifactType,
    Map<String, dynamic> artifactData) async {
    var params = {};

    ConduitUtils.put({
      "buildTarget": buildTarget,
      "artifactKey": artifactKey,
      "artifactType": artifactType,
      "artifactData": artifactData
    }, params);

    return await callMethod("createartifact", params);
  }
}
