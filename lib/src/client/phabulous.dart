part of phabricator.client;

class PhabulousConduitService extends ConduitService {  
  @override
  String get group => "phabulous";

  PhabulousConduitService(ConduitClient client) : super(client);

  Future<Map<String, String>> fromSlack(List<String> accountIds) async {
    return await callMethod("fromslack", {
      "accountIDs": accountIds
    });
  }
  
  Future<Map<String, String>> toSlack(List<String> userIds) async {
    return await callMethod("toslack", {
      "UserPHIDs": userIds
    });
  }
}
