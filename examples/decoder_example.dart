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
class ResultsParsers with MParserMixin {
  ///The parsed td element
  ///
  ///   <td>
  ///      <a href="https://www.necta.go.tz/results/2017/psle/results/reg_27.htm">SIMIYU</a>
  ///   </td>
  ///
  Parser tdLinkParser() => parentElement('td', element('a'));
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

    ResultsXmlToStringDecoder(resultsParser.tdLinkParser())
        .decode(xml)
        .listen((String str) {
      print('Result Str -> $str \n\n');
    });
  } on GetResultsXmFailed catch (e) {
    print(e);
  } catch (e) {
    print(e);
  }
}

class P with MParserMixin {
  Parser myParser() => parentElement('td', element('a')).flatten();
  Parser myParser1() => parentElement('div', repeat(myParser(), 6)).flatten();
}

main() {
  //run_results_xml_to_string_decoder_example();

  var txt = ''' 
  <div>
  
  <td>  <a href="link1"> </a> </td>
  
  <td><a href="link2"> </a></td>
  
  <td><a href="link3"> </a></td>
  
  <td><a href="link4"> </a></td>
  <td><a href="link4"> </a></td><td><a href="link4"> </a></td>
  </div>
  ''';

  print(P().myParser1().matchesSkipping(txt));
}
