enum UmShareMedia {
  qq,
  qZone,
  weiBo,
  aliPay,
  dingDing,
  douYin,
}

class Utils {
  static int getPlatform(UmShareMedia shareMedia) {
    switch (shareMedia) {
      case UmShareMedia.qq:
        return 0;
      case UmShareMedia.qZone:
        return 4;
      case UmShareMedia.weiBo:
        return 1;
      case UmShareMedia.aliPay:
        return 28;
      case UmShareMedia.dingDing:
        return 32;
      case UmShareMedia.douYin:
        return 34;
      default:
        return 0;
    }
  }

  static UmShareMedia getShareMedia(int shareMedia) {
    switch (shareMedia) {
      case 0:
        return UmShareMedia.qq;
      case 1:
        return UmShareMedia.weiBo;
      case 4:
        return UmShareMedia.qZone;
      case 28:
        return UmShareMedia.aliPay;
      case 32:
        return UmShareMedia.dingDing;
      case 34:
        return UmShareMedia.douYin;
      default:
        return UmShareMedia.qq;
    }
  }
}
