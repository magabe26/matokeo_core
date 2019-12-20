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

class DecoderBlocException implements Exception {
  final String message;

  DecoderBlocException(this.message);

  @override
  String toString() {
    return message;
  }
}

abstract class DecoderBloc<E, S> extends MBloc<E, S> {
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

  Future<void> load(String input, {String baseUrl}) async {
    if (input == null || input.isEmpty) {
      throw DecoderBlocException('input is null or empty');
    }

    if ((_completer != null) && (!_completer.isCompleted)) {
      return; //avoid data corruption
    }

    _completer = Completer();

    //unsubscribe previous stream
    await _unsubscribe();

    try {
      dispatchEvents(input, baseUrl: baseUrl);
    } catch (e) {
      throw DecoderBlocException(e.toString());
    }
  }

  void dispatchEvents(String input, {String baseUrl});

  void decode<T>({
    @required String input,
    @required MDecoder<T> decoder,
    @required DecoderListener<T> listener,
    @required OnDone onDone,
  }) {
    _stream = decoder.decode(input);
    _subscription = _stream.listen(listener, onDone: onDone);
  }

  /// A subclass must call this when loading is completed
  /// tobe able to reload or load new input using this block
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
