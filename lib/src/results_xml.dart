/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:convert';
import 'mdownloader.dart' as results_html_downloader;

///A tag that contains non-results information
class DirtyTag extends Equatable {
  final String start;
  final String end;

  @override
  List<Object> get props => [start, end];

  const DirtyTag({@required this.start, @required this.end});

  @override
  String toString() {
    return 'DirtyTag${jsonEncode(<String, dynamic>{
      'start': start,
      'end': end
    })}';
  }
}

final _commonDirtTags = <DirtyTag>{
  const DirtyTag(start: '<meta', end: '>'),
  const DirtyTag(start: '<script', end: '</script>'),
  const DirtyTag(start: '<div', end: '</div>'),
  const DirtyTag(start: '<title>', end: '</title>'),
  const DirtyTag(start: '< rel', end: '>'),
  const DirtyTag(start: '<rel', end: '>'),
  const DirtyTag(start: '<style>', end: '</style>'),
  const DirtyTag(start: '<link', end: '>'),
  const DirtyTag(start: '<!', end: '->'),
};

class RemoveTagResult {
  final int tagRemoved;
  final String html;

  const RemoveTagResult(this.tagRemoved, this.html);
}

class RemoveTagFailed implements Exception {
  final String startTag;
  final String endTag;
  String _html;

  RemoveTagFailed({@required this.startTag, @required this.endTag});

  set html(String html) => _html = html;

  get html => _html;

  @override
  String toString() {
    return 'RemoveTagFailed !, startTag: $startTag , endTag: $endTag';
  }
}

Future<RemoveTagResult> removeDirtyTag(String html, DirtyTag dirtyTag) {
  int startTagIndex = -1;
  bool error = false;
  int tagRemoved = 0;
  String sTag = dirtyTag.start;
  String eTag = dirtyTag.end;
  int nLoop = 1;
  String formattedHtml = html;
  final RemoveTagFailed exception =
      RemoveTagFailed(startTag: dirtyTag.start, endTag: dirtyTag.end);

  remove() {
    while ((startTagIndex = formattedHtml.indexOf(sTag)) != -1) {
      int endTagIndex = formattedHtml.indexOf(eTag, startTagIndex);
      if (endTagIndex == -1) {
        error = true;
        break;
      } else {
        formattedHtml = formattedHtml.replaceRange(
            startTagIndex, (endTagIndex + eTag.length), '');
        tagRemoved++;
      }
    }
  }

  remove();

  if (nLoop < 2) {
    nLoop++;
    //look for upperCase ones
    sTag = dirtyTag.start.toUpperCase();
    eTag = dirtyTag.end.toUpperCase();
    remove();
  }

  if (error) {
    exception.html = formattedHtml;
    throw exception;
  } else {
    return Future<RemoveTagResult>.value(
        RemoveTagResult(tagRemoved, formattedHtml));
  }
}

Future<String> removeDirtyTags(String html, Set<DirtyTag> tags) async {
  if (tags != null && tags.isNotEmpty) {
    var tmp = html;
    for (DirtyTag tag in tags) {
      try {
        tmp = (await removeDirtyTag(tmp, tag)).html;
      } on RemoveTagFailed catch (e) {
        tmp = e.html;
      }
    }
    return tmp;
  } else {
    return html;
  }
}

Future<String> removeAttributes(String html,
    {List<String> keepAttributes = const <String>['href']}) {
  String formatted = html;

  var completer = Completer<String>();

  bool shouldKeep(Match match) {
    if (match.groupCount >= 1) {
      var arry = match[0].split('=');
      if (arry.length == 2) {
        var attr = arry[0];
        return keepAttributes.contains(attr) ||
            keepAttributes.contains(attr.toLowerCase()) ||
            keepAttributes.contains(attr.toUpperCase());
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  removeSimpleAttributes() {
    formatted = formatted.replaceAllMapped(
        RegExp(r'(\w+=\s?\"?#?\w+%?\"?)', caseSensitive: false), (Match m) {
      return shouldKeep(m) ? m[0] : '';
    });
  }

  removeEmptyAttributes() {
    formatted = formatted.replaceAllMapped(
        RegExp(r'(\w+=\"\")', caseSensitive: false), (Match m) {
      return shouldKeep(m) ? m[0] : '';
    });
  }

  removeComplexyAttributes() {
    formatted = formatted.replaceAllMapped(
        RegExp(r'(\w+=\s?\"?.+\"?)', caseSensitive: false), (Match m) {
      return shouldKeep(m) ? m[0] : '';
    });

    completer.complete(formatted);
  }

  removeSimpleAttributes();
  removeEmptyAttributes();
  removeComplexyAttributes();

  return completer.future;
}

Future<String> removeEmptyTags(String html,
    {List<String> keepTags = const <String>[
      'a',
      'td',
      'h1',
      'h2',
      'h3',
      'table',
      'body'
    ]}) {
  String formatted = html;

  var completer = Completer<String>();

  bool shouldKeep(Match match) {
    if (match.groupCount >= 1) {
      var tag = match[0]
          .replaceAll('<', '')
          .replaceAll('>', '')
          .replaceAll('\\', '')
          .replaceAll('/', '')
          .trim();

      return keepTags.contains(tag) ||
          keepTags.contains(tag.toLowerCase()) ||
          keepTags.contains(tag.toUpperCase());
    } else {
      return false;
    }
  }

  removeStartWithEmptyTag() {
    formatted = formatted.replaceAllMapped(
        RegExp(r'(<\w+\s+>)', caseSensitive: false), (Match m) {
      return shouldKeep(m) ? m[0] : '';
    });
  }

  removeStartWithNoEmptyTag() {
    formatted = formatted
        .replaceAllMapped(RegExp(r'(<\w+>)', caseSensitive: false), (Match m) {
      return shouldKeep(m) ? m[0] : '';
    });
  }

  removeEndTag() {
    formatted = formatted
        .replaceAllMapped(RegExp(r'(</\w+>)', caseSensitive: false), (Match m) {
      return shouldKeep(m) ? m[0] : '';
    });

    completer.complete(formatted);
  }

  removeStartWithEmptyTag();
  removeStartWithNoEmptyTag();
  removeEndTag();

  return completer.future;
}

class GetResultsXmFailed implements Exception {
  String message;
  GetResultsXmFailed(this.message);

  @override
  String toString() {
    return message;
  }
}

///The xml returned is not checked by the function ,so it maybe invalid
///if you wish to keep one or more CommonDirtTags , set  removeCommonDirtTags = false
Future<String> getResultsXml(
  String url, {
  Set<DirtyTag> dirtyTags,
  List<String> keepTags = const <String>[
    'a',
    'td',
    'h1',
    'h2',
    'h3',
    'table',
    'body'
  ],
  List<String> keepAttributes = const <String>['href'],
  bool removeCommonDirtTags = true,
}) async {
  try {
    var html = await results_html_downloader.download(url);

    if ((dirtyTags != null) && removeCommonDirtTags) {
      dirtyTags.addAll(_commonDirtTags);
    }

    html = await removeDirtyTags(html,
        removeCommonDirtTags ? (dirtyTags ?? _commonDirtTags) : dirtyTags);
    html = await removeAttributes(html, keepAttributes: keepAttributes);
    html = await removeEmptyTags(html, keepTags: keepTags);
    html = _replaceTable(html);

    try {
      return xml.parse(html).toXmlString(pretty: true);
    } catch (_) {
      return html;
    }
  } on results_html_downloader.DownloadFailed catch (e) {
    throw GetResultsXmFailed('GetResultsXmFailed, ${e.toString()}');
  }
}

String _replaceTable(String html) {
  return html
      .replaceAll('TABLE BORDER ', 'TABLE')
      .replaceAll('table border', 'table');
}

Future<String> getSimplifiedMenuHtml(
  String url, {
  Set<DirtyTag> dirtyTags,
  List<String> keepTags = const <String>[],
  List<String> keepAttributes = const <String>['href'],
}) async {
  try {
    var html = await results_html_downloader.download(url);

    if (dirtyTags != null) {
      html = await removeDirtyTags(html, dirtyTags);
    }

    html = await removeAttributes(html, keepAttributes: keepAttributes);
    html = await removeEmptyTags(html, keepTags: keepTags);
    return _replaceTable(html);
  } on results_html_downloader.DownloadFailed catch (e) {
    throw GetResultsXmFailed('GetMenuXmFailed, ${e.toString()}');
  }
}
