import 'utils.dart';

mixin UmShareBaseModel {
  Map<String, Object> toMap();
}

mixin UmInitBaseModel {
  Map<String, Object> toMap();
}

///初始化微博
///@AppKey 新浪微博应用 AppKey
///@appSecret 新浪微博应用 AppSecret
///@redirectUrl 对于新浪平台，redirectURL参数为新浪官方验证使用，参数内传递的URL必须和微博开放平台设置的授权回调页一致
///
class UmInitWeiBo implements UmInitBaseModel {
  final String appKey;
  final String appSecret;
  final String redirectUrl;

  UmInitWeiBo({
    required this.appKey,
    required this.appSecret,
    required this.redirectUrl,
  })  : assert(appKey.isNotEmpty),
        assert(appSecret.isNotEmpty),
        assert(redirectUrl.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      'sinaWeiboAppKey': appKey,
      'sinaWeiboAppSecret': appSecret,
      'redirectUrl': redirectUrl,
    };
  }
}

///初始腾讯QQ
///@AppKey 腾讯QQ应用 AppKey
///@appSecret 腾讯QQ应用 AppSecret
///@universalLink ios唤起第三方应用的链接
///
class UmInitQQ implements UmInitBaseModel {
  final String appKey;
  final String appSecret;
  final String universalLink;

  UmInitQQ({
    required this.appKey,
    required this.appSecret,
    required this.universalLink,
  })  : assert(appKey.isNotEmpty),
        assert(appSecret.isNotEmpty),
        assert(universalLink.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      'qqAppKey': appKey,
      'qqAppSecret': appSecret,
      'qqUniversalLink': universalLink,
    };
  }
}

///初始支付宝
///@AppKey 支付宝应用 AppKey
///
class UmInitAliPay implements UmInitBaseModel {
  final String appKey;

  UmInitAliPay({required this.appKey}) : assert(appKey.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      'aliPayAppKey': appKey,
    };
  }
}

///初始钉钉
///@AppKey 钉钉应用 AppKey
///
class UmInitDingDing implements UmInitBaseModel {
  final String appKey;

  UmInitDingDing({required this.appKey}) : assert(appKey.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      'dingDingAppKey': appKey,
    };
  }
}

///初始抖音
///@AppKey 钉钉应用 AppKey
///
class UmInitDouYin implements UmInitBaseModel {
  final String appKey;
  final String appSecret;

  UmInitDouYin({required this.appKey, required this.appSecret})
      : assert(appKey.isNotEmpty),
        assert(appSecret.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      'byteDanceAppKey': appKey,
      'byteDanceAppSecret': appSecret,
    };
  }
}

///分享网页
class UmShareWebModel implements UmShareBaseModel {
  final String title;
  final String text;
  final String img;
  final String webUrl;
  final UmShareMedia shareMedia;

  UmShareWebModel(this.webUrl, this.shareMedia, {required this.title, required this.text, required this.img})
      : assert(webUrl.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      "title": title,
      "text": text,
      "img": img,
      "weburl": webUrl,
      "sharemedia": Utils.getPlatform(shareMedia),
    };
  }
}

///分享网络图片
class UmShareHttpImgModel implements UmShareBaseModel {
  final String text;
  final String img;
  final UmShareMedia shareMedia;

  UmShareHttpImgModel(this.img, this.shareMedia, {required this.text}) : assert(img.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      "text": text,
      "img": img,
      "sharemedia": Utils.getPlatform(shareMedia),
    };
  }
}

///分享本地图片
class UmShareFileImgModel implements UmShareBaseModel {
  final String title;
  final String fileImg;
  final UmShareMedia shareMedia;

  UmShareFileImgModel(this.fileImg, this.shareMedia, {required this.title}) : assert(fileImg.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      "title": title,
      "fileImg": fileImg,
      "sharemedia": Utils.getPlatform(shareMedia),
    };
  }
}

///分享文本
class UmShareTextModel implements UmShareBaseModel {
  final String text;
  final UmShareMedia shareMedia;

  UmShareTextModel(this.text, this.shareMedia) : assert(text.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      "text": text,
      "sharemedia": Utils.getPlatform(shareMedia),
    };
  }
}

///分享视频
class UmShareVideoModel implements UmShareBaseModel {
  final String title;
  final String text;
  final String img;
  final String videoUrl;
  final UmShareMedia shareMedia;

  UmShareVideoModel(this.videoUrl, this.shareMedia, {required this.title, required this.text, required this.img})
      : assert(videoUrl.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      "videoUrl": videoUrl,
      "title": title,
      "text": text,
      "img": img,
      "sharemedia": Utils.getPlatform(shareMedia),
    };
  }
}

///分享音频
class UmShareMusicModel implements UmShareBaseModel {
  final String title;
  final String text;
  final String img;
  final String musicUrl;
  final UmShareMedia shareMedia;

  UmShareMusicModel(this.musicUrl, this.shareMedia, {required this.title, required this.text, required this.img})
      : assert(musicUrl.isNotEmpty);

  @override
  Map<String, Object> toMap() {
    return {
      "musicUrl": musicUrl,
      "title": title,
      "text": text,
      "img": img,
      "sharemedia": Utils.getPlatform(shareMedia),
    };
  }
}
