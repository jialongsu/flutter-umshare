import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  NewWantListener,
} from '@ohos/flutter_ohos';

import { AbilityConstant, common, Want } from '@kit.AbilityKit';

import { douYinOpenSDK } from "@douyin/opensdk-common-external";
import { ShareWeiBoSdk } from "@zyl/weibo_har";
import { StrUtil } from './StrUtil';
import { DDEventHandle } from './DDApiEventHandlerImpl';
import { UMSocialGlobal } from './UMSocialGlobal';
import { DouYinHelper } from './DouYinHelper';
import { ShareParams } from './ShareParams';
import { WeiBoHelper } from './WeiBoHelper';
import { DingTalkHelper } from './DingTalkHelper';
import { QQHelper } from './QQHelper';
import { AliPayHelper } from './AliPayHelper';

const TAG = "UmsharePlugin";

/** UmsharePlugin **/
export default class UmsharePlugin implements FlutterPlugin, MethodCallHandler, NewWantListener, AbilityAware {
  private channel: MethodChannel | null = null;
  private binding: AbilityPluginBinding | null = null;
  private launchWant: Want | null = null;

  constructor() {
    console.log(TAG, "constructor");
  }

  getUniqueClassName(): string {
    return "UmsharePlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    console.log(TAG, "onAttachedToEngine");
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "umshare");
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    console.log(TAG, "onDetachedFromEngine");
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null)
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    console.log(TAG, `onMethodCall ${call.method}`);
    console.log(TAG, typeof call.args)
    if (call.args instanceof Map) {
      call.args.forEach((value: ESObject, key: string) => {
        console.log(TAG, `Key: ${key}, Value: ${value}`);
      });
    }
    if (call.method === "umInit") {
      this.umInit(call, result);
    } else if (call.method === "platformConfig") {
      this.platformConfig(call, result);
    } else if (call.method === "umShare") {
      this.share(call, result);
    } else if (call.method === "umAuth") {
      this.auth(call, result);
    } else if (call.method === "umCheckInstall") {
      this.checkInstall(call, result);
    } else {
      result.notImplemented()
    }
  }

  share(call: MethodCall, result: MethodResult) {
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // 0: QQ, 1: 新浪微博, 4:	QQ空间, 28: 支付宝, 32: 钉钉, 34: 抖音
    let text: string = call.argument("text");
    let img: string = call.argument("img");
    let fileImg: string = call.argument("fileImg");
    let weburl: string = call.argument("weburl");
    let title: string = call.argument("title");
    let videoUrl: string = call.argument("videoUrl");
    let musicUrl: string = call.argument("musicUrl");
    let sharemedia: number = call.argument("sharemedia");
    const shareParams: ShareParams = {
      text: text,
      img: img,
      fileImg: fileImg,
      weburl: weburl,
      title: title,
      videoUrl: videoUrl,
      musicUrl: musicUrl,
      sharemedia: sharemedia
    }
    if (sharemedia == 0) { // QQ
      QQHelper.share(context, result, shareParams);
    } else if (sharemedia == 1) { // 新浪微博
      WeiBoHelper.share(context, result, shareParams)
    } else if (sharemedia == 4) { // QQ空间

    } else if (sharemedia == 28) { // 支付宝

    } else if (sharemedia == 32) { // 钉钉
      DingTalkHelper.share(context, result, shareParams);
    } else if (sharemedia == 34) { // 抖音
      DouYinHelper.share(context, result, shareParams);
    } else {
      result.error("400", "不支持的分享类型", null);
    }
  }

  checkInstall(call: MethodCall, result: MethodResult) {
    // 0: QQ, 1: 新浪微博, 4:	QQ空间, 28: 支付宝, 32: 钉钉, 34: 抖音
    let sharemedia = call.args as number;
    let params: Record<string, ESObject> = {};
    // boolean isInstall = UMShareAPI.get(ma).isInstall(ma, getShareMedia(sharemedia));
    params["code"] = 200;
    if (0 == sharemedia) { // qq
      params["isInstall"] = QQHelper.checkInstall();
    } else if (1 == sharemedia) { // sina
      params["isInstall"] = WeiBoHelper.checkInstall();
    } else if (4 == sharemedia) { // qq 空间

    } else if (28 == sharemedia) { // alipay
      params["isInstall"] = AliPayHelper.checkInstall();
    } else if (32 == sharemedia) { // dingding
      let canOpen = DingTalkHelper.checkInstall();
      params["isInstall"] = canOpen;
    } else if (34 == sharemedia) { // 抖音
      params["isInstall"] = DouYinHelper.checkInstall();
    }
    result.success(params);
  }

  platformConfig(call: MethodCall, result: MethodResult) {
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    console.log(TAG, `platformConfig: ${JSON.stringify(call.args)}`);
    if (StrUtil.isNotEmpty(call.argument("qqUniversalLink"))) {
      let qqUniversalLink: string = call.argument("qqUniversalLink");
      UMSocialGlobal.getInstance().qqUniversalLink = qqUniversalLink;
    }
    // sina
    if (StrUtil.isNotEmpty(call.argument("sinaWeiboAppKey")) &&
    StrUtil.isNotEmpty(call.argument("sinaWeiboAppSecret"))) {
      let sinaWeiboAppKey: string = call.argument("sinaWeiboAppKey");
      let sinaWeiboAppSecret: string = call.argument("sinaWeiboAppSecret");
      let redirectUrl: string = call.argument("redirectUrl");

      UMSocialGlobal.getInstance().sinaWeiboAppKey = sinaWeiboAppKey;
      UMSocialGlobal.getInstance().sinaWeiboAppSecret = sinaWeiboAppSecret;
      UMSocialGlobal.getInstance().redirectUrl = redirectUrl;

      WeiBoHelper.init(context);
    }

    //QQ
    if (StrUtil.isNotEmpty(call.argument("qqAppKey")) &&
    StrUtil.isNotEmpty(call.argument("qqAppSecret"))) {
      let qqAppKey: string = call.argument("qqAppKey");
      let qqAppSecret: string = call.argument("qqAppSecret");
      UMSocialGlobal.getInstance().qqAppKey = qqAppKey;
      UMSocialGlobal.getInstance().qqAppSecret = qqAppSecret;
      QQHelper.init();
    }

    // alipay
    if (StrUtil.isNotEmpty(call.argument("aliPayAppKey"))) {
      let aliPayAppKey: string = call.argument("aliPayAppKey");
      UMSocialGlobal.getInstance().aliPayAppKey = aliPayAppKey;
      AliPayHelper.init();
    }

    // ding ding
    if (StrUtil.isNotEmpty(call.argument("dingDingAppKey"))) {
      let dingDingAppKey: string = call.argument("dingDingAppKey");
      UMSocialGlobal.getInstance().dingDingAppKey = dingDingAppKey;
      DingTalkHelper.init();
    }

    // byteDance
    if (StrUtil.isNotEmpty(call.argument("byteDanceAppKey")) &&
    StrUtil.isNotEmpty(call.argument("byteDanceAppSecret"))) {
      let byteDanceAppKey: string = call.argument("byteDanceAppKey");
      let byteDanceAppSecret: string = call.argument("byteDanceAppSecret");
      let byteDanceRedirectUrl: string = call.argument("byteDanceRedirectUrl");
      UMSocialGlobal.getInstance().byteDanceAppKey = byteDanceAppKey;
      UMSocialGlobal.getInstance().byteDanceAppSecret = byteDanceAppSecret;
      UMSocialGlobal.getInstance().byteDanceRedirectUrl = byteDanceRedirectUrl;
      DouYinHelper.init();
    }
    result.success({
      "code": "200",
      "msg": "set platformConfig success"
    });
  }


  umInit(call: MethodCall, result: MethodResult) {
    console.log(TAG, `umInit: ${JSON.stringify(call.args)}`);
    let appKey: string = call.argument("appKey");
    let channel: string = call.argument("channel");
    let logEnabled: string = call.argument("logEnabled");
    // UMConfigure.preInit(this.context, appKey, "umengshare");
    // UMConfigure.init(this.context, appKey, channel, UMConfigure.DEVICE_TYPE_PHONE,"");
    // UMConfigure.setLogEnabled(logEnabled != null ? logEnabled : false);

    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    if (this.launchWant != null) {
      douYinOpenSDK.doResult(context, this.launchWant);
      ShareWeiBoSdk.mWBAPI?.doWBAsResult(this.launchWant, context);
      DingTalkHelper.dingdingApi?.handleWant(this.launchWant, DDEventHandle)
    }

    result.success({
      "code": "2000",
      "msg": "um init success"
    })
  }

  // 用户授权
  auth(call: MethodCall, result: MethodResult) {
    let sharemedia = call.args as number;
    console.log(TAG, `auth: ${sharemedia}`);
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    // 0: QQ, 1: 新浪微博, 4:	QQ空间, 28: 支付宝, 32: 钉钉, 34: 抖音
    if (34 === sharemedia) { // 抖音
      DouYinHelper.auth(context, result);
    } else if (1 === sharemedia) { // 微博
      WeiBoHelper.auth(context, result);
    } else if (32 === sharemedia) { // 钉钉
      DingTalkHelper.auth(context, result);
    }
  }

  private handleWant(want: Want) {
    if (!want.uri) {
      return;
    }
    let context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    douYinOpenSDK.doResult(context, want)
  }

  // MARK: - NewWantListener
  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    this.handleWant(want);
  }

  // MARK: - AbilityAware
  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.binding = binding;
    this.binding.addOnNewWantListener(this);
    // launchWant
    let want: Want = binding.getAbility().launchWant;
    this.launchWant = want;
    this.handleWant(this.launchWant);
  }

  onDetachedFromAbility(): void {
    this.binding?.removeOnNewWantListener(this);
    this.binding = null;
  }
}
