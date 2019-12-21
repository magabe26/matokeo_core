/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'dart:convert';
import 'package:petitparser/petitparser.dart';
import 'package:meta/meta.dart';

import 'string_to_stream.dart';

///Subclass this class to build a decoder that decode a formatted string(xml ,html etc) into dart Objects,
///It uses a parser which is responsible for the parsing.
abstract class MDecoder<T> extends Converter<String, List<T>> {
  ///A parser responsible for all decoder parsing, must not be null.
  Parser get parser;

  List<String> convertStringList({@required String input}) {
    int end = RangeError.checkValidRange(0, null, input.length);
    var xml = input.substring(0, end);
    if (parser == null) {
      return <String>[];
    } else {
      return parser.flatten().matchesSkipping(xml);
    }
  }

  ///Map each parser result to a type T Object
  T mapParserResult(String result);

  @override
  Sink<String> startChunkedConversion(Sink<List<T>> sink) =>
      _ResultsDecoderSink<List<T>>(sink, parser, this);

  @override
  List<T> convert(String input) {
    return convertStringList(input: input)
        .map((parserResult) {
          try {
            return mapParserResult(parserResult);
          } catch (_) {
            return null;
          }
        })
        .where((obj) => (obj != null)) //filter null objects
        .toList(); /* Important Note: growable parameter must be set to true, by default ,growable is set to true*/
  }

  Stream<T> decode(String input) {
    return stringToStream(input).transform(this).expand((i) => i);
  }
}

class _ResultsDecoderSink<T> extends StringConversionSinkBase {
  _ResultsDecoderSink(this.sink, this.parser, this.converter)
      : assert(sink != null),
        assert(parser != null),
        assert(converter != null);

  final Sink<T> sink;
  final Parser parser;
  final Converter converter;
  String carry = '';

  @override
  void addSlice(String str, int start, int end, bool isLast) {
    T result;

    end = RangeError.checkValidRange(start, end, str.length);
    if (start == end) {
      return;
    }

    final strToParse = carry + str.substring(start, end);
    parser.flatten().matchesSkipping(strToParse).forEach((str) {
      //call subclass's convert method, that uses convertStringList method
      //to convert to a list of type T
      T list = converter.convert(str);
      if (result == null) {
        result = list;
      } else {
        if ((list as List).isNotEmpty) {
          (result as List).add((list as List)[0]);
        }
      }
    });

    carry = str.substring(end);

    if ((result != null) && (result as List).isNotEmpty) {
      sink.add(result);
    }
    if (isLast) {
      close();
    }
  }

  @override
  void close() {
    if (carry.isNotEmpty) {
      throw Exception('MDecoder:: Unable to parse remaining input: $carry');
    }
    sink.close();
  }
}
