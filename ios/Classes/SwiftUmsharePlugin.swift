import Flutter
import UIKit

public class SwiftUmsharePlugin: NSObject, FlutterPlugin, UIApplicationDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "umshare", binaryMessenger: registrar.messenger())
    let instance = SwiftUmsharePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance);
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    if("umInit" == call.method) {
        umInit(call: call, result: result);
    }else if("platformConfig" == call.method) {
        platformConfig(call: call, result: result);
    } else if("umShare" == call.method) {
        share(call: call, result: result);
    } else if("umAuth" == call.method) {
        auth(call: call, result: result);
    } else if("umCheckInstall" == call.method) {
        checkInstall(call: call, result: result);
    }else {
        result(FlutterMethodNotImplemented);
    }
    
  }
    
  public func getShareMedia(_ platform: Int) -> UMSocialPlatformType {
    
    switch (platform) {
      case 0: // QQ
        return UMSocialPlatformType.QQ;
      case 1: // Sina
        return UMSocialPlatformType.sina;
      case 2: // wechat
        return UMSocialPlatformType.wechatSession;
      case 3:
        return UMSocialPlatformType.wechatTimeLine;
      case 4:
        return UMSocialPlatformType.qzone;
      case 5:
        return UMSocialPlatformType.email;
      case 6:
        return UMSocialPlatformType.sms;
      case 7:
        return UMSocialPlatformType.facebook;
      case 8:
        return UMSocialPlatformType.twitter;
      case 9:
        return UMSocialPlatformType.wechatFavorite;
      case 10:
        return UMSocialPlatformType.googlePlus;
      case 11:
        return UMSocialPlatformType.renren;
      case 12:
        return UMSocialPlatformType.tencentWb;
      case 13:
        return UMSocialPlatformType.douban;
      case 14:
        return UMSocialPlatformType.faceBookMessenger;
      case 15:
        return UMSocialPlatformType.yixinSession;
      case 16:
        return UMSocialPlatformType.yixinTimeLine;
      case 17:
        return UMSocialPlatformType.instagram;
      case 18:
        return UMSocialPlatformType.pinterest;
      case 19:
        return UMSocialPlatformType.everNote;
      case 20:
        return UMSocialPlatformType.pocket;
      case 21:
        return UMSocialPlatformType.linkedin;
      case 22:
        return UMSocialPlatformType.unKnown; // foursquare on android
      case 23:
        return UMSocialPlatformType.youDaoNote;
      case 24:
        return UMSocialPlatformType.whatsapp;
      case 25:
        return UMSocialPlatformType.line;
      case 26:
        return UMSocialPlatformType.flickr;
      case 27:
        return UMSocialPlatformType.tumblr;
      case 28:
        return UMSocialPlatformType.apSession;
      case 29:
        return UMSocialPlatformType.kakaoTalk;
      case 30:
        return UMSocialPlatformType.dropBox;
      case 31:
        return UMSocialPlatformType.vKontakte;
      case 32:
        return UMSocialPlatformType.dingDing;
      case 33:
        return UMSocialPlatformType.unKnown; // more
      case 34:
        return UMSocialPlatformType.douYin;
      default:
        return UMSocialPlatformType.QQ;
    }
  }
    
    public func shareWithText(_ text: String?, icon: String?, fileImg: String?, videoUrl: String?, musicUrl: String?, link: String?, title: String?, platform: Int, completion: @escaping UMSocialRequestCompletionHandler) {
        let messageObject = UMSocialMessageObject()

        if (link?.count ?? 0) > 0 {
            let shareObject = UMShareWebpageObject.shareObject(withTitle: title, descr: text, thumImage: icon)
            shareObject?.webpageUrl = link

            messageObject.shareObject = shareObject
        } else if (videoUrl?.count ?? 0) > 0 {
            let shareVideoObject = UMShareVideoObject.shareObject(withTitle: title, descr: text, thumImage: icon);
            shareVideoObject?.videoUrl = videoUrl;
            messageObject.shareObject = shareVideoObject;
        } else if (musicUrl?.count ?? 0) > 0 {
            let shareObject = UMShareMusicObject.shareObject(withTitle: title, descr: text, thumImage: icon);
            shareObject?.musicUrl = musicUrl;
            messageObject.shareObject = shareObject;
        } else if (icon?.count ?? 0) > 0 {
            var img: Any? = nil
            if icon?.hasPrefix("http") ?? false {
                img = icon
            } else {
                if icon?.hasPrefix("/") ?? false {
                    img = UIImage(contentsOfFile: icon ?? "")
                } else {
                    img = UIImage(contentsOfFile: Bundle.main.path(forResource: icon, ofType: nil) ?? "")
                }
            }
            let shareObject = UMShareImageObject()
            shareObject.thumbImage = img
            shareObject.shareImage = img
            messageObject.shareObject = shareObject

            messageObject.text = title
        }  else if (fileImg?.count ?? 0) > 0 {
            let img = UIImage.init(contentsOfFile: fileImg!)
            let shareObject = UMShareImageObject()
            shareObject.thumbImage = img
            shareObject.shareImage = img
            messageObject.shareObject = shareObject

            messageObject.text = title
        } else if (text?.count ?? 0) > 0 {
            messageObject.text = text
        } else {
            completion(nil, NSError(domain: "UShare", code: -3, userInfo: [
                "message": "invalid parameter"
            ]))
            return
        }
        
       
        UMSocialManager.default()?.share(to: getShareMedia(platform), messageObject: messageObject, currentViewController: nil, completion: completion)

    }
    
    public func umInit(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as! Dictionary<String, Any>;
        let appKey = params["appKey"] as! String;
        let channel = params["channel"] as! String;
        let logEnabled = params["logEnabled"] as! Bool;
        UMConfigure.initWithAppkey(appKey, channel: channel);
        UMConfigure.setLogEnabled(logEnabled);
        result(["code": "200", "msg": "um init success"]);
    }
    
    public func platformConfig(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as! Dictionary<String, String>;
        let keys = params.keys;
        let uMSocialManager = UMSocialManager.default();
        
        //初始化 UniversalLink
        if(keys.contains("qqUniversalLink")) {
            UMSocialGlobal.shareInstance().universalLinkDic = [
                UMSocialPlatformType.QQ: params["qqUniversalLink"]!
            ]
        }
        
        //QQ
        if(keys.contains("qqAppSecret") && keys.contains("qqAppKey")) {
            uMSocialManager?.setPlaform(UMSocialPlatformType.QQ, appKey: params["qqAppKey"], appSecret: params["qqAppSecret"], redirectURL: "http://mobile.umeng.com/social")
        }
        
        //新浪微博
        if(keys.contains("sinaWeiboAppKey") && keys.contains("sinaWeiboAppSecret")) {
            uMSocialManager?.setPlaform(UMSocialPlatformType.sina, appKey: params["sinaWeiboAppKey"], appSecret: params["sinaWeiboAppSecret"], redirectURL: params["redirectUrl"])
        }

        //支付宝
        if(keys.contains("aliPayAppKey")) {
            uMSocialManager?.setPlaform(UMSocialPlatformType.sina, appKey: params["aliPayAppKey"], appSecret: nil, redirectURL: "http://mobile.umeng.com/social")
        }
        
        //钉钉
        if(keys.contains("dingDingAppKey")) {
            uMSocialManager?.setPlaform(UMSocialPlatformType.sina, appKey: params["dingDingAppKey"], appSecret: nil, redirectURL: nil)
        }

        //抖音
        if(keys.contains("byteDanceAppKey") && keys.contains("byteDanceAppSecret")) {
            uMSocialManager?.setPlaform(UMSocialPlatformType.douYin, appKey: params["byteDanceAppKey"], appSecret: params["byteDanceAppSecret"], redirectURL:nil)
        }
        
        result(["code": "200", "msg": "set platformConfig success"]);
    }
    
    public func share(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as! Dictionary<String, Any>;
        let text: String = params["text"] as? String ?? "";
        let img: String = params["img"] as? String ?? "";
        let fileImg: String = params["fileImg"] as? String ?? "";
        let weburl: String = params["weburl"] as? String ?? "";
        let title: String = params["title"] as? String ?? "";
        let videoUrl: String = params["videoUrl"] as? String ?? "";
        let musicUrl: String = params["musicUrl"] as? String ?? "";
        let sharemedia: Int = params["sharemedia"] as? Int ?? -1;
        
        if(getShareMedia(sharemedia) == UMSocialPlatformType.unKnown) {
            result(["code": "-1", "msg": "invalid platform"]);
            return;
        }

        shareWithText(
            text,
            icon: img,
            fileImg: fileImg,
            videoUrl: videoUrl,
            musicUrl: musicUrl,
            link: weburl,
            title: title,
            platform: sharemedia,
            completion: {(res,error) in
                if((error) != nil) {
                    let _error = error! as NSError;
                    var msg = _error.userInfo["NSLocalizedFailureReason"] as? String
                    if (msg == nil) {
                        msg = _error.userInfo["message"] as? String
                    }
                    if (msg == nil) {
                        msg = "share failed"
                    }
                    var stcode: Int = _error.code;
                    if(stcode == 2009){
                      stcode = -1;
                    }
                    result(["code": stcode, "msg": msg ?? "failed"]);
                } else {
                    result(["code": 200, "msg": "share success"]);
                }
            })
        
    }
    
    public func auth(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let sharemedia: Int = call.arguments as! Int;
        
        if(getShareMedia(sharemedia) == UMSocialPlatformType.unKnown) {
            result(["code": "-1", "msg": "invalid platform"]);
            return;
        }
        
        UMSocialManager.default()?.getUserInfo(with: getShareMedia(sharemedia), currentViewController: nil, completion: {(res,error) in
            if((error) != nil) {
                let _error = error! as NSError;
                var msg = _error.userInfo["NSLocalizedFailureReason"] as? String
                if (msg == nil) {
                    msg = _error.userInfo["message"] as? String
                }
                if (msg == nil) {
                    msg = "share failed"
                }
                var stcode: Int = _error.code;
                if(stcode == 2009){
                  stcode = -1;
                }
                result(["code": stcode, "msg": msg ?? "failed"]);
            } else {
                let authInfo = res as! UMSocialUserInfoResponse;
                let originInfo = authInfo.originalResponse as! Dictionary<String, Any>;
                // retDict["uid"] = authInfo.uid;
                // retDict["openid"] = authInfo.openid;
                // retDict["unionId"] = authInfo.unionId;
                // retDict["accessToken"] = authInfo.accessToken;
                // retDict["refreshToken"] = authInfo.refreshToken;
                // retDict["expiration"] = authInfo.expiration;
                // retDict["name"] = authInfo.name;
                // retDict["iconurl"] = authInfo.iconurl;
                // retDict["city"] = originInfo["city"];
                // retDict["province"] = originInfo["province"];
                // retDict["country"] = originInfo["country"];
                
                result(["code": 200, "msg": "share success", "data": originInfo]);
            }
        })
    }
    
    public func checkInstall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let sharemedia: Int = call.arguments as! Int;
        
        if(getShareMedia(sharemedia) == UMSocialPlatformType.unKnown) {
            result(["code": "-1", "msg": "invalid platform"]);
            return;
        }
        
        let isInstall = UMSocialManager.default()?.isInstall(getShareMedia(sharemedia))
        result(["code": 200, "isInstall": isInstall ?? false]);
        
    }
    
    // MARK: - iOS 9.0+ 推荐使用的方法（新版 API）
   @available(iOS 9.0, *)
   public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
       let result = UMSocialManager.default().handleOpen(url, options: options)
       if !result {
           // 其他 SDK 的回调（如微信、支付宝等）
           print("UMShare 未处理该 URL")
       }
       return result
   }

   // MARK: - iOS 8.0+ 兼容方法（旧版 API）
   public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       let result = UMSocialManager.default().handleOpen(url, sourceApplication: sourceApplication, annotation: annotation)
       if !result {
           // 其他 SDK 的回调
           print("UMShare 未处理该 URL")
       }
       return result
   }

   // MARK: - 更老版本兼容（iOS 7 及以下，已弃用）
   public func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
       let result = UMSocialManager.default().handleOpen(url)
       if !result {
           // 其他 SDK 的回调
           print("UMShare 未处理该 URL")
       }
       return result
   }

   // MARK: - Universal Links 处理（iOS 9+）
    @nonobjc @available(iOS 9.0, *)
   public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
       let result = UMSocialManager.default().handleUniversalLink(userActivity, options: nil)
       if !result {
           // 其他 SDK 的回调
           print("UMShare 未处理该 Universal Link")
       }
       return result
   }

}
