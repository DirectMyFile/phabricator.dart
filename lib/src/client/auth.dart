part of phabricator.client;

class AuthConduitService extends ConduitService {
  @override
  String get group => "auth";

  AuthConduitService(ConduitClient client) : super(client);

  Future<ConduitCursor<String>> getAuthorizedKeys(List<String> phids, {
    int offset,
    int limit
  }) async {
    var params = {};

    ConduitUtils.put({
      "phids": phids,
      "offset": offset,
      "limit": limit
    }, params);

    var result = await callMethod("authorizedkeys", params);
    var list = new ConduitCursor<String>.create(result);

    return list.setNextCallback(() async {
      return await getAuthorizedKeys(
        phids,
        limit: limit,
        offset: list.after
      );
    });
  }
}
