/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:petitparser/petitparser.dart';
import 'package:meta/meta.dart';

const _otherPermittedAttributeValueChars =
    ':./?&=%#_@-\\'; //They sometimes use \ instead of / by mistake

///Any results parser must mix with this mixin
mixin ResultsXmlParserMixin {
  Parser start() => char('<');

  Parser end() => char('>');

  Parser slash() => char('/');

  Parser spaceOptional() => whitespace().star();

  Parser quote() => char('"') | char("'");

  Parser equal() => char('=');

  Parser repeat(Parser p, int times) => repeatRange(p, min: times, max: times);

  Parser repeatRange(Parser p, {@required int min, @required int max}) =>
      spaceOptional().seq(p).seq(spaceOptional()).repeat(min, max);

  /// In the following examples
  ///    final str = '''
  ///          chura CHURA ChurA ChUrA mkia is awesome
  ///       ''';
  ///
  /// nonCaseSensitiveChars("chura").flatten().matchesSkipping(str);
  /// returns [chura CHURA ChurA ChUrA]
  Parser nonCaseSensitiveChars(String str) {
    if ((str == null) || str.isEmpty) {
      return undefined('argument "str" can not be empty or null');
    }
    Parser p;
    str.split('').forEach((c) {
      final parser = pattern('${c.toLowerCase()}${c.toUpperCase()}');
      if (p == null) {
        p = parser;
      } else {
        p = p.seq(parser);
      }
    });
    return p;
  }

  Parser attributeValue() =>
      (letter() | digit() | pattern(_otherPermittedAttributeValueChars)).star();

  Parser attributeKey([String key]) =>
      (key == null) ? word().plus() : nonCaseSensitiveChars(key);

  Parser attribute([String attr]) => (attributeKey(attr)
      .seq(equal())
      .seq(quote())
      .seq(attributeValue())
      .seq(quote()));

  /// In the following examples
  ///    final str = '''
  ///          <tag attr1 ="attribute1"> Text </tag>
  ///          <TAG> TEXT </TAG>
  ///            <tag/>
  ///       ''';
  ///  elementStartTag(tag:'tag'); matches both  <tag attr1 ="attribute1"> and  <TAG>
  ///     while
  ///  elementStartTag(tag:'tag',isClosed: true); matches only <tag/>
  Parser elementStartTag(
      {String tag, int maxNoOfAttributes = 6, bool isClosed = false}) {
    final Parser attr =
        spaceOptional().seq(attribute().star()).repeat(1, maxNoOfAttributes);

    Parser p = start()
        .seq((tag == null) ? letter().plus() : nonCaseSensitiveChars(tag))
        .seq(spaceOptional())
        .seq(attr)
        .seq(spaceOptional());

    if (isClosed) {
      p = p.seq(slash());
    }

    p = p.seq(end());

    return p;
  }

  Parser elementEndTag([String tag]) => start()
      .seq(slash())
      .seq((tag == null) ? letter().plus() : nonCaseSensitiveChars(tag))
      .seq(end());

  /// In the following examples
  ///    final str = '''
  ///          <tag attr1 ="attribute1"> Text </tag>
  ///          <TAG> TEXT </TAG>
  ///       ''';
  ///  element('tag'); matches both  <tag attr1 ="attribute1"> Text </tag>
  ///  and  <TAG> TEXT </TAG>
  Parser element(String tag, {Parser startTag, Parser endTag}) {
    return ((startTag != null) ? startTag : elementStartTag(tag: tag))
        .seq(spaceOptional())
        .seq(spaceOptional()
            .seq(any()
                .starLazy((endTag != null) ? endTag : elementEndTag(tag))
                .flatten('element: Expected any text'))
            .pick(1)
            .optional(''))
        .seq(spaceOptional())
        .seq((endTag != null) ? endTag : elementEndTag(tag));
  }

  /// In the following examples
  ///    final str = '''
  ///        <tr>  <tag attr1 ="attribute1"> Text </tag> </tr>
  ///          <TAG> TEXT </TAG>
  ///       ''';
  ///  parentElement("tr",element('tag'));
  ///  matches  <tr>  <tag attr1 ="attribute1"> Text </tag> </tr>
  Parser parentElement(String tag, Parser element,
      {Parser startTag, Parser endTag}) {
    return ((startTag != null) ? startTag : elementStartTag(tag: tag))
        .seq(spaceOptional())
        .seq(element)
        .seq(spaceOptional())
        .seq((endTag != null) ? endTag : elementEndTag(tag));
  }
}
