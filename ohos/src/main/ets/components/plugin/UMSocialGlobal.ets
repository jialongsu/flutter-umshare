export class UMSocialGlobal {
  private static instance: UMSocialGlobal
  // qq
  public qqUniversalLink: string = '';
  public qqAppKey: string = '';
  public qqAppSecret: string = '';
  // byte
  public byteDanceAppKey: string = '';
  public byteDanceAppSecret: string = '';
  public byteDanceRedirectUrl: string = '';
  // sina
  public sinaWeiboAppKey: string = '';
  public sinaWeiboAppSecret: string = '';
  public redirectUrl: string = '';
  // dingding
  public dingDingAppKey: string = '';
  // alipay
  public aliPayAppKey: string = '';

  public static getInstance(): UMSocialGlobal {
    if (!UMSocialGlobal.instance) {
      UMSocialGlobal.instance = new UMSocialGlobal();
    }
    return UMSocialGlobal.instance;
  }
}