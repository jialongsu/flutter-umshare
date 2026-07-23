/*
 * @Author: Arno.su
 * @Date: 2021-04-27 14:36:24
 * @LastEditors: Arno.su
 * @LastEditTime: 2022-10-26 14:18:58
 */
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:umshare/umshare.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _platformVersion = 'Unknown';
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await Umshare.init("60519766b8c8d45c13a16fa0");
      // await Umshare.platformConfig([
      //   UmInitWeiBo(
      //     appKey: 'appKey',
      //     appSecret: 'appSecret',
      //     redirectUrl: 'https://sns.whalecloud.com/sina2/callback',
      //   ),
      //   UmInitDouYin(
      //     appKey: 'appKey',
      //     appSecret: 'appSecret',
      //   ),
      // ]);
      await Umshare.platformConfig([
        UmInitWeiBo(
          appKey: 'appKey',
          appSecret: 'appSecret',
          redirectUrl: 'https://sns.whalecloud.com/sina2/callback',
        ),
        UmInitAliPay(
          appKey: 'appKey',
        ),
        UmInitDingDing(
          appKey: 'appKey',
        ),
        UmInitDouYin(
          appKey: 'awyaxo8a90dogqyf',
          appSecret: '33e83f060a13a24a599c5a5559d83927',
          redirectUrl: 'https://demo.910728.xyz/path',
        )
      ]);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: RepaintBoundary(
            key: _globalKey,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              child: Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      await Umshare.init('appKey',
                          channel: 'umengshare', logEnabled: true);
                      print('========初始化========');
                    },
                    child: Text('init'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Umshare.platformConfig([
                        UmInitWeiBo(
                          appKey: 'appKey',
                          appSecret: 'appSecret',
                          redirectUrl:
                              'https://sns.whalecloud.com/sina2/callback',
                        ),
                        UmInitAliPay(
                          appKey: 'appKey',
                        ),
                        UmInitDingDing(
                          appKey: 'appKey',
                        ),
                        UmInitDouYin(
                          appKey: 'awyaxo8a90dogqyf',
                          appSecret: '33e83f060a13a24a599c5a5559d83927',
                          redirectUrl: 'https://miniapp.livelab.com.cn/path',
                        )
                      ]);
                    },
                    child: Text('platformConfig'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // var res = await Umshare.share(UmShareWebModel(
                      //   'https://www.baidu.com',
                      //   UmShareMedia.weiBo,
                      //   title: 'demo',
                      //   text: 'test-----',
                      //   img: 'https://dss1.bdstatic.com/kvoZeXSm1A5BphGlnYG/skin_zoom/320.jpg',
                      // ));
                      // print('========结果=========$res');

                      // var res = await Umshare.share(UmShareHttpImgModel(
                      //   'https://dss1.bdstatic.com/kvoZeXSm1A5BphGlnYG/skin_zoom/320.jpg',
                      //   UmShareMedia.qq,
                      //   text: 'test-----',
                      // ));
                      // print('========结果=========$res');

                      var res = await Umshare.share(UmShareFileImgModel(
                        'https://dss1.bdstatic.com/kvoZeXSm1A5BphGlnYG/skin_zoom/320.jpg',
                        UmShareMedia.weiBo,
                        title: 'test-----',
                      ));
                      print('========结果=========$res');
                    },
                    child: Text('分享'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        var res = await Umshare.auth(UmShareMedia.douYin);
                        print('========登录====res=======$res');
                      } catch (e) {
                        print('========登录====error=======$e');
                      }
                    },
                    child: Text('登录抖音'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        var res = await Umshare.auth(UmShareMedia.weiBo);
                        print('========登录====res=======$res');
                      } catch (e) {
                        print('========登录====error=======$e');
                      }
                    },
                    child: Text('登录微博'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var checkInstallRes =
                          await Umshare.checkInstall(UmShareMedia.weiBo);
                      print(checkInstallRes["isInstall"]);
                      print(
                          '========检查是否安装应用====douYin=======${await Umshare.checkInstall(UmShareMedia.douYin)}');
                      print(
                          '========检查是否安装应用====qq=======${await Umshare.checkInstall(UmShareMedia.qq)}');
                      print(
                          '========检查是否安装应用====weiBo=======${await Umshare.checkInstall(UmShareMedia.weiBo)}');
                      print(
                          '========检查是否安装应用====dingDing=======${await Umshare.checkInstall(UmShareMedia.dingDing)}');
                      print(
                          '========检查是否安装应用====aliPay=======${await Umshare.checkInstall(UmShareMedia.aliPay)}');
                    },
                    child: Text('检查是否安装应用'),
                  ),
                  TextButton(
                    onPressed: () async {
                      String localPath = await downloadAndSaveImage(
                          'https://dss1.bdstatic.com/kvoZeXSm1A5BphGlnYG/skin_zoom/320.jpg');
                      print(localPath);
                      var res = await Umshare.share(UmShareFileImgModel(
                        localPath,
                        UmShareMedia.weiBo,
                        title: 'test-----',
                      ));
                      print('========结果=========$res');
                    },
                    child: Text('先下载压缩后分享'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        String localPath = await downloadAndSaveImage(
                            'https://dss1.bdstatic.com/kvoZeXSm1A5BphGlnYG/skin_zoom/326.jpg');
                        print(localPath);
                        var res = await Umshare.share(UmShareFileImgModel(
                          localPath,
                          UmShareMedia.weiBo,
                          title: 'test-----',
                        ));
                        print('========结果=========$res');
                      } catch (e) {
                        print('下载图片失败: $e');
                      }
                    },
                    child: Text('分享网络图片'),
                  ),
                  TextButton(
                    onPressed: () async {
                      RenderRepaintBoundary boundary =
                          _globalKey.currentContext!.findRenderObject()
                              as RenderRepaintBoundary;
                      ui.Image image = await boundary.toImage(
                          pixelRatio: View.of(context).devicePixelRatio);
                      ByteData byteData = await image.toByteData(
                          format: ui.ImageByteFormat.png) as ByteData;
                      Uint8List pngBytes = byteData.buffer.asUint8List();
                      File file =
                          await saveToLocal(pngBytes, 'shareTicket.png');
                      Umshare.share(UmShareFileImgModel(
                        file.path,
                        UmShareMedia.weiBo,
                        title: 'test-----',
                      ));
                    },
                    child: Text('分享截图'),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

Future<String> downloadAndSaveImage(String imageUrl) async {
  print("-------downloadAndSaveImage---------");
  // 获取临时目录
  final dir = await getTemporaryDirectory();
  print(dir.path);
  // 获取图片文件名
  final fileName = path.basename(imageUrl);
  // 拼接本地文件路径
  final filePath = path.join(dir.path, fileName);
  // 下载图片
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode == 200) {
    Uint8List bytes = await compressImage(response.bodyBytes);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file.path;
  } else {
    throw Exception('图片下载失败');
  }
}

Future<Uint8List> compressImage(Uint8List imageBytes) async {
  Uint8List originalBytes = imageBytes;
  int currentSizeKb = originalBytes.lengthInBytes ~/ 1024;
  int maxKb = 90;
  Uint8List bytes = originalBytes;

  if (currentSizeKb >= maxKb && Platform.isOhos) {
    int estimatedQuality = (maxKb / currentSizeKb * 100).toInt();
    estimatedQuality = estimatedQuality.clamp(10, 90);
    bytes = await FlutterImageCompress.compressWithList(
      originalBytes,
      format: CompressFormat.jpeg,
      quality: estimatedQuality,
    );

    int quality = 90;
    while (bytes.lengthInBytes >= maxKb * 1024 && quality > 10) {
      quality -= 20;
      bytes = await FlutterImageCompress.compressWithList(
        originalBytes,
        format: CompressFormat.jpeg,
        quality: quality,
      );
    }
  }
  return bytes;
}

///保存在本地缓存
Future<File> saveToLocal(List<int> bytes, String name) async {
  File saveFile;
  Directory saveDir = await path_provider.getApplicationDocumentsDirectory();
  saveFile = File(path.join(saveDir.path, name));
//    if (!saveFile.existsSync()) {
  saveFile.createSync(recursive: true);
  saveFile.writeAsBytesSync(bytes, flush: true);
//    }
  return saveFile;
}
