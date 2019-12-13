/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:petitparser/petitparser.dart';
import 'results_xml_decoder.dart';

class ResultsXmlToStringDecoder
    extends ResultsXmlDecoder<String, List<String>> {
  ResultsXmlToStringDecoder(Parser parser) : super(parser);

  @override
  List<String> convert(String input) {
    return convertStringList(input: input);
  }
}
