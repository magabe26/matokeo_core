/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:petitparser/petitparser.dart';

///Any results parser must mix with this mixin
mixin ResultsXmlParserMixin {
  static const otherAttributeChars = [
    ':',
    '.',
    '/',
    '?',
    '&',
    '=',
    '%',
    '#',
    '_',
    '@',
    '-',
    '\\'
  ];

  Parser start() => char('<');

  Parser end() => char('>');

  Parser slash() => char('/');

  Parser space() => whitespace();

  Parser spaceOrNot() => whitespace().star();

  Parser quote() => char('"') | char("'");

  Parser equal() => char('=');

  Parser attributeValue() =>
      (letter() | digit() | pattern(otherAttributeChars.join())).star();

  Parser attributeKey([String key]) =>
      (key == null) ? word().plus() : string(key);

  Parser attribute([String attr]) => (attributeKey(attr)
      .seq(equal())
      .seq(quote())
      .seq(attributeValue())
      .seq(quote()));

  Parser elementStartTag(
      {String tag, int maxNoOfAttributes = 6, bool isClosed = false}) {
    Parser attr;

    for (int i = 0; i < maxNoOfAttributes; ++i) {
      Parser p = attribute().star();
      if (attr == null) {
        attr = p;
      } else {
        attr = attr.seq(spaceOrNot()).seq(p);
      }
    }

    Parser p = start()
        .seq((tag == null) ? letter().plus() : string(tag))
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
      .seq((tag == null) ? letter().plus() : string(tag))
      .seq(end());

  Parser innerElement(String tag,
          {Parser startTagElement, Parser endTagElement}) =>
      ((startTagElement != null) ? startTagElement : elementStartTag(tag: tag))
          .seq(spaceOrNot())
          .seq(any()
              .starLazy(elementEndTag(tag))
              .flatten('innerElement: Expected any text'))
          .seq(spaceOrNot())
          .seq((endTagElement != null) ? endTagElement : elementEndTag(tag));

  Parser outerElement(String tag, Parser innerElement,
      {Parser startTagElement, Parser endTagElement}) {
    return ((startTagElement != null)
            ? startTagElement
            : elementStartTag(tag: tag))
        .seq(spaceOrNot())
        .seq(innerElement)
        .seq(spaceOrNot())
        .seq((endTagElement != null) ? endTagElement : elementEndTag(tag));
  }
}
