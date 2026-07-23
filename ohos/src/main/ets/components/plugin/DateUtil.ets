import { RegexUtil } from "./RegexUtil";

export class DateUtil {
  /**
   * 获取格式化日期，将传入的日期格式化为Date
   * @param date
   * @returns
   */
  static getFormatDate(date?: number | string | Date): Date {
    if (date == undefined || date == null) { //无参数
      date = new Date();
    } else if (typeof date == "string") { //字符串日期
      if (date.length == 0) {
        date = new Date();
      } else if (RegexUtil.isDigits(date)) { //字符串类型的时间戳
        date = new Date(Number(date));
      } else {
        const dateStr = DateUtil.formatDateStr(date);
        date = new Date(dateStr);
      }
    } else if (typeof date == "number") { //时间戳
      if (date.toString().length == 10) {
        date = date * 1000; //如果是10位时间戳转为13位
      }
      date = new Date(date);
    }
    return date;
  }

  /**
   * 格式化日期字符串
   * @param date
   * @returns
   */
  private static formatDateStr(date: string): string {
    let dateStr = date.trim()
      .replaceAll("-", '/')
      .replace("年", '/')
      .replace("月", '/')
      .replace("日", ' ')
      .replace('  ', ' ')
      .replace("时", ':')
      .replace("分", ':')
      .replace("秒", '');
    if (dateStr.endsWith('/') || dateStr.endsWith(':') || dateStr.endsWith(' ')) {
      dateStr = dateStr.substring(0, dateStr.length - 1);
    }
    if (dateStr.length == 13 && dateStr.includes(' ')) {
      dateStr = dateStr + ':00'; //yyyy-MM-dd HH，需要补齐分钟。
    }
    return dateStr;
  }


  /**
   * 获取今天的时间，字符串类型
   * @param format 格式化字符串,(yyyy-MM-dd HH:mm:ss)
   * @returns
   */
  static getTodayStr(format?: string): string {
    return DateUtil.getFormatDateStr(new Date(), format)
  }

  /**
   * 获取格式化日期，将传入的日期格式化为指定格式的字符串
   * @param date
   * @param format 格式化字符串,(yyyy-MM-dd HH:mm:ss)
   * @returns
   */
  static getFormatDateStr(date: number | string | Date, format?: string): string {
    date = DateUtil.getFormatDate(date)
    if (format === undefined || format.length <= 0) {
      format = "yyyy-MM-dd HH:mm:ss";
    }
    let year = date.getFullYear(); //年份，例如 2024
    let month = DateUtil.padZero(date.getMonth() + 1); //月份，0-11，0 表示一月，11 表示十二月
    let day = DateUtil.padZero(date.getDate()); //日期，1-31
    let hours = DateUtil.padZero(date.getHours()); //小时，0-23
    let minutes = DateUtil.padZero(date.getMinutes()); //分钟，0-59
    let seconds = DateUtil.padZero(date.getSeconds()); //秒数，0-59
    let millisecond = date.getMilliseconds(); //毫秒数，0-999
    let formattedDate = format.replace("yyyy", year.toString());
    formattedDate = formattedDate.replace("MM", month);
    formattedDate = formattedDate.replace("dd", day);
    formattedDate = formattedDate.replace("HH", hours);
    formattedDate = formattedDate.replace("mm", minutes);
    formattedDate = formattedDate.replace("ss", seconds);
    formattedDate = formattedDate.replace("fff", millisecond.toString());
    return formattedDate;
  }

  /**
   * 补零操作
   * @param num
   * @returns
   */
  private static padZero(num: number): string {
    return num.toString().padStart(2, "0");
  }
}