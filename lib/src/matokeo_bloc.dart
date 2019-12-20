/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import '../matokeo_core.dart';
import 'package:meta/meta.dart';
import 'dart:async';

typedef void OnDone();
typedef void DecoderListener<T>(T entity);

class MatokeoBlocException implements Exception {
  final String message;

  MatokeoBlocException(this.message);

  @override
  String toString() {
    return message;
  }
}

abstract class MatokeoBloc<E, S> extends MBloc<E, S> {
  Completer<void> _completer;
  StreamSubscription _subscription;
  Stream _stream;

  Future<void> unsubscribe() async {
    if ((_subscription != null) && (_stream != null)) {
      try {
        await _subscription.cancel();
        print('----------------unsubscribe---------');
      } catch (_) {}
    }
  }

  Future<void> load(String xml, {String baseUrl}) async {
    if (xml == null || xml.isEmpty) {
      throw MatokeoBlocException('xml is null or empty');
    }

    if ((_completer != null) && (!_completer.isCompleted)) {
      return; //avoid data corruption
    }

    _completer = Completer();

    //unsubscribe previous stream
    await unsubscribe();

    try {
      eventsDispatcher(xml, baseUrl: baseUrl);
    } catch (e) {
      throw MatokeoBlocException(e.toString());
    }
  }

  void eventsDispatcher(String xml, {String baseUrl});

  void decode<T>({
    @required String xml,
    @required ResultsXmlDecoder<T> decoder,
    @required DecoderListener<T> listener,
    @required OnDone onDone,
  }) {
    _stream = decoder.decode(xml);
    _subscription = _stream.listen(listener, onDone: onDone);
  }

  /// A subclasss must call this when loading is completed
  /// so to be able to reload or load other xml using this block
  void blocCompleted() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  @override
  Future<void> dispose() async {
    await unsubscribe();
    return super.dispose();
  }
}
