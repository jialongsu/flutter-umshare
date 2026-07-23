export class RegexUtil {
  /**
   * 数字
   */
  static readonly REG_NUMBERS: string = "^\\d+$";

  /**
   * 检查字符串是否只包含数字字符
   * @param str - 要检查的字符串
   * @returns 如果字符串只包含数字则返回 true，否则返回 false
   */
  static isDigits(str: string): boolean {
    if (typeof str !== 'string' || str.length === 0) {
      return false;
    }
    return RegexUtil.isMatch(str, RegexUtil.REG_NUMBERS);
  }

  /**
   * 给定内容是否匹配正则（配合RegexUtil里的正则常量一起使用）
   * @param content 内容
   * @param regex  正则
   */
  static isMatch(content: string, regex: RegExp | string): boolean {
    if (content === undefined || content === null) {
      return false;
    } else {
      if (typeof regex === 'string') {
        return new RegExp(regex).test(content);
      } else {
        return regex.test(content);
      }
    }
  }


}