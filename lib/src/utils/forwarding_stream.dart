import 'dart:async';

import 'package:rxdart/src/utils/forwarding_sink.dart';

/// @private
/// Helper method which forwards the events from an incoming [Stream]
/// to a new [StreamController].
/// It captures events such as onListen, onPause, onResume and onCancel,
/// which can be used in pair with a [ForwardingSink]
_ForwardStream<T> forwardStream<T>(Stream<T> stream) {
  StreamController<T> controller;
  ForwardingSink<T> connectedSink;

  final onListen = () {
    stream.listen(controller.add,
        onError: controller.addError, onDone: controller.close);

    try {
      connectedSink?.onListen();
    } catch (e, s) {
      controller.addError(e, s);
    }
  };

  final onCancel = () {
    try {
      connectedSink?.onCancel();
    } catch (e, s) {
      controller.addError(e, s);
    }
  };

  final onPause = () {
    try {
      connectedSink?.onPause();
    } catch (e, s) {
      controller.addError(e, s);
    }
  };

  final onResume = () {
    try {
      connectedSink?.onResume();
    } catch (e, s) {
      controller.addError(e, s);
    }
  };

  controller = stream.isBroadcast
      ? StreamController<T>.broadcast(
          onListen: onListen, onCancel: onCancel, sync: true)
      : StreamController<T>(
          onListen: onListen,
          onCancel: onCancel,
          onPause: onPause,
          onResume: onResume,
          sync: true);

  return _ForwardStream<T>(
      controller.stream, (ForwardingSink<T> sink) => connectedSink = sink);
}

class _ForwardStream<T> {
  final Stream<T> stream;
  final ForwardingSink<T> Function(ForwardingSink<T> sink) connect;

  _ForwardStream(this.stream, this.connect);
}
