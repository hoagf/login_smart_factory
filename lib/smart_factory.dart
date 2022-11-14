import 'dart:convert';
import 'dart:io';

import 'package:download_install_apk/download_install_apk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preference_app_group/shared_preference_app_group.dart';
import 'package:token_provider/token_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SmartFactory {
  static const _smartfactoryPackage = 'com.foxconn.fii.smartfactory';
  static const _appGroupTokenSaveKey =
      '_______com.foxconn.fii.smartfactory_______';

  static Future<dynamic> init({required BuildContext context}) async {
    if (Platform.isAndroid) {
      if (await canLaunchUrl(
          Uri(scheme: _smartfactoryPackage, path: '/login/pop'))) {
        final tokenRaw = await TokenProvider().getToken();
        if (tokenRaw != null && tokenRaw.isNotEmpty) {
          return json.decode((tokenRaw));
        }
        launchUrl(
          Uri(
              scheme: _smartfactoryPackage,
              path:
                  '/login/pop/${(await PackageInfo.fromPlatform()).packageName}'),
        );
        SystemNavigator.pop();
      } else {
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Login'),
              content: const Text('Bạn cần cài đặt SmartFactory để tiếp tục'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    SystemNavigator.pop();
                  },
                  child: const Text('Thoát'),
                ),
                TextButton(
                  onPressed: () async {
                    //Navigator.of(context).pop(true);
                    await _showDownloadStatusDialog(context,
                        'https://10.224.81.70:6443/fiistore/ws-data/images/TDB/SmartFactory.apk');
                  },
                  child: const Text('Tải xuống'),
                ),
              ],
            );
          },
        );
      }
    }

    if (Platform.isIOS) {
      if (await canLaunchUrl(
          Uri(scheme: _smartfactoryPackage, path: '/login/pop'))) {
        SharedPreferenceAppGroup.setAppGroup(_smartfactoryPackage);
        final tokenRaw =
            await SharedPreferenceAppGroup.get(_appGroupTokenSaveKey);
        if (tokenRaw != null && tokenRaw.isNotEmpty) {
          return json.decode((tokenRaw));
        }
        launchUrl(
          Uri(
              scheme: _smartfactoryPackage,
              path:
                  '/login/pop/${(await PackageInfo.fromPlatform()).packageName}'),
        );
        SystemNavigator.pop();
      } else {
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Login'),
              content: const Text('Bạn cần cài đặt SmartFactory để tiếp tục'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    SystemNavigator.pop();
                  },
                  child: const Text('Thoát'),
                ),
                TextButton(
                  onPressed: () async {
                    //todo: update link install
                    launchUrl(
                      Uri(
                        scheme: 'link install ios app',
                      ),
                    );
                  },
                  child: const Text('Cài đặt'),
                ),
              ],
            );
          },
        );
      }
    }
    return null;
  }

  static Future<void> _showDownloadStatusDialog(
      BuildContext context, String url) {
    final downloadStream = DownloadInstallApk().execute(
      url,
    );
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
              title: const Text(
                'Tải xuống',
                textAlign: TextAlign.center,
              ),
              content: StreamBuilder<Event>(
                stream: downloadStream,
                builder: (context, snapshot) {
                  if (snapshot.data?.status == Status.installing) {
                    Navigator.of(context).pop();
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Builder(
                        builder: (context) {
                          if (snapshot.data?.status == Status.downloadError) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                    'Đã xảy ra lỗi trong quá trình tải xuống, chi tiết: ${snapshot.data?.value}'),
                                Align(
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        launchUrl(Uri.parse(url),
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                      child: const Text('Mở trong trình duyệt'),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      SystemNavigator.pop();
                                    },
                                    child: const Text('Thoát'),
                                  ),
                                )
                              ],
                            );
                          }
                          return Column(
                            children: [
                              const Text(
                                  'Vui lòng KHÔNG thoát khỏi ứng dụng trong tiến trình này!'),
                              (snapshot.data?.status == Status.downloading)
                                  ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: ((int.tryParse(snapshot
                                                              .data?.value ??
                                                          '0') ??
                                                      0) /
                                                  100),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                '${(snapshot.data?.value ?? 0)}%'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(),
                                    ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Đang tải xuống ${url.split('/').last}',
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                      SystemNavigator.pop();
                                    },
                                    child: const Text('Thoát'),
                                  )
                                ],
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ));
  }

  static Future<void> logout() async {
    await SystemNavigator.pop();
    await launchUrl(
      Uri(scheme: _smartfactoryPackage, path: '/logout'),
    );
  }
}
