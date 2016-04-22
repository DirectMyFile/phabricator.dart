part of phabricator.client;

class ConduitException {
  final String errorCode;
  final String errorInfo;

  ConduitException(this.errorCode, this.errorInfo);

  @override
  String toString() =>
    "Conduit Exception - (Error Code: ${errorCode}): ${errorInfo}";
}
