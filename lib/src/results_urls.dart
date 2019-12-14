typedef String BaseUrlFinalizer(String baseUrl);

class ResultsUrls {
  static String getBaseUrl(String url, {BaseUrlFinalizer baseUrlFinalizer}) {
    String bUrl;
    String protocolStr;

    String tmpUrl = url.trim();
    final bool t1 = tmpUrl.contains("https://");
    final bool t2 = tmpUrl.contains("HTTPS://");
    if (t1 || t2) {
      protocolStr = "https://";
      if (t1) {
        tmpUrl = tmpUrl.replaceFirst("https://", '');
      } else {
        tmpUrl = tmpUrl.replaceFirst("HTTPS://", '');
      }
    } else {
      protocolStr = "http://";
      tmpUrl = tmpUrl.replaceFirst("http://", '');
      tmpUrl = tmpUrl.replaceFirst("HTTP://", '');
    }

    var list = tmpUrl.split("/");
    if (list.isEmpty) {
      return '';
    }
    list.removeLast();
    bUrl = list.join("/");
    if (baseUrlFinalizer != null) {
      return baseUrlFinalizer('$protocolStr$bUrl/');
    } else {
      return '$protocolStr$bUrl/';
    }
  }

  static String getResultsPath(String url) {
    //some paths contain \ ,so stupid ,those who built the necta site
    var list = url.replaceAll('\\', '/').split("/");
    if (list.isNotEmpty) {
      return list[list.length - 1];
    } else {
      return '';
    }
  }

  static String getFullUrl(String baseUrl, String pathOrFilename) {
    String bUrl = baseUrl;
    return '$bUrl${getResultsPath(pathOrFilename)}';
  }
}
