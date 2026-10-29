import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(SynapseVoiceTaskHandler());
}

class SynapseVoiceTaskHandler extends TaskHandler {
  SendPort? _sendPort;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Android Foreground Service Initialized for ambient "Hey Buddy" detection
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Periodic background keep-alive check
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    // Service stopped
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'ask_synapse') {
      // Trigger voice query popup directly over lock screen
      AndroidForegroundVoiceService.wakeScreenAndShow();
      FlutterForegroundTask.wakeUpScreen();
    }
  }

  @override
  void onNotificationPressed() {
    AndroidForegroundVoiceService.wakeScreenAndShow();
    FlutterForegroundTask.launchApp();
  }
}

class AndroidForegroundVoiceService {
  AndroidForegroundVoiceService._();

  static const MethodChannel _lockScreenChannel =
      MethodChannel('com.synapse.ambient/lock_screen');

  static Future<void> initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'synapse_ambient_channel',
        channelName: 'Synapse Ambient Listening',
        channelDescription:
            'Maintains zero-latency "Hey Buddy" wake-word detection while locked.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        buttons: [
          const NotificationButton(id: 'ask_synapse', text: '🎙️ Speak to Synapse'),
        ],
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  static Future<bool> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return true;
    }

    return await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'Synapse Ambient Voice',
      notificationText: 'Listening for "Hey Buddy"...',
      callback: startCallback,
    );
  }

  static Future<bool> stopService() async {
    return await FlutterForegroundTask.stopService();
  }

  static Future<bool> isRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }

  /// Turns screen on and shows Synapse activity over Android lock screen
  static Future<bool> wakeScreenAndShow() async {
    try {
      final res = await _lockScreenChannel.invokeMethod<bool>('wakeScreenAndShow');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Requests exemption from Android Doze battery killing
  static Future<bool> requestBatteryOptimizationExemption() async {
    try {
      final res = await _lockScreenChannel
          .invokeMethod<bool>('requestIgnoreBatteryOptimizations');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Verifies if app is already exempt from battery optimization
  static Future<bool> isBatteryOptimizationIgnored() async {
    try {
      final res = await _lockScreenChannel
          .invokeMethod<bool>('isBatteryOptimizationIgnored');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Controls screen wake-lock
  static Future<bool> keepScreenOn(bool enable) async {
    try {
      final res = await _lockScreenChannel
          .invokeMethod<bool>('keepScreenOn', {'enable': enable});
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}
