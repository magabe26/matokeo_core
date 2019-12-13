/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:matokeo_core/matokeo_core.dart';
import 'package:petitparser/petitparser.dart';

const links = [
  'http://localhost/primary/2017/psle/results/psle.htm',
  'http://localhost/primary/2017/psle/results/shl_ps1907062.htm',
  'http://localhost/primary/2017/psle/results/distr_1907.htm',
  'http://localhost/primary/2017/psle/results/reg_19.htm'
];

///assuming the tags for inner and upper are in the same case( uppercase or lowercase)
class ResultsParsers with ResultsXmlParserMixin {
  ///The parsed td element
  ///
  ///   <td>
  ///      <a href="https://www.necta.go.tz/results/2017/psle/results/reg_27.htm">SIMIYU</a>
  ///   </td>
  ///
  Parser tdLinkParser() => outerElement('td', innerElement('a'));
}

final resultsParser = ResultsParsers();

void run_results_xml_to_string_decoder_example() async {
  try {
    var xml = await getResultsXml(links[0], keepTags: const <String>[
      'a',
      'td',
      'h1',
      'h2',
      'h3',
      'table',
      'body',
      'tr'
    ]);

    xmlToStream(xml)
        .transform(ResultsXmlToStringDecoder(resultsParser.tdLinkParser()))
        .expand((events) => events)
        .listen((String str) {
      print('Result Str -----> $str \n\n');
    });
  } on GetResultsXmFailed catch (e) {
    print(e);
  } catch (e) {
    print(e);
  }
}

main() {
  run_results_xml_to_string_decoder_example();
}
