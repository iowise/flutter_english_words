package com.iowise.app.wordtrainer

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  val sharedData = HashMap<String, String>()
  val CHANNEL = "app.channel.shared.data"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState);
//    GeneratedPluginRegistrant.registerWith(this);

    handleSendIntent(getIntent());

    MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).setMethodCallHandler shared@{ call, result ->
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

    if (Intent.ACTION_SEND == action && type != null) {
      if ("text/plain".equals(type)) {
        sharedData.put("subject", intent.getStringExtra(Intent.EXTRA_SUBJECT));
        sharedData.put("text", intent.getStringExtra(Intent.EXTRA_TEXT));
      }
    }
  }
}
