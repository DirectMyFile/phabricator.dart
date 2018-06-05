part of phabricator.client;

class OAuthUtils {
  static Future<String> obtainAccessToken(
    String phabricatorUrl,
    String redirectUri,
    String clientId,
    String clientSecret,
    String code) async {
    var uri = Uri.parse(phabricatorUrl);
    uri = uri.resolve("/oauthserver/token/");
    uri = uri.replace(queryParameters: {
      "client_id": clientId,
      "client_secret": clientSecret,
      "code": code,
      "grant_type": "authorization_code",
      "redirect_uri": redirectUri
    });

    http.Response response = await ConduitUtils.httpClient.get(uri);

    return ConduitUtils.handleResponse(
      response,
      resultKey: "access_token"
    );
  }
}
