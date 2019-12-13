/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:http/http.dart' as http;

class DownloadFailed implements Exception {
  String message;
  DownloadFailed(this.message);

  @override
  String toString() {
    return message;
  }
}

Future<String> downloadResultsHtml(String url) async {
  try {
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw DownloadFailed(
          'Failed to download results: url = $url , Error=  statusCode : ${response.statusCode}');
    }
  } catch (e) {
    throw DownloadFailed('${e.toString()}');
  }
}