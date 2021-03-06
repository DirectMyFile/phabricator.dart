part of phabricator.client;

class ConduitSearch<T extends ConduitObject> extends ConduitObject<Map<String, dynamic>> {
  int id;
  String phid;

  Map<String, dynamic> fields;
  Map<String, dynamic> attachments;

  T item;

  @override
  void decode(Map<String, dynamic> input, [T stubItem]) {
    json = input;
    id = input["id"];
    phid = input["phid"];
    fields = input["fields"];
    attachments = input["attachments"];
    item = stubItem;
  }

  dynamic getAttachment(String key) {
    var result = crawlAndApplyConduitTypes(attachments[key]);

    if (result is Map && result.length == 1 && result[key] != null) {
      result = result[key];
    }

    return result;
  }
}

abstract class SearchableConduitService<T extends ConduitObject> extends ConduitService {
  final String searchResultType;

  SearchableConduitService(ConduitClient client, this.searchResultType) : super(client);

  bool get searchUseAfterOffset => false;

  Future<ConduitCursor<ConduitSearch<T>>> search({
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
        ..decode(input, mapConduitType(searchResultType, input));
    });

    cursor.setNextCallback(() async {
      return await search(
        queryKey: queryKey,
        constraints: constraints,
        attachments: attachments,
        order: order,
        before: before,
        after: searchUseAfterOffset ? cursor.after.toString() : after,
        limit: limit,
        offset: searchUseAfterOffset ? null : cursor.after
      );
    });

    return cursor;
  }
}
