part of phabricator.client;

class ConduitUtils {
  static HttpClient httpClient = new HttpClient();

  static Future<dynamic> handleResponse(HttpClientResponse response, {
    String resultKey: "result"
  }) async {
    var content = await response.transform(const Utf8Decoder()).join();
    var json = const JsonDecoder().convert(content);

    String error = tryMultipleKeys(const [
      "error_code",
      "error"
    ], json);
    
    String errorMessage = tryMultipleKeys(const [
      "error_description",
      "error_info",
      "errorMessage"
    ], json);

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
      var value = input[key];

      if (value == null) {
        continue;
      }

      if (value is Uint8List) {
        value = const Base64Encoder().convert(value);
      }

      if (value is Iterable) {
        value = value.map((item) {
          if (item is ConduitEncodable) {
            return item.encode();
          } else {
            return item;
          }
        }).toList();
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

  static int asInt(input) {
    if (input == null) {
      return -1;
    }

    if (input is int) {
      return input;
    } else if (input is num) {
      return input.toInt();
    } else if (input is String) {
      try {
        return int.parse(input);
      } on FormatException {
        return -1;
      }
    }
    return -1;
  }
  
  static dynamic tryMultipleKeys(List<String> keys, Map<String, dynamic> input) {
    for (var key in keys) {
      var value = input[key];

      if (value != null) return value;
    }
    
    return null;
  }
}

abstract class ConduitEncodable {
  dynamic encode();
}

abstract class ConduitObject<T> {
  int get id {
    if (_id == null) {
      if (json != null && json is Map) {
        var possibleId = (json as Map)["id"];
        if (possibleId is int) {
          return _id = possibleId;
        }
      }
    }
    return _id;
  }

  set id(int val) {
    _id = val;
  }

  int _id;

  String get phid {
    if (_phid == null) {
      if (json != null && json is Map) {
        var possibleId = (json as Map)["phid"];
        if (possibleId is String) {
          return _phid = possibleId;
        }
      }
    }
    return _phid;
  }

  set phid(String val) {
    _phid = val;
  }
  String _phid;

  T json;
  
  void decode(T input);
}

typedef Future<ConduitCursor<T>> ConduitCursorProvider<T>();

class ConduitCursor<T> extends ListBase<T> {
  final List<T> base;

  ConduitCursorProvider<T> next;

  int offset = 0;
  int limit = 0;
  int after = 0;
  int before = 0;

  ConduitCursor(this.base);

  @override
  T operator [](int index) => base[index];
  
  @override
  operator []=(int index, T value) => base[index] = value;

  @override
  int get length => base.length;

  @override
  set length(int value) => base.length = value;

  factory ConduitCursor.create(Map<String, dynamic> input, {int offset, T convert(item)}) {
    var allData = input["data"];
    var cursor = input["cursor"];

    if (convert != null) {
      allData = allData.map((item) => convert(item)).toList();
    }

    var list = new ConduitCursor<T>(allData);

    list
      ..limit = cursor["limit"]
      ..after = cursor["after"]
      ..before = cursor["before"]
      ..offset = offset == null ? 0 : offset;
    return list;
  }

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
  
  ConduitCursor<T> setNextCallback(ConduitCursorProvider<T> handler) {
    if (after != null) {
      next = handler;
    }
    return this;
  }
}

class ConduitBlob {
  final String base64;

  ConduitBlob(this.base64);

  factory ConduitBlob.fromBytes(List<int> bytes) {
    return new ConduitBlob(const Base64Encoder().convert(bytes));
  }

  Uint8List read() {
    var bytes = const Base64Decoder().convert(base64);

    if (bytes is! Uint8List) {
      return new Uint8List.fromList(bytes);
    } else {
      return bytes;
    }
  }

  String readText() {
    return const Utf8Decoder().convert(read());
  }
}
