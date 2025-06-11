import 'dart:async';

import 'package:flutter/services.dart';
import 'package:umshare/umshare_models.dart';

import 'utils.dart';

export 'package:umshare/umshare_models.dart';

export 'utils.dart';

class Umshare {
  static const MethodChannel _channel = const MethodChannel('umshare');

  ///初始化um sdk
  ///@appKey 友盟应用 appKey
  ///@channel 分享渠道
  ///@logEnabled 是否开启日志
  ///在调用所有方法前必须调用
  ///
  static Future<dynamic> init(String appKey, {String channel = "umengshare", bool logEnabled = false}) async {
    Map<dynamic, dynamic> result = await _channel.invokeMethod('umInit', {
      "appKey": appKey,
      "channel": channel,
      "logEnabled": true,
    });
    return result;
  }

  ///初始化各平台 app sdk
  ///
  static Future<dynamic> platformConfig(List<UmInitBaseModel> list) async {
    Map<String, Object> params = {};
    list.forEach((item) {
      params.addAll(item.toMap());
    });
    var result = await _channel.invokeMethod('platformConfig', params);
    return result;
  }

  ///分享
  ///@title 分享标题
  ///@text 分享描述
  ///@img 分享图片
  ///@fileImg 本地文件图片路径
  ///@webUrl 分享网页链接
  ///@videoUrl 分享视频链接
  ///@musicUrl 分享音频链接
  ///@shareMedia 分享类型：0: QQ, 1: 新浪微博, 4:	QQ空间, 28: 支付宝, 32: 钉钉, 34: 抖音
  ///
  static Future<dynamic> share(UmShareBaseModel model) async {
    Map<dynamic, dynamic> result = await _channel.invokeMethod('umShare', model.toMap());
    return result;
  }

  ///登录
  ///@shareMedia 分享类型：0: QQ, 1: 新浪微博, 4:	QQ空间, 28: 支付宝, 32: 钉钉, 34: 抖音
  ///
  static Future<dynamic> auth(UmShareMedia shareMedia) async {
    Map<dynamic, dynamic> result = await _channel.invokeMethod('umAuth', Utils.getPlatform(shareMedia));
    return result;
  }

  ///检查应用是否安装
  ///@shareMedia 分享类型：0: QQ, 1: 新浪微博, 4:	QQ空间, 28: 支付宝, 32: 钉钉, 34: 抖音
  ///
  static Future<dynamic> checkInstall(UmShareMedia shareMedia) async {
    Map<dynamic, dynamic> result = await _channel.invokeMethod('umCheckInstall', Utils.getPlatform(shareMedia));
    return result;
  }
}
