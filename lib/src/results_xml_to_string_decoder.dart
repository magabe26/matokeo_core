/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:petitparser/petitparser.dart';
import 'results_xml_decoder.dart';

///A simple example that shows how to implement ResultsXmlDecoder
class ResultsXmlToStringDecoder extends ResultsXmlDecoder<String> {
  ResultsXmlToStringDecoder(Parser parser) : super(parser);

  @override
  String mapParserResult(String result) {
    return result;
  }
}
