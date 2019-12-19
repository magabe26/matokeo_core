/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:petitparser/petitparser.dart';

const _otherPermittedAttributeValueChars = ':./?&=%#_@-\\';

///Any results parser must mix with this mixin
mixin ResultsXmlParserMixin {
  Parser start() => char('<');

  Parser end() => char('>');

  Parser slash() => char('/');

  Parser spaceOrNot() => whitespace().star();

  Parser quote() => char('"') | char("'");

  Parser equal() => char('=');

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
        spaceOrNot().seq(attribute().star()).repeat(1, maxNoOfAttributes);

    Parser p = start()
        .seq((tag == null) ? letter().plus() : nonCaseSensitiveChars(tag))
        .seq(spaceOrNot())
        .seq(attr)
        .seq(spaceOrNot());

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
  ///  innerElement('tag'); matches both  <tag attr1 ="attribute1"> Text </tag>
  ///  and  <TAG> TEXT </TAG>
  Parser innerElement(String tag, {Parser startTag, Parser endTag}) {
    return ((startTag != null) ? startTag : elementStartTag(tag: tag))
        .seq(spaceOrNot())
        .seq(spaceOrNot()
            .seq(any()
                .starLazy((endTag != null) ? endTag : elementEndTag(tag))
                .flatten('innerElement: Expected any text'))
            .pick(1)
            .optional(''))
        .seq(spaceOrNot())
        .seq((endTag != null) ? endTag : elementEndTag(tag));
  }

  /// In the following examples
  ///    final str = '''
  ///        <tr>  <tag attr1 ="attribute1"> Text </tag> </tr>
  ///          <TAG> TEXT </TAG>
  ///       ''';
  ///  outerElement("tr",innerElement('tag'));
  ///  matches  <tr>  <tag attr1 ="attribute1"> Text </tag> </tr>
  Parser outerElement(String tag, Parser innerElement,
      {Parser startTag, Parser endTag}) {
    return ((startTag != null) ? startTag : elementStartTag(tag: tag))
        .seq(spaceOrNot())
        .seq(innerElement)
        .seq(spaceOrNot())
        .seq((endTag != null) ? endTag : elementEndTag(tag));
  }
}
