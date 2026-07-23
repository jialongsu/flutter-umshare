import { bundleManager, common } from "@kit.AbilityKit";
import { MethodResult, } from '@ohos/flutter_ohos';
import { IQQOpenApi, QQOpenApiFactory } from "@tencent/qq-open-sdk";
import { ShareParams } from "./ShareParams";
import { UMSocialGlobal } from "./UMSocialGlobal";
import { cryptoFramework } from "@kit.CryptoArchitectureKit";
import { buffer } from "@kit.ArkTS";

export class QQHelper {
  static iQQOpenApi: IQQOpenApi | null = null;

  static init() {
    QQHelper.iQQOpenApi = QQOpenApiFactory.createApi(Number(UMSocialGlobal.getInstance().qqAppKey))
  }

  static checkInstall(): boolean {
    return QQHelper.iQQOpenApi?.isQQInstalled() ?? false;
  }

  static async auth(context: common.UIAbilityContext, result: MethodResult) {

  }

  static async share(context: common.UIAbilityContext, result: MethodResult, shareParams: ShareParams) {
    const shareJson = JSON.stringify({
      "msg_style": 0,
      "title": shareParams.title,
      "summary": shareParams.text,
      "brief": "",
      "url": shareParams.weburl,
      "picture_url": shareParams.img
    });
    const timestamp = Math.floor(Date.now() / 1000);
    const nonce = Math.floor(Math.random() * 1000000000);
    const appKey = UMSocialGlobal.getInstance().qqAppKey;
    const appSecret = UMSocialGlobal.getInstance().qqAppSecret;
    const signStr = appKey + shareJson + timestamp + nonce + appSecret;

    let mdAlgName = 'MD5'
    let md = cryptoFramework.createMd(mdAlgName)
    md.updateSync({ data: new Uint8Array(buffer.from(signStr, 'utf-8').buffer) })
    let shareJsonSign: string = md.digestSync().data.toString()
    QQHelper.iQQOpenApi?.share(2, {
      "shareJson": shareJson,
      "timestamp": timestamp,
      "nonce": nonce,
      "shareJsonSign": shareJsonSign
    })
  }
}