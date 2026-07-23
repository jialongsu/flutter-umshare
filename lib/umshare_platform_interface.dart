import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'umshare_method_channel.dart';

abstract class UmsharePlatform extends PlatformInterface {
  /// Constructs a UmsharePlatform.
  UmsharePlatform() : super(token: _token);

  static final Object _token = Object();

  static UmsharePlatform _instance = MethodChannelUmshare();

  /// The default instance of [UmsharePlatform] to use.
  ///
  /// Defaults to [MethodChannelUmshare].
  static UmsharePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UmsharePlatform] when
  /// they register themselves.
  static set instance(UmsharePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
