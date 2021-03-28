import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mrz_parser/mrz_parser.dart';

/// MRZ scanner camera widget
class MRZScanner extends StatefulWidget {
  const MRZScanner({
    Key key,
    @required this.onControllerCreated,
  }) : super(key: key);

  /// Provides a controller for MRZ handling
  final void Function(MRZController controller) onControllerCreated;
  @override
  _MRZScannerState createState() => _MRZScannerState();
}

class _MRZScannerState extends State<MRZScanner> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class MRZController {
  MRZController._init(int id) {
    _channel = MethodChannel('mrzscanner_$id');
    _channel.setMethodCallHandler(_platformCallHandler);
  }
  MethodChannel _channel;
  void Function(MRZResult mrz) onParsed;
  void Function(String text) onError;

  void flashlightOn() {
    _channel.invokeMethod<void>('flashlightOn');
  }

  void flashlightOff() {
    _channel.invokeMethod<void>('flashlightOff');
  }

  Future<List<int>> takePhoto({
    bool crop = true,
  }) async {
    final result = await _channel.invokeMethod<List<int>>('takePhoto', {
      'crop': crop,
    });
    return result;
  }

  Future<void> _platformCallHandler(MethodCall call) {
    switch (call.method) {
      case 'onError':
        if (onError != null) {
          onError(call.arguments);
        }
        break;
      case 'onParsed':
        if (onParsed != null) {
          final lines = _splitRecognized(call.arguments);
          if (lines.isNotEmpty) {
            final result = MRZParser.tryParse(lines);
            if (result != null) {
              onParsed(result);
            }
          }
        }
        break;
    }
    return Future.value();
  }

  List<String> _splitRecognized(String recognizedText) {
    final mrzString = recognizedText.replaceAll(' ', '');
    return mrzString.split('\n').where((s) => s.isNotEmpty).toList();
  }

  void startPreview({bool isFrontCam = false}) => _channel.invokeMethod<void>(
        'start',
        {
          'isFrontCam': isFrontCam,
        },
      );

  void stopPreview() => _channel.invokeMethod<void>('stop');
}
