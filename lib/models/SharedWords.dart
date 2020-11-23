import 'package:flutter/services.dart';

class SharedWordsService {
  static const platform = const MethodChannel('app.channel.shared.data');
  final Function(String) onCreateWord;

  SharedWordsService(this.onCreateWord);

  Future init() async {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg.contains('resumed')) {
        final data = await _getSharedData();
        if (data['text'] == null) return;
        onCreateWord(_cleanSendText(data['text']));
      }
    });

    final data = await _getSharedData();
    if (data['text'] == null) return;
    onCreateWord(_cleanSendText(data['text']));
  }

  Future<Map> _getSharedData() async =>
      await platform.invokeMethod('getSharedData');
}

String _cleanSendText(String s) => s.replaceAll('\n', ' ');
