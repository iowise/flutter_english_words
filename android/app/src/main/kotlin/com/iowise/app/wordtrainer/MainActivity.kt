package com.iowise.app.wordtrainer

import android.os.Bundle
import android.content.Intent

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
  val sharedData = HashMap<String, String>()
  val CHANNEL = "app.channel.shared.data"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState);
    handleSendIntent(getIntent());
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler shared@{ call, result ->
      if (call.method == "getSharedData") {
        result.success(sharedData);
        sharedData.clear();
      }
    }
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent);
    handleSendIntent(intent);
  }

  fun handleSendIntent(intent: Intent) {
    val action = intent.action
    val type = intent.type

    if (Intent.ACTION_SEND == action && "text/plain" == type) {
      intent.getStringExtra(Intent.EXTRA_SUBJECT)?.let { subject ->
        intent.getStringExtra(Intent.EXTRA_TEXT)?.let { text ->
          sharedData.put("subject", subject);
          sharedData.put("text", text);
        }
      }

    }
  }
}
