import {
  DouYinOpenConfigBuilder,
  DouYinOpenListener,
  douYinOpenSDK,
  ImageObject,
  LandingPage,
  MixObject,
  OpenAuthRequest,
  OpenAuthResponse,
  OpenShareRequest,
  OpenShareResponse,
  SupportApiName
} from "@douyin/opensdk-common-external";
import { MethodResult, } from '@ohos/flutter_ohos';
import { UMSocialGlobal } from "./UMSocialGlobal";
import { bundleManager, common } from "@kit.AbilityKit";

import { http } from '@kit.NetworkKit';
import { ShareParams } from "./ShareParams";
import { StrUtil } from "./StrUtil";
import fileUri from "@ohos.file.fileuri";

const TAG = "DouYinHelper";

export class DouYinHelper {
  static init() {
    // PlatformConfig.setBytedance(byteDanceAppKey, byteDanceAppKey, byteDanceAppSecret, FileProvider);
    // 抖音初始化
    let apiParam = new DouYinOpenConfigBuilder(UMSocialGlobal.getInstance().byteDanceAppKey)
      .setDebug(true) //是否开启debug开关，目前主要为输出日志
      .setHostLogService({
        d(tag: string, message: string): void {
          console.log(TAG, `d -> tag:${tag} message: ${message}`);
        },

        i(tag: string, message: string): void {
          console.log(TAG, `i -> tag:${tag} message: ${message}`);
        },

        w(tag: string, message: string): void {
          console.log(TAG, `w -> tag:${tag} message: ${message}`);
        },

        e(tag: string, message: string): void {
          console.log(TAG, `e -> tag:${tag} message: ${message}`);
        }
      }) //可选实现
      .build();
    douYinOpenSDK.init(apiParam)
  }

  static checkInstall(): boolean {
    return bundleManager.canOpenLink('snssdk1128://');
  }

  static async auth(context: common.UIAbilityContext, result: MethodResult) {
    let listener: DouYinOpenListener = {
      onSuccess: (response: OpenAuthResponse, authCode: string, grantedPermissions: string) => {
        console.log(TAG,
          `auth onSuccess: -> response.authCode:${response.authCode} errCode:${grantedPermissions} errMsg: ${grantedPermissions}`);
        let params: Record<string, ESObject> = {};
        params["code"] = 200;
        params["data"] = authCode
        result.success(params);
      },
      onError: (response: OpenAuthResponse, errCode: number, errMsg: string) => {
        console.log(TAG,
          `auth onError: -> response.authCode:${response.authCode} errCode:${errCode} errMsg: ${errMsg}`);
        if (errCode === -2) { // 用户手动取消
          result.error("2", "cancel", "cancel");
        } else {
          result.error("1", "error", errMsg);
        }
      }
    }
    let authRequest: OpenAuthRequest = new OpenAuthRequest();
    authRequest.scope = "user_info"
    authRequest.state = "AuthUseCase";
    authRequest.callerLocalEntry = "EntryAbility";
    authRequest.redirectUri = UMSocialGlobal.getInstance().byteDanceRedirectUrl;
    douYinOpenSDK.createDouYinOpenApi()?.authorize(context, authRequest, listener);
  }

  static async share(context: common.UIAbilityContext, result: MethodResult, shareParams: ShareParams) {
    if (StrUtil.isNotEmpty(shareParams.fileImg)) {
      let request = new OpenShareRequest()
      request.state = "share";
      request.callerLocalEntry = "EntryAbility";
      request.redirectUri = UMSocialGlobal.getInstance().byteDanceRedirectUrl;
      request.landingPage = LandingPage.Edit
      let uri = fileUri.getUriFromPath(shareParams.fileImg)
      let imageObject = new ImageObject()
      imageObject.imageUri = uri
      request.mediaObject = imageObject
      let douYinOpenApi = douYinOpenSDK.createDouYinOpenApi()
      if (douYinOpenApi?.isSupportApi(SupportApiName.SUPPORT_MIX) == true) {
        let mixObject = new MixObject()
        mixObject.uriList.push(uri) // 可以多加
        request.mediaObject = mixObject
      }
      let listener: DouYinOpenListener = {
        onSuccess: (response: OpenShareResponse) => {

        },
        onError: (response: OpenShareResponse, errorCode: number, errMsg?: string) => {
          console.log(TAG,
            `share onError: -> errorCode:${errorCode} errMsg: ${errMsg}`);
        }
      }
      douYinOpenSDK.createDouYinOpenApi()?.share(context, request, listener)
    }
  }

  async getAccessToken(code: string): Promise<void> {
    const url = 'https://open.douyin.com/oauth/access_token/';
    try {
      let response = await http.createHttp().request(
        url,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/x-www-form-urlencoded' },
          extraData: {
            client_id: UMSocialGlobal.getInstance().byteDanceAppKey,
            client_secret: UMSocialGlobal.getInstance().byteDanceAppSecret,
            grant_type: 'authorization_code',
            code: code,
            redirect_uri: UMSocialGlobal.getInstance().byteDanceRedirectUrl
          }
        }
      );
      if (response.responseCode === 200) {
        const result: AccessTokenResult = JSON.parse(response.result.toString()) as AccessTokenResult;
        if (result.data.error_code == 0) {
          console.log(TAG, `result.data.access_token: ${result.data.access_token}`);
        }
        console.log(TAG, `result: AccessTokenResult: ${result.data.access_token}`);
      } else {
        console.log(TAG, `HTTP Error: ${response.responseCode}`);
      }
    } catch (err) {
      console.log(TAG, `Request Failed: ${err}`);
    }
  }
}


interface AccessTokenResult {
  data: AccessTokenData;
  message: string;
}

interface AccessTokenData {
  access_token: string;
  captcha: string;
  desc_url: string;
  description: string;
  error_code: number;
  expires_in: number;
  log_id: string;
  open_id: string;
  refresh_expires_in: number;
  refresh_token: string;
  scope: string;
}