/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:simple_smart_scraper/simple_smart_scraper.dart';
import 'package:petitparser/petitparser.dart';

const links = [
  'http://localhost/primary/2017/psle/results/psle.htm',
  'http://localhost/primary/2017/psle/results/shl_ps1907062.htm',
  'http://localhost/primary/2017/psle/results/distr_1907.htm',
  'http://localhost/primary/2017/psle/results/reg_19.htm'
];

class XmlStringDecoder extends Decoder<String> {
  ///The parsed td element
  ///
  ///   <td>
  ///      <a href="https://www.necta.go.tz/results/2017/psle/results/reg_27.htm">SIMIYU</a>
  ///   </td>
  ///
  @override
  Parser get parser => parentElement('td', element('a'));

  @override
  String mapParserResult(String result) {
    return result;
  }
}

void run_results_xml_to_string_decoder_example() async {
  try {
    var xml = await getCleanedHtml(links[0], keepTags: const <String>[
      'a',
      'td',
      'h1',
      'h2',
      'h3',
      'table',
      'body',
      'tr'
    ]);

    XmlStringDecoder().decode(xml).listen((String str) {
      print('Result Str -> $str \n\n');
    });
  } on GetCleanedHtmlFailed catch (e) {
    print(e);
  } catch (e) {
    print(e);
  }
}

main() {
  run_results_xml_to_string_decoder_example();
}
