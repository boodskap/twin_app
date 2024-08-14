import 'package:flutter/material.dart';
import 'package:twin_app/widgets/twinsys_config_widget.dart';
import 'package:twin_commons/core/twin_image_helper.dart';

class FontsAndColorSettingPage extends StatefulWidget {
  const FontsAndColorSettingPage({super.key});

  @override
  State<FontsAndColorSettingPage> createState() =>
      _FontsAndColorSettingPageState();
}

class _FontsAndColorSettingPageState extends State<FontsAndColorSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: TwinSysConfigWidget(
              onBannerUpload: () async {
                return TwinImageHelper.uploadDomainBanner();
              },
              onImageUpload: () async {
                return TwinImageHelper.uploadDomainImage();
              },
              onIconUpload: () async {
                return TwinImageHelper.uploadDomainIcon();
              },
            ),
          ),
        ],
      ),
    );
  }
}
