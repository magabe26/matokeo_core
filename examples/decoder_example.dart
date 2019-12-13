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
  Parser tdLinkParser() => (outerElement('td', innerElement('a')) |
      outerElement('TD', innerElement('A')));
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

run_parsers_test() {
  // print('\\'.runes);
  String _nameStartChars = ':A-Z_a-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF'
      '\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001'
      '\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD';
  String _nameChars = '-.0-9\u00B7\u0300-\u036F\u203F-\u2040$_nameStartChars';
  // print(['a','b'].join());
  //print(pattern('a-c').matchesSkipping('churabxX\\/'));

  print(nonCaseSensitiveChars('chura')
      .flatten()
      .parse('chura CHURA ChuRaa mkia churrA'));

  print(string('CHUR')
      .flatten()
      .matchesSkipping('chura CHURA ChuRaa mkia churrA'));
}
main() {
  //run_results_xml_to_string_decoder_example();
  run_parsers_test();
}
