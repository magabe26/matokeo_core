/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:simple_smart_scraper/simple_smart_scraper.dart';
import 'package:simple_smart_scraper/petitparser_2.4.0.dart';

const links = [
  'http://localhost/primary/2017/psle/results/psle.htm',
  'http://localhost/primary/2017/psle/results/shl_ps1907062.htm',
  'http://localhost/primary/2017/psle/results/distr_1907.htm',
  'http://localhost/primary/2017/psle/results/reg_19.htm'
];
enum DecoderOutputType { regionName, url }

class XmlStringDecoder extends Decoder<String> {
  DecoderOutputType decoderOutputType;

  ///The parsed td element
  ///
  ///   <td>
  ///      <a href="https://www.necta.go.tz/results/2017/psle/results/reg_27.htm">SIMIYU</a>
  ///   </td>
  ///
  @override
  Parser get parser => parentElement('td', element('a'));

  @override
  Stream<String> decode(String input, {DecoderOutputType to}) {
    decoderOutputType = to;
    return super.decode(input);
  }

  @override
  String mapParserResult(String result) {
    switch (decoderOutputType) {
      case DecoderOutputType.regionName:
        return getRegionName(result);

      case DecoderOutputType.url:
        return getUrl(result);

      default:
        return result;
    }
  }

  String getRegionName(input) => getElementText(tag: 'a', input: input);

  String aTag(input) => getParserResult(parser: element('a'), input: input);

  String getUrl(input) =>
      getAttributeValue(tag: 'a', attribute: 'href', input: aTag(input));
}

final _decoder = XmlStringDecoder();

void run_get_region_name_decoder_example() async {
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

    _decoder.decode(xml, to: DecoderOutputType.regionName).listen((String str) {
      print('---> $str \n\n');
    });
  } on GetCleanedHtmlFailed catch (e) {
    print(e);
  } catch (e) {
    print(e);
  }
}

void run_get_url_decoder_example() async {
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

    _decoder.decode(xml, to: DecoderOutputType.url).listen((String str) {
      print('---> $str \n\n');
    });
  } on GetCleanedHtmlFailed catch (e) {
    print(e);
  } catch (e) {
    print(e);
  }
}

main() {
  run_get_region_name_decoder_example();
  run_get_url_decoder_example();
}
