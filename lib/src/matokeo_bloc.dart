/**
 * Copyright 2019 - MagabeLab (Tanzania). All Rights Reserved.
 * Author Edwin Magabe    edyma50@yahoo.com
 */

import 'package:meta/meta.dart';
import 'dart:async';

import 'mbloc.dart';
import 'mdecoder.dart';

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

  Future<void> _unsubscribe() async {
    if ((_subscription != null) && (_stream != null)) {
      try {
        await _subscription.cancel();
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
    await _unsubscribe();

    try {
      dispatchEvents(xml, baseUrl: baseUrl);
    } catch (e) {
      throw MatokeoBlocException(e.toString());
    }
  }

  void dispatchEvents(String xml, {String baseUrl});

  void decode<T>({
    @required String xml,
    @required MDecoder<T> decoder,
    @required DecoderListener<T> listener,
    @required OnDone onDone,
  }) {
    _stream = decoder.decode(xml);
    _subscription = _stream.listen(listener, onDone: onDone);
  }

  /// A subclass must call this when loading is completed
  /// so to be able to reload or load new xml using this block
  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  @override
  Future<void> dispose() async {
    await _unsubscribe();
    return super.dispose();
  }
}
