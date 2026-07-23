import { ImageKnife } from '@ohos/imageknife'
import { FileUtil } from './FileUtil';
import { PreviewUtil } from './PreviewUtil';
import fs from '@ohos.file.fs';
import { resourceManager } from '@kit.LocalizationKit';
import { image } from '@kit.ImageKit';
import { DateUtil } from './DateUtil';

export async function downloadAndCompressImage(url: string): Promise<string> {
  let localPath = await ImageKnife.getInstance().preLoadCache(url);
  return localPath;
}

export async function compressImage(localPath: string): Promise<string> {
  return ImageUtil.compressPhoto(localPath, 5000, "image/jpeg");
}

export class ImageUtil {
  /**
   * 创建图片源实例
   * @param src（联合类型: string、number、ArrayBuffer、resourceManager.RawFileDescriptor）
   *   path string 图片路径，当前仅支持应用沙箱路径。当前支持格式有：.jpg .png .gif .bmp .webp RAW SVG10+ .ico11+。
   *   fd  number 文件描述符fd。
   *   buf  ArrayBuffer  图像缓冲区数组。
   *   rawfile resourceManager.RawFileDescriptor 图像资源文件的RawFileDescriptor。
   * options SourceOptions  图片属性，包括图片像素密度、像素格式和图片尺寸。
   *   sourceDensity  number ImageSource的密度。
   *   sourcePixelFormat  PixelMapFormat 图片像素格式。
   *   sourceSize  Size 图像像素大小。
   * @returns
   */
  static createImageSource(src: string | number | ArrayBuffer | resourceManager.RawFileDescriptor,
    options?: image.SourceOptions): image.ImageSource {
    if (typeof src === 'string') {
      if (options) {
        return image.createImageSource(src, options);
      } else {
        return image.createImageSource(src);
      }
    } else if (typeof src === 'number') {
      if (options) {
        return image.createImageSource(src, options);
      } else {
        return image.createImageSource(src);
      }
    } else if (src instanceof ArrayBuffer) {
      if (options) {
        return image.createImageSource(src, options);
      } else {
        return image.createImageSource(src);
      }
    } else {
      if (options) {
        return image.createImageSource(src, options);
      } else {
        return image.createImageSource(src);
      }
    }
  }


  /**
   * packing压缩
   * @param sourcePixelMap：原始待压缩图片的PixelMap
   * @param imageQuality：图片质量参数
   * @param imageFormat：当前只支持"image/jpeg"、"image/webp"、"image/png"和"image/heif"12+（不同硬件设备支持情况不同）。
   * @returns data：返回压缩后的图片数据
   */
  static async packing(sourcePixelMap: image.PixelMap, imageQuality: number,
    imageFormat: string = "image/jpeg"): Promise<ArrayBuffer> {
    const imagePackerApi = image.createImagePacker();
    const packOpts: image.PackingOption = { format: imageFormat, quality: imageQuality };
    const data: ArrayBuffer = await imagePackerApi.packing(sourcePixelMap, packOpts);
    imagePackerApi.release()
    return data;
  }

  /**
   * packing二分方式循环压缩
   * @param compressedImageData：图片压缩的ArrayBuffer
   * @param sourcePixelMap：原始待压缩图片的PixelMap
   * @param maxCompressedImageByte：压缩目标图像字节长度
   * @param imageQuality：图片质量参数
   * @param imageFormat：当前只支持"image/jpeg"、"image/webp"、"image/png"和"image/heif"12+（不同硬件设备支持情况不同）。
   * @returns compressedImageData：返回二分packing压缩后的图片数据
   */
  static async packingImage(compressedImageData: ArrayBuffer, sourcePixelMap: image.PixelMap,
    maxCompressedImageByte: number,
    imageQuality: number, imageFormat: string = "image/jpeg"): Promise<ArrayBuffer> {
    //图片质量参数范围为0-100，这里以10为最小二分单位创建用于packing二分图片质量参数的数组。
    const packingArray: number[] = [];
    const DICHOTOMY_ACCURACY = 10;
    //性能知识点: 如果对图片压缩质量要求不高，建议调高最小二分单位dichotomyAccuracy，减少循环，提升packing压缩性能。
    for (let i = 0; i <= 100; i += DICHOTOMY_ACCURACY) {
      packingArray.push(i);
    }
    let left = 0;
    let right = packingArray.length - 1;
    //二分压缩图片
    while (left <= right) {
      const mid = Math.floor((left + right) / 2);
      imageQuality = packingArray[mid];
      //根据传入的图片质量参数进行packing压缩，返回压缩后的图片文件流数据。
      compressedImageData = await ImageUtil.packing(sourcePixelMap, imageQuality, imageFormat);
      //判断查找一个尽可能接近但不超过压缩目标的压缩大小
      if (compressedImageData.byteLength <= maxCompressedImageByte) {
        left = mid + 1;
        if (mid === packingArray.length - 1) {
          break;
        }
        //获取下一次二分的图片质量参数（mid+1）压缩的图片文件流数据
        compressedImageData = await ImageUtil.packing(sourcePixelMap, packingArray[mid + 1], imageFormat);
        //判断用下一次图片质量参数（mid+1）压缩的图片大小是否大于指定图片的压缩目标大小。如果大于，说明当前图片质量参数（mid）压缩出来的图片大小最接近指定图片的压缩目标大小。传入当前图片质量参数mid，得到最终目标图片压缩数据。
        if (compressedImageData.byteLength > maxCompressedImageByte) {
          compressedImageData = await ImageUtil.packing(sourcePixelMap, packingArray[mid], imageFormat);
          break;
        }
      } else {
        //目标值不在当前范围的右半部分，将搜索范围的右边界向左移动，以缩小搜索范围并继续在下一次迭代中查找左半部分。
        right = mid - 1;
      }
    }
    return compressedImageData;
  }

  /**
   * 图片压缩
   * @param sourcePixelMap：原始待压缩图片的PixelMap对象
   * @param maxSize：指定图片的压缩目标大小，单位kb
   * @param imageFormat：当前只支持"image/jpeg"、"image/webp"、"image/png"和"image/heif"12+（不同硬件设备支持情况不同）。
   * @returns compressedImageData：返回压缩后的图片数据
   */
  static async compressedImage(sourcePixelMap: image.PixelMap, maxImgSize: number,
    imageFormat: string = "image/jpeg"): Promise<ArrayBuffer> {
    const imagePackerApi = image.createImagePacker(); //创建图像编码ImagePacker对象
    const IMAGE_QUALITY = 0;
    const packOpts: image.PackingOption = { format: imageFormat, quality: IMAGE_QUALITY };
    //通过PixelMap进行编码。compressedImageData为打包获取到的图片文件流。
    let compressedImageData: ArrayBuffer = await imagePackerApi.packing(sourcePixelMap, packOpts);
    const maxCompressedImageByte = maxImgSize * 1024; //压缩目标图像字节长度
    //图片压缩。先判断设置图片质量参数quality为0时，packing能压缩到的图片最小字节大小是否满足指定的图片压缩大小。如果满足，则使用packing方式二分查找最接近指定图片压缩目标大小的quality来压缩图片。如果不满足，则使用scale对图片先进行缩放，采用while循环每次递减0.4倍缩放图片，再用packing（图片质量参数quality设置0）获取压缩图片大小，最终查找到最接近指定图片压缩目标大小的缩放倍数的图片压缩数据。
    if (maxCompressedImageByte > compressedImageData.byteLength) {
      //使用packing二分压缩获取图片文件流
      compressedImageData =
        await ImageUtil.packingImage(compressedImageData, sourcePixelMap, maxCompressedImageByte, IMAGE_QUALITY,
          imageFormat);
    } else {
      //使用scale对图片先进行缩放，采用while循环每次递减0.4倍缩放图片，再用packing（图片质量参数quality设置0）获取压缩图片大小，最终查找到最接近指定图片压缩目标大小的缩放倍数的图片压缩数据
      let imageScale = 1;
      const REDUCE_SCALE = 0.4;
      //判断压缩后的图片大小是否大于指定图片的压缩目标大小，如果大于，继续降低缩放倍数压缩。
      while (compressedImageData.byteLength > maxCompressedImageByte) {
        if (imageScale > 0) {
          //性能知识点: 由于scale会直接修改图片PixelMap数据，所以不适用二分查找scale缩放倍数。这里采用循环递减0.4倍缩放图片，来查找确定最适合的缩放倍数。如果对图片压缩质量要求不高，建议调高每次递减的缩放倍数reduceScale，减少循环，提升scale压缩性能。
          imageScale = imageScale - REDUCE_SCALE;
          await sourcePixelMap.scale(imageScale, imageScale);
          compressedImageData = await ImageUtil.packing(sourcePixelMap, IMAGE_QUALITY, imageFormat);
        } else {
          //imageScale缩放小于等于0时，没有意义，结束压缩。这里不考虑图片缩放倍数小于reduceScale的情况。
          break;
        }
      }
    }
    imagePackerApi.release();
    return compressedImageData;
  }


  /**
   * 图片压缩，返回压缩后的图片文件路径
   * @param uri：原始待压缩图片的PixelMap对象
   * @param maxSize：指定图片的压缩目标大小，单位kb
   * @param imageFormat：当前只支持"image/jpeg"、"image/webp"、"image/png"和"image/heif"12+（不同硬件设备支持情况不同）。
   * @returns filePath：返回文件压缩路径
   */
  static async compressPhoto(uri: string, maxSize: number, imageFormat?: string): Promise<string> {
    imageFormat = imageFormat ?? PreviewUtil.getMimeType(FileUtil.getFileExtention(uri));
    let srcFile = await FileUtil.open(uri, fs.OpenMode.READ_ONLY);
    let pixelMap = await ImageUtil.createImageSource(srcFile.fd).createPixelMap();
    let arrayBuffer = await ImageUtil.compressedImage(pixelMap, maxSize, imageFormat); //压缩
    let filePath = FileUtil.getTempDirPath(DateUtil.getTodayStr("yyyy-MM-dd"), srcFile.name);
    await FileUtil.writeEasy(filePath, arrayBuffer, false); //写入文件
    FileUtil.closeSync(srcFile.fd); //关闭文件
    pixelMap.release(); //释放资源
    return filePath; //返回文件压缩路径
  }
}