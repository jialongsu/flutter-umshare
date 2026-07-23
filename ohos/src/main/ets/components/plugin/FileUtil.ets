import { StrUtil } from "./StrUtil";
import fs, { ListFileOptions, ReadOptions, ReadTextOptions, WriteOptions } from '@ohos.file.fs';


export class FileUtil {
  static readonly separator: string = '/';

  /**
   * 根据文件名获取文件后缀
   * @param fileName 例如: test.txt  test.doc
   * @returns
   */
  static getFileExtention(fileName: string) {
    if (StrUtil.isNotEmpty(fileName) && fileName.includes(".")) {
      return fileName.substring(fileName.lastIndexOf(".") + 1);
    }
    return '';
  }

  /**
   * 打开文件，支持使用URI打开文件。使用Promise异步回调。
   * @param path string 文件的应用沙箱路径或URI。
   * @param mode number 打开文件的选项，必须指定如下选项中的一个，默认以只读方式打开。
   * @returns
   */
  static open(path: string, mode: number = fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE): Promise<fs.File> {
    return fs.open(path, mode);
  }

  /**
   * 关闭文件，以同步方法。
   * @param file 已打开的File对象或已打开的文件描述符fd。
   */
  static closeSync(file: fs.File | number) {
    fs.closeSync(file);
  }

  /**
   * 打开文件，支持使用URI打开文件。以同步方法。
   * @param path string 文件的应用沙箱路径或URI。
   * @param mode number 打开文件的选项，必须指定如下选项中的一个，默认以只读方式打开。
   * @returns
   */
  static openSync(path: string, mode: number = fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE): fs.File {
    return fs.openSync(path, mode);
  }


  /**
   * 获取临时目录下的文件夹路径或文件路径。
   * @param dirPath 文件路径；支持完整路径和相对路径（download/wps/doc）；dirPath传空字符串表示根目录
   * @param fileName 文件名（test.text）；fileName传空字符串表示文件夹路径
   * @param blHap true：HAP级别文件路径、 false：App级别文件路径
   * @returns
   */
  static getTempDirPath(dirPath: string = "", fileName: string = "", blHap: boolean = true): string {
    let filePath = blHap ? getContext().tempDir : getContext().getApplicationContext().tempDir; //根目录
    if (StrUtil.isNotEmpty(dirPath)) {
      if (FileUtil.hasDirPath(dirPath)) { //路径中包含根目录，是完整路径。
        filePath = dirPath;
      } else { //路径中不包含根目录，拼接成完整路径。
        filePath = filePath + FileUtil.separator + dirPath;
      }
      if (!FileUtil.accessSync(filePath)) {
        FileUtil.mkdirSync(filePath); //如果文件夹不存在就创建
      }
    }
    if (StrUtil.isNotEmpty(fileName)) {
      filePath = filePath + FileUtil.separator + fileName;
    }
    return filePath;
  }

  /**
   * 创建目录以同步方法，当recursion指定为true，可多层级创建目录。
   * @param path 目录的应用沙箱路径。
   * @param recursion 是否多层级创建目录。recursion指定为true时，可多层级创建目录。recursion指定为false时，仅可创建单层目录。
   */
  static mkdirSync(path: string, recursion: boolean = true) {
    if (recursion) {
      fs.mkdirSync(path, recursion);
    } else {
      fs.mkdirSync(path);
    }
  }

  /**
   * 检查文件是否存在，以同步方法。
   * @param path 文件应用沙箱路径。
   * @returns
   */
  static accessSync(path: string): boolean {
    return fs.accessSync(path);
  }


  /**
   * 获取文件详细属性信息，以同步方法。
   * @param file string|number 文件应用沙箱路径path或已打开的文件描述符fd。
   * @returns
   */
  static statSync(file: string | number): fs.Stat {
    return fs.statSync(file);
  }


  /**
   * 判断是否是完整路径
   * @param path 文件路径
   */
  static hasDirPath(path: string): boolean {
    return StrUtil.startsWith(path, "/data/storage/") || StrUtil.startsWith(path, "/storage/");
  }


  /**
   * 将数据写入文件，使用Promise异步回调。
   * @param fd number 已打开的文件描述符。
   * @param buffer ArrayBuffer|string 待写入文件的数据，可来自缓冲区或字符串。
   * @param options 支持如下选项：
   *                 offset，number类型，表示期望写入文件的位置。可选，默认从当前位置开始写。
   *                 length，number类型，表示期望写入数据的长度。可选，默认缓冲区长度。
   *                 encoding，string类型，当数据是string类型时有效，表示数据的编码方式，默认 'utf-8'。当前仅支持 'utf-8'。
   * @returns Promise对象。返回实际写入的数据长度，单位字节。
   */
  static write(fd: number, buffer: ArrayBuffer | string, options?: WriteOptions): Promise<number> {
    return fs.write(fd, buffer, options)
  }

  /**
   * 关闭文件，使用Promise异步回调。
   * @param file 已打开的File对象或已打开的文件描述符fd。
   * @returns
   */
  static close(file: fs.File | number): Promise<void> {
    return fs.close(file);
  }

  /**
   * 将数据写入文件，并关闭文件。
   * @param path string 文件的应用沙箱路径或URI。
   * @param buffer ArrayBuffer|string 待写入文件的数据，可来自缓冲区或字符串。
   * @param append 是否追加，true-追加，false-不追加（直接覆盖）
   * @returns Promise对象。返回实际写入的数据长度，单位字节。
   */
  static async writeEasy(path: string, buffer: ArrayBuffer | string, append: boolean = true): Promise<number> {
    const file = FileUtil.openSync(path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    const offset = append ? FileUtil.statSync(file.fd).size : 0
    const options: WriteOptions = { offset: offset, encoding: 'utf-8' };
    let result = await FileUtil.write(file.fd, buffer, options);
    FileUtil.close(file.fd); //关闭文件
    return result;
  }
}