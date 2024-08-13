import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twin_app/pages/branding/digital_twin_menu_group_content.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twin_app/core/session_variables.dart';

class LandingWidgetType extends StatefulWidget {
  Load load;
  twinned.TwinSysInfo twinSysInfo;
  twinned.LandingPage landingPage;
  final int index;

  LandingWidgetType({
    super.key,
    required this.load,
    required this.twinSysInfo,
    required this.landingPage,
    required this.index,
  });

  @override
  State<LandingWidgetType> createState() => _LandingWidgetTypeState();
}

class _LandingWidgetTypeState extends BaseState<LandingWidgetType> {
  late Image logoImage;

  // var res = UserSession().selectedOrganization;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _heading = TextEditingController();
  final TextEditingController _subHeading = TextEditingController();
  final TextEditingController _line_1 = TextEditingController();
  final TextEditingController _line_2 = TextEditingController();
  final TextEditingController _line_3 = TextEditingController();
  final TextEditingController _line_4 = TextEditingController();
  final TextEditingController _line_5 = TextEditingController();

  List<Shadow> fontShadow = const [
    Shadow(
      offset: Offset(0, 0),
      color: Colors.grey,
      blurRadius: 1,
    )
  ];

  //*** Heading ***
  String headerFont = 'Acme';
  double headerFontSize = 50;
  Color headerFontColor = Colors.black;
  TextStyle headerStyle = const TextStyle();

  //*** Sub Heading ***
  String subHeaderFont = 'Acme';
  double subHeaderFontSize = 28;
  Color subHeaderFontColor = Colors.black;
  TextStyle subHeaderStyle = const TextStyle();

  //*** Line 1 ***
  String lineFont = 'Acme';
  double lineFontSize = 18;
  Color lineFontColor = Colors.black;
  TextStyle lineStyle = const TextStyle();

  @override
  void initState() {
    logoImage = Image.asset(
      'images/logo-large.png',
      fit: BoxFit.contain,
    );

    twinned.TwinSysInfo info = widget.twinSysInfo!;

    headerFont = info.headerFont ?? headerFont;
    headerFontColor = Color(info.headerFontColor ?? headerFontColor.value);
    headerFontSize = info.headerFontSize ?? headerFontSize;

    subHeaderFont = info.subHeaderFont ?? subHeaderFont;
    subHeaderFontColor =
        Color(info.subHeaderFontColor ?? subHeaderFontColor.value);
    subHeaderFontSize = info.subHeaderFontSize ?? subHeaderFontSize;

    lineFont = info.labelFont ?? lineFont;
    lineFontColor = Color(info.labelFontColor ?? lineFontColor.value);
    lineFontSize = info.labelFontSize ?? lineFontSize;

    headerStyle = GoogleFonts.getFont(
      headerFont,
      fontSize: headerFontSize.toDouble(),
      color: headerFontColor,
    );

    subHeaderStyle = GoogleFonts.getFont(
      subHeaderFont,
      fontSize: subHeaderFontSize.toDouble(),
      color: subHeaderFontColor,
    );

    lineStyle = GoogleFonts.getFont(
      lineFont,
      fontSize: lineFontSize.toDouble(),
      color: lineFontColor,
    );

    _heading.text = widget.landingPage.heading ?? '';
    _subHeading.text = widget.landingPage.subHeading ?? '';
    _line_1.text = widget.landingPage.line1 ?? '';
    _line_2.text = widget.landingPage.line2 ?? '';
    _line_3.text = widget.landingPage.line3 ?? '';
    _line_4.text = widget.landingPage.line4 ?? '';
    _line_5.text = widget.landingPage.line5 ?? '';

    if (widget.landingPage.logoImage!.isNotEmpty) {
      logoImage = TwinImageHelper.getDomainImage(widget.landingPage.logoImage!,
          fit: BoxFit.contain);
    }

    super.initState();
  }

  void _deleteImage(String image) async {
    confirm(
        title: 'Warning',
        titleStyle: theme.getStyle().copyWith(
              color: Colors.red,
            ),
        message: 'Are you sure you want to delete this image?',
        onPressed: () async {
          busy();
          try {
            var res = await TwinnedSession.instance.twin.deleteImage(
                apikey: TwinnedSession.instance.authToken, id: image);

            if (validateResponse(res)) {
              // widget.model!.images!.remove(image);
                logoImage = Image.asset(
          'images/logo-large.png',
          fit: BoxFit.contain,
        );
              setup();
              alert('Image', 'Landing Page image deleted');
            }
          } catch (e, x) {
            debugPrint('$e\n$x');
          }
          busy(busy: false);
        });
  }

  @override
  void setup() async {}

  void _close() {
    Navigator.pop(context);
  }

  Future _save({bool close = false}) async {
    if (loading) return;
    loading = true;
    await execute(() async {
      if (_formKey.currentState!.validate()) {
        var landing = widget.landingPage.copyWith(
          heading: _heading.text,
          subHeading: _subHeading.text,
          line1: _line_1.text,
          line2: _line_2.text,
          line3: _line_3.text,
          line4: _line_4.text,
          line5: _line_5.text,
        );
        widget.twinSysInfo.landingPages![widget.index] = landing;

        var upRes = await TwinnedSession.instance.twin.upsertTwinConfig(
          apikey: TwinnedSession.instance.authToken,
          body: widget.twinSysInfo,
        );

        if (validateResponse(upRes) && close) {
          _close();
          widget.load(true);
        }
      }
    });
    loading = false;
  }

  Future _upload() async {
    if (loading) return;
    loading = true;
    bool uploaded = false;
    await execute(() async {
      var res = await TwinImageHelper.uploadDomainImage();
      if (null != res) {
        widget.landingPage =
            widget.landingPage.copyWith(logoImage: res.entity!.id);
        uploaded = true;
        logoImage = TwinImageHelper.getDomainImage(
            widget.landingPage.logoImage!,
            fit: BoxFit.contain);
      }
    });
    loading = false;
    if (uploaded) {
      await _save();
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const TopBar(title: 'Landing Page'),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.2),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: logoImage,
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Tooltip(
                            message: 'Upload Image',
                            child: IconButton(
                              icon: const Icon(
                                Icons.upload,
                              ),
                              onPressed: () async {
                                await _upload();
                              },
                            ),
                          ),
                        ),
                        if (widget.landingPage.logoImage != null &&
                            widget.landingPage.logoImage!.isNotEmpty)
                          Positioned(
                            top: 10,
                            right: 40,
                            child: Tooltip(
                                message: 'Delete Image',
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                     _deleteImage(widget.landingPage.logoImage!);
                                  },
                                )),
                          )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.2),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: _heading,
                                decoration: InputDecoration(
                                  hintText: 'Enter Heading',
                                  hintStyle: headerStyle.copyWith(
                                    shadows: fontShadow,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                style:
                                    headerStyle.copyWith(shadows: fontShadow),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Heading Required';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: TextFormField(
                                controller: _subHeading,
                                decoration: InputDecoration(
                                  hintText: 'Enter Sub Heading',
                                  hintStyle: subHeaderStyle.copyWith(
                                    shadows: fontShadow,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                style: subHeaderStyle.copyWith(
                                    shadows: fontShadow),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Sub Heading Required';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextFormField(
                                controller: _line_1,
                                decoration: InputDecoration(
                                  hintText: 'Enter Line 1',
                                  hintStyle: lineStyle.copyWith(
                                    shadows: fontShadow,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                style: lineStyle.copyWith(shadows: fontShadow),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextFormField(
                                controller: _line_2,
                                decoration: InputDecoration(
                                  hintText: 'Enter Line 2',
                                  hintStyle: lineStyle.copyWith(
                                    shadows: fontShadow,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                style: lineStyle.copyWith(shadows: fontShadow),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextFormField(
                                controller: _line_3,
                                decoration: InputDecoration(
                                  hintText: 'Enter Line 3',
                                  hintStyle: lineStyle.copyWith(
                                    shadows: fontShadow,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                style: lineStyle.copyWith(shadows: fontShadow),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextFormField(
                                controller: _line_4,
                                decoration: InputDecoration(
                                  hintText: 'Enter Line 4',
                                  hintStyle: lineStyle.copyWith(
                                    shadows: fontShadow,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                style: lineStyle.copyWith(shadows: fontShadow),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextFormField(
                                controller: _line_5,
                                decoration: InputDecoration(
                                  hintText: 'Enter Line 5',
                                  hintStyle: lineStyle.copyWith(
                                    shadows: fontShadow,
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                                style: lineStyle.copyWith(shadows: fontShadow),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const BusyIndicator(),
                                SecondaryButton(
                                  labelKey: "Cancel",
                                  onPressed: _close,
                                ),
                                divider(horizontal: true),
                                PrimaryButton(
                                  labelKey: "Save",
                                  onPressed: () async {
                                    await _save(close: true);
                                  },
                                ),
                                divider(horizontal: true),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
