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
}
