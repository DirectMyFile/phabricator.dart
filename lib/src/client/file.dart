part of phabricator.client;

class FileConduitService extends ConduitService {
  FileConduitService(ConduitClient client) : super(client);

  @override
  String get group => "file";

  Future<ConduitBlob> download(String phid) async {
    return new ConduitBlob(await callMethod("download", {
      "phid": phid
    }));
  }

  Future<String> upload(data, {
    String name,
    String viewPolicy,
    bool allowCDN
  }) async {
    Uint8List bytes;

    if (data is Uint8List) {
      bytes = data;
    } else if (data is ByteBuffer) {
      bytes = data.asUint8List();
    } else if (data is TypedData) {
      bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes
      );
    } else if (data is List<int>) {
      bytes = new Uint8List.fromList(data);
    } else if (data is String) {
      var result = UTF8.encode(data);
      if (result is! Uint8List) {
        result = new Uint8List.fromList(result);
      }
      bytes = result;
    }

    var params = {};

    ConduitUtils.put({
      "data_base64": bytes,
      "name": name,
      "viewPolicy": viewPolicy,
      "canCDN": allowCDN
    }, params);

    return await callMethod("upload", params);
  }
}
