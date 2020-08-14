import 'package:flutter/material.dart';
import 'package:pangle_flutter/pangle_flutter.dart';
import 'package:pangle_flutter_example/common/constant.dart';

class BannerPage extends StatefulWidget {
  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<BannerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Banner AD'),
      ),
      body: Column(
        children: <Widget>[
          BannerView(
            iOS: IOSBannerAdConfig(
              slotId: kBannerExpressId,
              imgSize: PangleImgSize.banner600_300,
              isExpress: true,
            ),
            android: AndroidBannerAdConfig(
              slotId: kBannerExpressId,
              imgSize: PangleImgSize.banner600_300,
              isExpress: true,
            ),
          ),
          BannerView(
            iOS: IOSBannerAdConfig(
              slotId: kBannerExpressId,
              imgSize: PangleImgSize.banner600_300,
              isExpress: true,
            ),
            android: AndroidBannerAdConfig(
              slotId: kBannerExpressId,
              imgSize: PangleImgSize.banner600_150,
              isExpress: true,
            ),
          ),
          BannerView(
            iOS: IOSBannerAdConfig(
              slotId: kBannerExpressId,
              imgSize: PangleImgSize.banner600_300,
              isExpress: true,
            ),
            android: AndroidBannerAdConfig(
              slotId: kBannerExpressId,
              imgSize: PangleImgSize.banner600_260,
              isExpress: true,
            ),
          ),
        ],
      ),
    );
  }
}
