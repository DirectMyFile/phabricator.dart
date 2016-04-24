part of phabricator.client;

class ConduitUtils {
  static http.Client httpClient = new http.Client();

  static dynamic handleResponse(http.Response response, {
    String resultKey: "result",
    String errorKey: "error",
    String errorMessageKey: "errorMessage"
  }) {
    var json = JSON.decode(response.body);

    String error = json[errorKey];
    String errorMessage = json[errorMessageKey];

    if (error != null || errorMessage != null) {
      throw new ConduitException(error, errorMessage);
    }

    return json[resultKey];
  }

  static void closeHttpClient() {
    httpClient.close();
  }

  static void put(Map input, Map target) {
    for (var key in input.keys) {
      var value = target[key];

      if (value == null) {
        continue;
      }

      if (value is Iterable && value is! List) {
        value = value.toList();
      }

      if (value is List && value.isEmpty) {
        continue;
      }

      if (value is ConduitEncodable) {
        value = value.encode();
      }

      target[key] = value;
    }
  }
}

abstract class ConduitEncodable {
  dynamic encode();
}

abstract class ConduitObject<T> {
  T json;
  void decode(T input);
}

typedef Future<ConduitCursor<T>> ConduitCursorProvider<T>();

class ConduitCursor<T> extends DelegatingList<T> {
  ConduitCursorProvider<T> next;

  int offset = 0;
  int limit = 0;
  int after = 0;
  int before = 0;

  ConduitCursor(List<T> base) : super(base);

  Future<ConduitCursor<T>> fetchNext() async {
    if (next != null) {
      return await next();
    } else {
      return null;
    }
  }

  Future<List<T>> fetchAll() async {
    var out = <T>[];

    var cursor = this;
    while (cursor != null) {
      out.addAll(cursor);
      cursor = await cursor.fetchNext();
    }

    return out;
  }
}

class ConduitBlob {
  final String base64;

  ConduitBlob(this.base64);

  factory ConduitBlob.fromBytes(List<int> bytes) {
    return new ConduitBlob(BASE64.encode(bytes));
  }

  Uint8List read() {
    var bytes = BASE64.decode(base64);

    if (bytes is! Uint8List) {
      return new Uint8List.fromList(bytes);
    } else {
      return bytes;
    }
  }
}
