package com.arno.umshare;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import com.tencent.tauth.Tencent;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.socialize.PlatformConfig;
import com.umeng.socialize.ShareAction;
import com.umeng.socialize.UMAuthListener;
import com.umeng.socialize.UMShareAPI;
import com.umeng.socialize.UMShareListener;
import com.umeng.socialize.bean.SHARE_MEDIA;
import com.umeng.socialize.common.ResContainer;
import com.umeng.socialize.media.UMImage;
import com.umeng.socialize.media.UMVideo;
import com.umeng.socialize.media.UMWeb;
import com.umeng.socialize.media.UMusic;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener;

/** UmsharePlugin */
public class UmsharePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {

  private Activity ma;
  private Context context;
  private final int SUCCESS = 200;
  private final int ERROR = 0;
  private final int CANCEL = -1;
  private static Handler mSDKHandler = new Handler(Looper.getMainLooper());
  private static void runOnMainThread(Runnable runnable) {
    mSDKHandler.postDelayed(runnable, 0);
  }

  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "umshare");
    channel.setMethodCallHandler(this);
//    UMConfigure.preInit(context, "2456784395", "umengshare");
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    UMShareAPI.get(ma).onActivityResult(requestCode,resultCode,data);
    return true;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    ma = binding.getActivity();
    binding.addActivityResultListener(this);
  }

  @Override
  public void onDetachedFromActivity() {

  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if(call.method.equals("umInit")) {
      umInit(call, result);
    }else if(call.method.equals("platformConfig")) {
      platformConfig(call, result);
    } else if(call.method.equals("umShare")) {
      share(call, result);
    } else if(call.method.equals("umAuth")) {
      auth(call, result);
    } else if(call.method.equals("umCheckInstall")) {
      checkInstall(call, result);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private void umInit(MethodCall call, Result result) {
    Map<String, Object> params = call.arguments();
    Map<String, Object> res = new HashMap<>();
    final String appKey = (String) params.get("appKey");
    final String channel = (String) params.get("channel");
    final Boolean logEnabled = (Boolean) params.get("logEnabled");
    UMConfigure.preInit(context, appKey, "umengshare");
    UMConfigure.init(context, appKey, channel, UMConfigure.DEVICE_TYPE_PHONE,"");
    UMConfigure.setLogEnabled(logEnabled != null ? logEnabled : false);
    res.put("code", "200");
    res.put("msg", "um init success");
    result.success(res);
  }

  private void platformConfig(final MethodCall call, Result result) {
    Map<String, String> config = call.arguments();
    Map<String, Object> res = new HashMap<>();
    String packageName = context.getPackageName();
    String FileProvider = packageName + ".fileprovider";

    //新浪微博
    if(config.containsKey("sinaWeiboAppKey") && config.containsKey("sinaWeiboAppSecret")) {
      String sinaWeiboAppKey = config.get("sinaWeiboAppKey");
      String sinaWeiboAppSecret = config.get("sinaWeiboAppSecret");
      String redirectUrl = config.get("redirectUrl");
      PlatformConfig.setSinaWeibo(sinaWeiboAppKey, sinaWeiboAppSecret, redirectUrl);
      PlatformConfig.setSinaFileProvider(FileProvider);
    }

    //QQ
    if(config.containsKey("qqAppSecret") && config.containsKey("qqAppKey")) {
      String qqAppKey = config.get("qqAppKey");
      String qqAppSecret = config.get("qqAppSecret");
      PlatformConfig.setQQZone(qqAppKey, qqAppSecret);
      PlatformConfig.setQQFileProvider(FileProvider);
      Tencent.setIsPermissionGranted(true);
    }

    //支付宝
    if(config.containsKey("aliPayAppKey")) {
      String aliPayAppKey = config.get("aliPayAppKey");
      PlatformConfig.setAlipay(aliPayAppKey);
    }

    //钉钉
    if(config.containsKey("dingDingAppKey")) {
      String dingDingAppKey = config.get("dingDingAppKey");
      PlatformConfig.setDing(dingDingAppKey);
    }

    //抖音
    if(config.containsKey("byteDanceAppKey") && config.containsKey("byteDanceAppSecret")) {
      String byteDanceAppKey = config.get("byteDanceAppKey");
      String byteDanceAppSecret = config.get("byteDanceAppSecret");
      PlatformConfig.setBytedance(byteDanceAppKey, byteDanceAppKey, byteDanceAppSecret, FileProvider);
    }

    res.put("code", "200");
    res.put("msg", "set platformConfig success");
    result.success(res);
  }

  private void share(final MethodCall call, final Result result){
    Map<String, Object> params = call.arguments();
    final String text = (String) params.get("text");
    final String img = (String)params.get("img");
    final String fileImg = (String) params.get("fileImg");
    final String weburl = (String)params.get("weburl");
    final String title = (String)params.get("title");
    final String videoUrl = (String)params.get("videoUrl");
    final String musicUrl = (String)params.get("musicUrl");
    final int sharemedia = (int) params.get("sharemedia");

    runOnMainThread(new Runnable() {
      @Override
      public void run() {

        if (!TextUtils.isEmpty(weburl)){
          UMWeb web = new UMWeb(weburl);
          web.setTitle(title);
          web.setDescription(text);
          if (getImage(img)!=null){
            web.setThumb(getImage(img));
          }
          new ShareAction(ma).withText(text)
                  .withMedia(web)
                  .setPlatform(getShareMedia(sharemedia))
                  .setCallback(getUMShareListener(result))
                  .share();
        } else if(!TextUtils.isEmpty(videoUrl)) {
          UMVideo video = new UMVideo(videoUrl);
          video.setTitle(title);//视频的标题
          video.setDescription(text);//视频的描述
          if (getImage(img)!=null){
            video.setThumb(getImage(img));
          }
          new ShareAction(ma).withText(text)
                  .withMedia(video)
                  .setPlatform(getShareMedia(sharemedia))
                  .setCallback(getUMShareListener(result))
                  .share();
        } else if(!TextUtils.isEmpty(musicUrl)) {
          UMusic music = new UMusic(musicUrl);
          music.setTitle(title);//音乐的标题
          music.setDescription(text);//音乐的描述
          music.setmTargetUrl(musicUrl);//音乐的跳转链接
          if (getImage(img)!=null){
            music.setThumb(getImage(img));
          }
          new ShareAction(ma).withText(text)
                  .withMedia(music)
                  .setPlatform(getShareMedia(sharemedia))
                  .setCallback(getUMShareListener(result))
                  .share();
        }else if (getImage(img)!=null){
          new ShareAction(ma).withText(title)
                  .withMedia(getImage(img))
                  .setPlatform(getShareMedia(sharemedia))
                  .setCallback(getUMShareListener(result))
                  .share();
        }else if (fileImg != null){
          new ShareAction(ma).withText(title)
                  .withMedia(new UMImage(ma, getImgFromSDRoot(fileImg)))
                  .setPlatform(getShareMedia(sharemedia))
                  .setCallback(getUMShareListener(result))
                  .share();
        }else {
          new ShareAction(ma).withText(text)
                  .setPlatform(getShareMedia(sharemedia))
                  .setCallback(getUMShareListener(result))
                  .share();
        }

      }
    });

  }

  private void auth(final MethodCall call, final Result result){
    final int sharemedia = call.arguments();

    runOnMainThread(new Runnable() {
      @Override
      public void run() {
        UMShareAPI.get(ma).getPlatformInfo(ma, getShareMedia(sharemedia), new UMAuthListener() {
          @Override
          public void onStart(SHARE_MEDIA share_media) {

          }

          @Override
          public void onComplete(SHARE_MEDIA share_media, int i, Map<String, String> map) {
            Map<String, Object> params = new HashMap<>();
            params.put("code", 200);
            params.put("data", map);
            // for (String key:map.keySet()){
            //   params.put(key,map.get(key));
            // }
            result.success(params);
          }

          @Override
          public void onError(SHARE_MEDIA share_media, int i, Throwable throwable) {
            result.error("1", "'error'" ,throwable.getMessage());
          }

          @Override
          public void onCancel(SHARE_MEDIA share_media, int i) {
            result.error("2", "'cancel'" ,"cancel");
          }
        });
      }
    });

  }

  private void checkInstall(final MethodCall call, final Result result) {
    final int sharemedia = call.arguments();

    runOnMainThread(new Runnable() {
      @Override
      public void run() {
        Map<String, Object> params = new HashMap<>();
        boolean isInstall = UMShareAPI.get(ma).isInstall(ma, getShareMedia(sharemedia));
        params.put("code", 200);
        params.put("isInstall", isInstall);
        result.success(params);
      }
    });
  }

  private UMShareListener getUMShareListener(final Result result){
    return new UMShareListener() {
      @Override
      public void onStart(SHARE_MEDIA share_media) {

      }

      @Override
      public void onResult(SHARE_MEDIA share_media) {
        Map<String, Object> res = new HashMap<>();
        res.put("code", SUCCESS);
        res.put("msg", "success");
        result.success(res);
      }

      @Override
      public void onError(SHARE_MEDIA share_media, Throwable throwable) {
        Map<String, Object> res = new HashMap<>();
        res.put("code", ERROR);
        res.put("msg", throwable.getMessage());
        result.success(res);
      }

      @Override
      public void onCancel(SHARE_MEDIA share_media) {
        Map<String, Object> res = new HashMap<>();
        res.put("code", CANCEL);
        res.put("msg", "cancel");
        result.success(res);
      }
    };
  }

  private UMImage getImage(String url){
    if (TextUtils.isEmpty(url)){
      return null;
    }else if(url.startsWith("http")){
      return new UMImage(ma,url);
    }else if(url.startsWith("/")){
      return new UMImage(ma,url);
    }else if(url.startsWith("res")){
      return new UMImage(ma, ResContainer.getResourceId(ma,"drawable",url.replace("res/","")));
    }else {
      return new UMImage(ma,url);
    }
  }

  /**
   * 从本地内存中根据图片名字获取图片
   * @param imgPath  图片路径
   * @return  返回图片的Bitmap格式
   */
  private static Bitmap getImgFromSDRoot(String imgPath) {
    Bitmap bitmap = null;
    int index = imgPath.lastIndexOf("/");
    String imgName = imgPath.substring(index + 1);
    String basePath = imgPath.substring(0, index + 1);
    File file = new File(basePath, imgName);
    try {
      FileInputStream fis = new FileInputStream(file);
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      byte b[] = new byte[1024];
      int len;
      while ((len = fis.read(b)) != -1) {
        baos.write(b, 0, len);
      }
      byte buff[] = baos.toByteArray();
      if (buff != null && buff.length != 0) {
        bitmap = BitmapFactory.decodeByteArray(buff, 0, buff.length);
      }
    } catch (IOException e) {
      e.printStackTrace();
    }
    return bitmap;
  }

  private SHARE_MEDIA getShareMedia(int num){
    switch (num){
      case 1:
        return SHARE_MEDIA.SINA;
      case 2:
        return SHARE_MEDIA.WEIXIN;
      case 3:
        return SHARE_MEDIA.WEIXIN_CIRCLE;
      case 4:
        return SHARE_MEDIA.QZONE;
      case 5:
        return SHARE_MEDIA.EMAIL;
      case 6:
        return SHARE_MEDIA.SMS;
      case 7:
        return SHARE_MEDIA.FACEBOOK;
      case 8:
        return SHARE_MEDIA.TWITTER;
      case 9:
        return SHARE_MEDIA.WEIXIN_FAVORITE;
//      case 10:
//        return SHARE_MEDIA.GOOGLEPLUS;
//      case 11:
//        return SHARE_MEDIA.RENREN;
//      case 12:
//        return SHARE_MEDIA.TENCENT;
      case 13:
        return SHARE_MEDIA.DOUBAN;
      case 14:
        return SHARE_MEDIA.FACEBOOK_MESSAGER;
      case 15:
        return SHARE_MEDIA.YIXIN;
      case 16:
        return SHARE_MEDIA.YIXIN_CIRCLE;
      case 17:
        return SHARE_MEDIA.INSTAGRAM;
      case 18:
        return SHARE_MEDIA.PINTEREST;
      case 19:
        return SHARE_MEDIA.EVERNOTE;
      case 20:
        return SHARE_MEDIA.POCKET;
      case 21:
        return SHARE_MEDIA.LINKEDIN;
      case 22:
        return SHARE_MEDIA.FOURSQUARE;
      case 23:
        return SHARE_MEDIA.YNOTE;
      case 24:
        return SHARE_MEDIA.WHATSAPP;
      case 25:
        return SHARE_MEDIA.LINE;
      case 26:
        return SHARE_MEDIA.FLICKR;
      case 27:
        return SHARE_MEDIA.TUMBLR;
      case 28:
        return SHARE_MEDIA.ALIPAY;
      case 29:
        return SHARE_MEDIA.KAKAO;
      case 30:
        return SHARE_MEDIA.DROPBOX;
      case 31:
        return SHARE_MEDIA.VKONTAKTE;
      case 32:
        return SHARE_MEDIA.DINGTALK;
      case 33:
        return SHARE_MEDIA.MORE;
      case 34:
        return SHARE_MEDIA.BYTEDANCE;
      default:
        return SHARE_MEDIA.QQ;
    }
  }

}
