/*
 * @Author: Arno.su
 * @Date: 2021-04-27 14:36:24
 * @LastEditors: Arno.su
 * @LastEditTime: 2022-10-26 14:18:58
 */
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:umshare/umshare.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _platformVersion = 'Unknown';

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
      await Umshare.init('6049a5076ee47d382b7c2e31');
      await Umshare.platformConfig([
        UmInitWeiBo(
          appKey: '3336474302',
          appSecret: '37f2e80d470f49b0301aa6a31e0700ea',
          redirectUrl: 'https://sns.whalecloud.com/sina2/callback',
        ),
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
          body: Column(
            children: [
              Center(
                child: Text('Running ---on: $_platformVersion\n'),
              ),
              TextButton(
                onPressed: () async {
                  var res = await Umshare.share(UmShareWebModel(
                    'https://www.baidu.com',
                    UmShareMedia.weiBo,
                    title: 'demo',
                    text: 'test-----',
                    img: 'https://avatar.csdnimg.cn/0/6/4/3_unhappy_long.jpg',
                  ));
                  print('========结果=========$res');
                },
                child: Text('分享'),
              ),
              TextButton(
                onPressed: () async {
                  var res = await Umshare.auth(UmShareMedia.dingDing);
                  print('========登录====res=======$res');
                },
                child: Text('登录'),
              ),
              TextButton(
                onPressed: () async {
                  var res = await Umshare.checkInstall(UmShareMedia.dingDing);
                  print('========检查是否安装应用====dingDing=======$res');
                },
                child: Text('检查是否安装应用'),
              ),
            ],
          )),
    );
  }
}
