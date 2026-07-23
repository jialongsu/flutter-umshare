import common from "@ohos.app.ability.common";
import { MethodResult, } from '@ohos/flutter_ohos';
import { ShareParams } from "./ShareParams";
import {
  AuthInfo,
  checkWeiBoApp,
  doWeiboShare,
  Oauth2AccessToken,
  ShareWeiBoSdk,
  UiError,
  WbASListener
} from "@zyl/weibo_har";
import { StrUtil } from "./StrUtil";
import fileUri from "@ohos.file.fileuri";
import { UMSocialGlobal } from "./UMSocialGlobal";
import { compressImage, downloadAndCompressImage } from "./ImageUtil";

export class WeiBoHelper {
  static checkInstall(): boolean {
    return checkWeiBoApp();
  }

  static init(context: common.UIAbilityContext) {
    ShareWeiBoSdk.getInstance().initSdkCreate(new AuthInfo(
      context,
      UMSocialGlobal.getInstance().sinaWeiboAppKey, // APP_KEY_WB
      UMSocialGlobal.getInstance().redirectUrl, // 申REDIRECT_URL_WB
      UMSocialGlobal.getInstance().redirectUrl// SCOPE_WB
    ))
  }

  static async auth(context: common.UIAbilityContext, result: MethodResult) {
    if (checkWeiBoApp()) {
      let listener: WbASListener = {
        onComplete: (token: Oauth2AccessToken) => {
          let params: Record<string, ESObject> = {};
          params["code"] = 200;
          params.put("data", token);
          // for (String key:map.keySet()){
          //   params.put(key,map.get(key));
          // }
          result.success(params);
        },
        onError: (error: UiError) => {
          result.error("1", "error", error.errorMessage);
        },
        onCancel: () => {
          result.error("2", "cancel", "cancel");
        }
      };
      ShareWeiBoSdk.mWBAPI?.authorizeClient(context, listener);
    } else {
      let listener: WbASListener = {
        onComplete: (token: Oauth2AccessToken) => {
          let params: Record<string, ESObject> = {};
          params["code"] = 200;
          params.put("data", token);
          // for (String key:map.keySet()){
          //   params.put(key,map.get(key));
          // }
          result.success(params);
        },
        onError: (error: UiError) => {
          result.error("1", "error", error.errorMessage);
        },
        onCancel: () => {
          result.error("2", "cancel", "cancel");
        }
      };
      if (ShareWeiBoSdk.mWBAPI != null) {
        ShareWeiBoSdk.mWBAPI?.authorizeWeb(listener);
      }
    }
  }

  static async share(context: common.UIAbilityContext, result: MethodResult, shareParams: ShareParams) {
    let text = `${shareParams.text ?? ""} ${shareParams.weburl ?? ""}`;
    if (StrUtil.isNotEmpty(shareParams.fileImg)) {
      let localFile = await compressImage(shareParams.fileImg);
      doWeiboShare(text, [fileUri.getUriFromPath(localFile)]);
      let params: Record<string, ESObject> = {};
      params["code"] = 200;
      result.success(params);
    } else if (StrUtil.isNotEmpty(shareParams.img)) {
      try {
        let filePath = await downloadAndCompressImage(shareParams.img)
        if (filePath.length > 0) {
          let localFile = await compressImage(filePath);
          doWeiboShare(text, [fileUri.getUriFromPath(localFile)]);
          let params: Record<string, ESObject> = {};
          params["code"] = 200;
          result.success(params);
        } else {
          result.error("1", "error", "获取资源失败");
        }
      } catch (error) {
        result.error("1", "error", error.errorMessage);
      }
    }
  }
}