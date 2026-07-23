import { uniformTypeDescriptor } from "@kit.ArkData";

export class PreviewUtil {

  /**
 * 根据文件后缀名获取TypeDescriptor（标准化数据类型的描述类）
 * @param fileExtention 文件后缀名，例如：html txt doc ts mp3
 */
  static getTypeDescriptor(fileExtention: string): uniformTypeDescriptor.TypeDescriptor {
    const dataType = uniformTypeDescriptor.getUniformDataTypeByFilenameExtension(`.${fileExtention}`);
    const typeDescriptor = uniformTypeDescriptor.getTypeDescriptor(dataType);
    return typeDescriptor;
  }


  /**
   * 根据文件后缀名获取文件mimeType
   * @param fileExtention 文件后缀名，例如：html txt doc ts mp3
   */
  static getMimeType(fileExtention: string): string {
    const typeDescriptor = PreviewUtil.getTypeDescriptor(fileExtention);
    const mimeTypes = typeDescriptor.mimeTypes;
    if (mimeTypes && mimeTypes.length > 0) {
      return mimeTypes[0];
    } else {
      return '*/*';
    }
  }
}
