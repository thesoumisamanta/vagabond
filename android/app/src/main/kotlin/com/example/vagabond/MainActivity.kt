package app.vagabond.com

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val channel: String = "app.vagabond.com/config"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler {
      call: MethodCall, result: MethodChannel.Result ->
        if (call.method == "getBaseUrl") {
          // Retrieve the base URL
          val baseUrl: String = BuildConfig.BASE_URL
          result.success(baseUrl)
        } else {
          result.notImplemented()
        }
      }
  }
}
