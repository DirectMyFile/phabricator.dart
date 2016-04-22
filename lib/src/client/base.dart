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
