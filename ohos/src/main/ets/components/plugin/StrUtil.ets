/*
 * Copyright (C) 2024 桃花镇童长老 @pura/harmony-utils
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import util from '@ohos.util';
// import { buffer } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';


/**
 * TODO 字符串工具类
 * author: 桃花镇童长老ᥫ᭡
 * since: 2024/05/01
 */
export class StrUtil {


  /**
   * 判断字符串是否为空(undefined、null)
   * @param str 被检测的字符串
   * @returns 是否为空
   */
  static isNull(str: string | number | undefined | null): boolean {
    return str === undefined || str === null;
  }

  /**
   * 判断字符串是否为非空。true为非空空，否则false
   * @param str
   * @returns
   */
  static isNotNull(str: string | number | undefined | null): boolean {
    return false === StrUtil.isNull(str);
  }


  /**
   * 判断字符串是否为空(undefined、null、字符串长度为0)
   * @param str 被检测的字符串
   * @return 是否为空
   */
  static isEmpty(str: string | undefined | null): boolean {
    return str === undefined || str === null || str.length === 0;
  }

  /**
   * 判断字符串是否为非空。true为非空空，否则false
   * @param str
   * @returns
   */
  static isNotEmpty(str: string | undefined | null): boolean {
    return false === StrUtil.isEmpty(str);
  }


  /**
   * 判断字符串是否为空和空白符(空白符包括空格、制表符、全角空格和不间断空格)。true为空，否则false
   * @param str
   * @returns
   */
  static isBlank(str: string | undefined | null): boolean {
    if ((str === undefined) || (str === null)) {
      return true;
    }
    let trimStr = StrUtil.trimAll(str);
    return trimStr.length === 0;
  }

  /**
   * 判断字符串是否为非空和空白符(空白符包括空格、制表符、全角空格和不间断空格)true为非空，否则false
   * @param str
   * @returns
   */
  static isNotBlank(str: string | undefined | null): boolean {
    return false === StrUtil.isBlank(str);
  }


  /**
   * 去除字符串两端的空格
   * @param str
   * @returns
   */
  static trim(str: string): string {
    return str.trim();
  }

  /**
   * 去除字符串里的所有空格
   * @param str
   * @returns
   */
  static trimAll(str: string): string {
    return str.replace(/\s/g,"");
  }


  /**
   * 格式化字符串
   * @param source
   * @param defaultValue
   * @returns
   */
  static toStr(source: number | boolean | string | null | undefined, defaultValue = ""): string {
    if (source === null || source === undefined) {
      return defaultValue;
    }
    return String(source);
  }


  /**
   * 替换字符串中匹配的正则为给定的字符串
   * @param str   待替换的字符串
   * @param pattern  要匹配的内容正则或字符串
   * @param replaceValue 替换的内容
   * @returns
   */
  static replace(str: string, pattern: RegExp | string, replaceValue: string = ''): string {
    return str.replace(pattern, replaceValue);
  }

  /**
   * 替换字符串中所有匹配的正则为给定的字符串
   * @param str  待替换的字符串
   * @param pattern  要匹配的内容正则或字符串
   * @param replaceValue 替换的内容
   * @returns 返回替换后的字符串
   */
  static replaceAll(str: string, pattern: RegExp | string, replaceValue: string = ''): string {
    return str.replaceAll(pattern, replaceValue);
  }

  /**
   * 判断字符串是否以给定的字符串开头
   * @param string 要检索的字符串
   * @param target 要检索字符
   * @param position 检索的位置
   * @returns
   */
  static startsWith(string: string = '', target: string, position: number = 0): boolean {
    return string.startsWith(target, position);
  }


  /**
   * 判断字符串是否以给定的字符串结尾
   * @param str 要检索的字符串
   * @param target 要检索字符
   * @param position 检索的位置
   * @returns
   */
  static endsWith(str: string = '', target: string, position: number = str.length): boolean {
    return str.endsWith(target, position);
  }


  /**
   * 将字符串重复指定次数
   * @param str  要重复的字符串
   * @param n  重复的次数
   * @returns
   */
  static repeat(str: string = '', n: number = 1): string {
    return str.repeat(n);
  }


  /**
   * 将整个字符串转换为小写
   * @param str 要转换的字符串
   * @returns 返回小写的字符串
   */
  static toLower(str: string = ''): string {
    return str.toLowerCase();
  }


  /**
   * 将整个字符串转换为大写
   * @param str 要转换的字符串
   * @returns 返回小写的字符串
   */
  static toUpper(str: string = ''): string {
    return str.toUpperCase();
  }


  /**
   * 将字符串首字母转换为大写，剩下为小写
   * @param str 待转换的字符串
   * @returns 转换后的
   */
  static capitalize(str: string = ''): string {
    if (StrUtil.isNotEmpty(str)) {
      const firstChar = str.charAt(0).toUpperCase();
      const restChars = str.slice(1).toLowerCase();
      return firstChar + restChars;
    }
    return '';
  }


  /**
   * 判断两个传入的数值或者是字符串是否相等
   * @param source
   * @param target
   * @returns
   */
  static equal(source: string | number, target: string | number): boolean {
    return source === target;
  }

  /**
   * 判断两个传入的数值或者是字符串是否不相等
   * @param source
   * @param target
   * @returns
   */
  static notEqual(source: string | number, target: string | number): boolean {
    return false === StrUtil.equal(source, target);
  }


  /**
   * Bytes转字符串
   * @param bytes
   * @returns
   */
  public static bytesToStr(bytes: Uint8Array): string {
    let str = ""
    for (let i = 0; i < bytes.length; i++) {
      str += String.fromCharCode(bytes[i]);

    }
    return str;
  }

  /**
   * 字符串转Bytes
   * @param str
   * @returns
   */
  public static strToBytes(str: string): Uint8Array {
    let bytes: number[] = new Array();
    for (let i = 0; i < str.length; i++) {
      bytes.push(str.charCodeAt(i))
    }
    return new Uint8Array(bytes);
  }



}
