import { Pay } from "@cashier_alipay/cashiersdk";
import { UMSocialGlobal } from "./UMSocialGlobal";
import { bundleManager } from "@kit.AbilityKit";


export class AliPayHelper {
  static checkInstall(): boolean {
    return bundleManager.canOpenLink('alipays://');
  }

  static aliPay: Pay = new Pay();

  static init() {
    AliPayHelper.aliPay.registerApp(UMSocialGlobal.getInstance().aliPayAppKey)
  }
}