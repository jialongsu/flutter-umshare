# [flutter-umshare](https://pub.dev/packages/umshare)
 flutter 友盟分享插件，支持android和ios。

## 支持的平台

 - 微博
 - QQ
 - 钉钉
 - 支付宝

## 能力

 - 分享
 - 登录
 - 判断平台是否安装

## 安装：
在pubspec.yaml 文件中添加umshare依赖:

```javascript

dependencies:
  umshare: ^${latestVersion}
  
```

## 使用

```javascript
import 'package:umshare/umshare.dart';

///初始化友盟sdk，在所有方法使用之前
Umshare.init("你申请的友盟APP ID");

//初始化需要分享的平台
Umshare.platformConfig([
  UmInitWeiBo(
    appKey: '申请的微博APP ID',
    appSecret: '申请的微博app Secret',
    redirectUrl: '申请的微博APP配置的回调接口地址',
  ),
]);

```

## 判断平台是否安装

```javascript

 var res = await Umshare.checkInstall(UmShareMedia.dingDing);
 print('========检查是否安装应用====dingDing=======$res');
 
```

## 分享

```javascript

var res = await Umshare.share(UmShareWebModel(
    'https://www.baidu.com',
    UmShareMedia.weiBo,
    title: 'demo',
    text: 'test-----',
    img: 'https://avatar.csdnimg.cn/0/6/4/3_unhappy_long.jpg',
 ));
 print('========分享回调结果=========$res');
                
```

## 授权登录

```javascript

 var res = await Umshare.auth(UmShareMedia.weiBo);
 print('========登录回调结果====res=======$res');
 
```

## 方法

|Method|Description  |Result|
|--|--|--|
| init | 友盟sdk初始化方法，需在调用任何方法前调用 |Future|
| platformConfig | 初始化需要分享的平台，支持UmInitWeiBo，UmInitQQ,，UmInitAliPay,，UmInitDingDing |Future|
| checkInstall | 判断平台是否安装方法 |Future|
| auth | 授权登录方法 |Future|
| share | 分享方法 |Future|

## 属性
**1.UmInitBaseModel： 平台sdk初始化类**

 - UmInitWeiBo -- 初始化微博
 - UmInitQQ -- 初始腾讯QQ
 - UmInitAliPay -- 初始支付宝
 - UmInitDingDing -- 初始钉钉
 
**2.UmShareBaseModel：分享类**

 - UmShareWebModel -- 分享网页
 - UmShareHttpImgModel -- 分享网络图片
 - UmShareFileImgModel -- 分享本地图片
 - UmShareTextModel -- 分享文本
 - UmShareVideoModel -- 分享视频
 - UmShareMusicModel -- 分享音频

