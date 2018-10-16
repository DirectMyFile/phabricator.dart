part of phabricator.client;

class PhabricatorFile extends ConduitObject<Map<String, dynamic>> {
  String name;
  String dataUrl;
  int size;

  int dateCreated;
  int dateModified;

  Map<String, dynamic> policy;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;

    name = input["name"];
    dataUrl = input["dataURI"];
    size = input["size"];

    dateCreated = input["dateCreated"];
    dateModified = input["dateModified"];

    policy = input["policy"];
  }
}

class FileAllocation extends ConduitObject<Map<String, dynamic>> {
  bool upload;
  String error;

  @override
  void decode(Map<String, dynamic> input) {
    json = input;
    phid = input["filePHID"];
    upload = input["upload"];
    error = input["error"];
  }
}

class FileConduitService extends SearchableConduitService {
  FileConduitService(ConduitClient client) : super(client, "FILE");

  @override
  String get group => "file";

  @override
  bool get searchUseAfterOffset => true;

  Future<ConduitBlob> download(String phid) async {
    return new ConduitBlob(await callMethod("download", {
      "phid": phid
    }));
  }

  Future<FileAllocation> allocate(String name, int contentLength, {
    String contentHash,
    String viewPolicy,
    int deleteAfterEpoch
  }) async {
    var params = {};
    ConduitUtils.put({
      "name": name,
      "contentLength": contentLength,
      "contentHash": contentHash,
      "viewPolicy": viewPolicy,
      "deleteAfterEpoch": deleteAfterEpoch
    }, params);
    var result = await callMethod("allocate", params);
    return new FileAllocation()..decode(result);
  }

  Future uploadChunk(String phid, int byteStart, data) async {
    var params = {};

    ConduitUtils.put({
      "filePHID": phid,
      "byteStart": byteStart,
      "data": _toBytes(data),
      "dataEncoding": "base64"
    }, params);

    await callMethod("uploadchunk", params);
  }

  Future<String> upload(data, {
    String name,
    String viewPolicy,
    bool allowCDN
  }) async {
    var params = {};

    ConduitUtils.put({
      "data_base64": _toBytes(data),
      "name": name,
      "viewPolicy": viewPolicy,
      "canCDN": allowCDN
    }, params);

    return await callMethod("upload", params);
  }

  Uint8List _toBytes(data) {
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

    return bytes;
  }
}
