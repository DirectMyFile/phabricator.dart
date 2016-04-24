part of phabricator.client;

class ConpherenceConduitService extends ConduitService {
  ConpherenceConduitService(ConduitClient client) : super(client);

  @override
  String get group => "conpherence";

  Future<bool> updateThread({
    int id,
    String phid,
    String title,
    String message,
    List<String> addParticipantPhids,
    String removeParticipantPhid
  }) async {
    var params = {};

    ConduitUtils.put({
      "id": id,
      "phid": phid,
      "title": title,
      "message": message,
      "addParticipantPHIDs": addParticipantPhids,
      "removeParticipantPHID": removeParticipantPhid
    }, params);

    return (await callMethod("updatethread", params)) == 1;
  }
}
