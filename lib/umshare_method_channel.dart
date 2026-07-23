import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'umshare_platform_interface.dart';

/// An implementation of [UmsharePlatform] that uses method channels.
class MethodChannelUmshare extends UmsharePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('umshare');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
