import { BaseResp, IDDAPIEventHandler, BaseReq, SendMessageToDD, ErrCode, DDShareApi } from "@dingtalk/ddsharesdk"
import { promptAction } from '@kit.ArkUI';

export class DDApiEventHandlerImpl implements IDDAPIEventHandler {

  onReq(req: BaseReq): void {
    console.log("DDTag 来自钉钉的请求");
  }

  onResp(resp: BaseResp): void {
    let errCode = resp.mErrCode;
    if (resp instanceof SendMessageToDD.Resp) {
      switch (errCode) {
        case ErrCode.ERR_OK:
          promptAction.showToast({
            message: "分享成功",
            duration: 2000
          })
          break;
        case ErrCode.ERR_USER_CANCEL:
          promptAction.showToast({
            message: "分享取消",
            duration: 2000
          })
          break;
        default :
          promptAction.showToast({
            message: "分享失败",
            duration: 2000
          })
          break;
      }
    }
  }
}

export const DDEventHandle = new DDApiEventHandlerImpl();
