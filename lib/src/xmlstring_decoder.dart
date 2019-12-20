/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:petitparser/petitparser.dart';
import 'mdecoder.dart';

///A simple example that shows how to implement MDecoder
class XmlStringDecoder extends MDecoder<String> {
  XmlStringDecoder(Parser parser) : super(parser);

  @override
  String mapParserResult(String result) {
    return result;
  }
}
