import { DDShareApi, IDDShareApi } from "@dingtalk/ddsharesdk";
import { bundleManager, common } from "@kit.AbilityKit";
import { MethodResult, } from '@ohos/flutter_ohos';
import { ShareParams } from "./ShareParams";
import { UMSocialGlobal } from "./UMSocialGlobal";

export class DingTalkHelper {
  static dingdingApi: IDDShareApi | null = null;

  static checkInstall() : boolean {
    return bundleManager.canOpenLink('dingtalk://');
  }

  static init() {
    DingTalkHelper.dingdingApi = DDShareApi.getInstance(UMSocialGlobal.getInstance().dingDingAppKey);
  }

  static async auth(context: common.UIAbilityContext, result: MethodResult) {

  }

  static async share(context: common.UIAbilityContext, result: MethodResult, shareParams: ShareParams) {

  }

}