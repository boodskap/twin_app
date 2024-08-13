import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:twin_app/pages/nocodebuilder/foldable_card.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twinned_widgets/core/border_config.dart';
import 'package:twinned_widgets/core/padding_config.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_app/core/session_variables.dart';

typedef OnDashboardScreenSaved = void Function(DashboardScreen screen);

class ConfigDashboardPalette extends StatefulWidget {
  final DashboardScreen screen;
  final OnDashboardScreenSaved onDashboardScreenSaved;
  const ConfigDashboardPalette(
      {super.key, required this.screen, required this.onDashboardScreenSaved});

  @override
  State<ConfigDashboardPalette> createState() => _ConfigDashboardPaletteState();
}

class _ConfigDashboardPaletteState extends BaseState<ConfigDashboardPalette> {
  // static const labelStyle =
  //     TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  static final InputDecorationTheme dropdownDecoration = InputDecorationTheme(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    constraints: BoxConstraints.tight(const Size.fromHeight(40)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static bool collapsed = false;
  late DashboardScreen _screen;

  @override
  void initState() {
    _screen = widget.screen.copyWith();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FoldableCard(
      title: 'Dashboard Properties',
      headerStyle: theme.getStyle().copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      labelStyle: theme.getStyle().copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      collapsed: collapsed,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Row Spacing',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 35,
              child: IntrinsicWidth(
                child: SpinBox(
                  min: 0.0,
                  max: 500,
                  value: _screen.spacing ?? 10,
                  step: 1,
                  onSubmitted: (value) {
                    setState(() {
                      _screen = _screen.copyWith(spacing: value);
                    });
                    widget.onDashboardScreenSaved(_screen);
                  },
                ),
              ),
            ),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Background Color',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
                onPressed: () {
                  _showColorPickerDialog();
                },
                icon: Icon(
                  Icons.palette,
                  color: Color((_screen.bgColor ?? 0) > 0
                      ? _screen.bgColor!
                      : Colors.white.value),
                )),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main Axis Alignment',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            DropdownMenu<MainAxisAlignment>(
                initialSelection: MainAxisAlignment.values.byName(
                    _screen.mainAxisAlignment ?? MainAxisAlignment.start.name),
                inputDecorationTheme: dropdownDecoration,
                onSelected: (value) {
                  setState(() {
                    _screen = _screen.copyWith(
                        mainAxisAlignment:
                            (value ?? MainAxisAlignment.start).name);
                  });
                  widget.onDashboardScreenSaved(_screen);
                },
                dropdownMenuEntries: const [
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.start, label: 'Start'),
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.center, label: 'Center'),
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.end, label: 'End'),
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.spaceEvenly,
                      label: 'Space Evenly'),
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.spaceBetween,
                      label: 'Space Between'),
                  DropdownMenuEntry<MainAxisAlignment>(
                      value: MainAxisAlignment.spaceAround,
                      label: 'Space Around'),
                ]),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cross Axis Alignment',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            DropdownMenu<CrossAxisAlignment>(
                initialSelection: CrossAxisAlignment.values.byName(
                    _screen.crossAxisAlignment ??
                        CrossAxisAlignment.start.name),
                inputDecorationTheme: dropdownDecoration,
                onSelected: (value) {
                  setState(() {
                    _screen = _screen.copyWith(
                        crossAxisAlignment:
                            (value ?? CrossAxisAlignment.start).name);
                  });
                  widget.onDashboardScreenSaved(_screen);
                },
                dropdownMenuEntries: const [
                  DropdownMenuEntry<CrossAxisAlignment>(
                      value: CrossAxisAlignment.start, label: 'Start'),
                  DropdownMenuEntry<CrossAxisAlignment>(
                      value: CrossAxisAlignment.center, label: 'Center'),
                  DropdownMenuEntry<CrossAxisAlignment>(
                      value: CrossAxisAlignment.end, label: 'End'),
                  DropdownMenuEntry<CrossAxisAlignment>(
                      value: CrossAxisAlignment.stretch, label: 'Stretch'),
                  // DropdownMenuEntry<CrossAxisAlignment>(
                  //     value: CrossAxisAlignment.baseline, label: 'Baseline'),
                ]),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Main Axis Size',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            DropdownMenu<MainAxisSize>(
                initialSelection: MainAxisSize.values
                    .byName(_screen.mainAxisSize ?? MainAxisSize.max.name),
                inputDecorationTheme: dropdownDecoration,
                onSelected: (value) {
                  setState(() {
                    _screen = _screen.copyWith(
                        mainAxisSize: (value ?? MainAxisSize.max).name);
                  });
                  widget.onDashboardScreenSaved(_screen);
                },
                dropdownMenuEntries: const [
                  DropdownMenuEntry<MainAxisSize>(
                      value: MainAxisSize.min, label: 'Min'),
                  DropdownMenuEntry<MainAxisSize>(
                      value: MainAxisSize.max, label: 'Max'),
                ]),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scroll Direction',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            DropdownMenu<Axis>(
                initialSelection: Axis.values
                    .byName(_screen.scrollDirection ?? Axis.vertical.name),
                inputDecorationTheme: dropdownDecoration,
                onSelected: (value) {
                  setState(() {
                    _screen = _screen.copyWith(
                        scrollDirection: (value ?? Axis.vertical).name);
                  });
                  widget.onDashboardScreenSaved(_screen);
                },
                dropdownMenuEntries: const [
                  DropdownMenuEntry<Axis>(
                      value: Axis.vertical, label: 'Vertical'),
                  DropdownMenuEntry<Axis>(
                      value: Axis.horizontal, label: 'Horizontal'),
                ]),
          ],
        ),
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Banner Image',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            Wrap(
              children: [
                if (_screen.bannerImage?.isNotEmpty ?? false)
                  Tooltip(
                    message: 'Delete banner image',
                    child: IconButton(
                        onPressed: () {
                          _deleteBanner();
                        },
                        icon: const Icon(Icons.delete_forever)),
                  ),
                Tooltip(
                  message: 'Upload banner image',
                  child: IconButton(
                      onPressed: () async {
                        await _uploadBanner();
                      },
                      icon: const Icon(Icons.upload)),
                ),
              ],
            ),
          ],
        ),
        if (_screen.bannerImage?.isNotEmpty ?? false) divider(),
        if (_screen.bannerImage?.isNotEmpty ?? false)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Banner Height',
                style: theme.getStyle().copyWith(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(
                    min: 1,
                    max: 2048,
                    value: _screen.bannerHeight ?? 100,
                    step: 1,
                    onSubmitted: (value) {
                      setState(() {
                        _screen = _screen.copyWith(bannerHeight: value);
                      });
                      widget.onDashboardScreenSaved(_screen);
                    },
                  ),
                ),
              ),
            ],
          ),
        if (_screen.bannerImage?.isNotEmpty ?? false) divider(),
        if (_screen.bannerImage?.isNotEmpty ?? false)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Banner Fit',
                style: theme.getStyle().copyWith(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              DropdownMenu<BoxFit>(
                  initialSelection: BoxFit.values.byName(
                      _screen.bannerImageFit?.fit.name ?? BoxFit.contain.name),
                  inputDecorationTheme: dropdownDecoration,
                  onSelected: (value) {
                    setState(() {
                      _screen = _screen.copyWith(
                          bannerImageFit: ImageFitConfig(
                              fit: ImageFitConfigFit.values
                                  .byName(value?.name ?? BoxFit.contain.name)));
                    });
                    debugPrint('FIT: ${_screen.bannerImageFit}');
                    widget.onDashboardScreenSaved(_screen);
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry<BoxFit>(
                        value: BoxFit.scaleDown, label: 'Scale Down'),
                    DropdownMenuEntry<BoxFit>(
                        value: BoxFit.fitWidth, label: 'Fit Width'),
                    DropdownMenuEntry<BoxFit>(
                        value: BoxFit.fitHeight, label: 'Fit Height'),
                    DropdownMenuEntry<BoxFit>(
                        value: BoxFit.contain, label: 'Contain'),
                    DropdownMenuEntry<BoxFit>(
                        value: BoxFit.none, label: 'None'),
                    DropdownMenuEntry<BoxFit>(
                        value: BoxFit.fill, label: 'Fill'),
                    DropdownMenuEntry<BoxFit>(
                        value: BoxFit.cover, label: 'Cover'),
                  ]),
            ],
          ),
        divider(),
        BorderConfigWidget(
            borderConfig: _screen.screenBorderConfig,
            onBorderConfigured: (border) {
              _onBorderConfigured(border);
            }),
        divider(),
        PaddingConfigWidget(
            title: 'Padding',
            paddingConfig: _screen.paddingConfig,
            onPaddingConfigSaved: (paddingConfig) {
              _onPaddingConfigSaved(paddingConfig);
            }),
        divider(),
        PaddingConfigWidget(
            title: 'Margin',
            paddingConfig: _screen.marginConfig,
            onPaddingConfigSaved: (paddingConfig) {
              _onMarginConfigSaved(paddingConfig);
            }),
        divider(),
        if (null != _screen.screenBorderConfig)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Background Image',
                style: theme.getStyle().copyWith(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () async {
                    await _uploadBackground();
                  },
                  icon: const Icon(Icons.upload)),
            ],
          ),
      ],
      onCollapsed: (value) {
        setState(() {
          collapsed = value;
        });
      },
    );
  }

  void _onPaddingConfigSaved(PaddingConfig? paddingConfig) {
    final DashboardScreen thisScreen;

    if (null == paddingConfig) {
      thisScreen = DashboardScreen(
        domainKey: _screen.domainKey,
        id: _screen.id,
        name: _screen.name,
        rtype: _screen.rtype,
        createdStamp: _screen.createdStamp,
        createdBy: _screen.createdBy,
        updatedBy: _screen.updatedBy,
        updatedStamp: _screen.updatedStamp,
        titleConfig: _screen.titleConfig,
        mainAxisAlignment: _screen.mainAxisAlignment,
        crossAxisAlignment: _screen.crossAxisAlignment,
        marginConfig: _screen.marginConfig,
        bgColor: _screen.bgColor,
        bgImage: _screen.bgImage,
        mainAxisSize: _screen.mainAxisSize,
        bgImageFit: _screen.bgImageFit,
        scrollDirection: _screen.scrollDirection,
        spacing: _screen.spacing,
        tags: _screen.tags,
        description: _screen.description,
        bannerImage: _screen.bannerImage,
        screenBorderConfig: _screen.screenBorderConfig,
        rows: _screen.rows,
      );
    } else {
      thisScreen = _screen.copyWith(paddingConfig: paddingConfig);
    }

    setState(() {
      _screen = thisScreen;
    });

    widget.onDashboardScreenSaved(_screen);
  }

  void _onMarginConfigSaved(PaddingConfig? marginConfig) {
    final DashboardScreen thisScreen;

    if (null == marginConfig) {
      thisScreen = DashboardScreen(
        domainKey: _screen.domainKey,
        id: _screen.id,
        name: _screen.name,
        rtype: _screen.rtype,
        createdStamp: _screen.createdStamp,
        createdBy: _screen.createdBy,
        updatedBy: _screen.updatedBy,
        updatedStamp: _screen.updatedStamp,
        titleConfig: _screen.titleConfig,
        mainAxisAlignment: _screen.mainAxisAlignment,
        crossAxisAlignment: _screen.crossAxisAlignment,
        paddingConfig: _screen.paddingConfig,
        bgColor: _screen.bgColor,
        bgImage: _screen.bgImage,
        mainAxisSize: _screen.mainAxisSize,
        bgImageFit: _screen.bgImageFit,
        scrollDirection: _screen.scrollDirection,
        spacing: _screen.spacing,
        tags: _screen.tags,
        description: _screen.description,
        bannerImage: _screen.bannerImage,
        screenBorderConfig: _screen.screenBorderConfig,
        rows: _screen.rows,
      );
    } else {
      thisScreen = _screen.copyWith(marginConfig: marginConfig);
    }

    setState(() {
      _screen = thisScreen;
    });

    widget.onDashboardScreenSaved(_screen);
  }

  void _onBorderConfigured(BorderConfig? borderConfig) {
    final DashboardScreen thisScreen;

    if (null == borderConfig) {
      thisScreen = DashboardScreen(
        domainKey: _screen.domainKey,
        id: _screen.id,
        name: _screen.name,
        rtype: _screen.rtype,
        createdStamp: _screen.createdStamp,
        createdBy: _screen.createdBy,
        updatedBy: _screen.updatedBy,
        updatedStamp: _screen.updatedStamp,
        titleConfig: _screen.titleConfig,
        mainAxisAlignment: _screen.mainAxisAlignment,
        crossAxisAlignment: _screen.crossAxisAlignment,
        paddingConfig: _screen.paddingConfig,
        marginConfig: _screen.marginConfig,
        bgColor: _screen.bgColor,
        bgImage: _screen.bgImage,
        mainAxisSize: _screen.mainAxisSize,
        bgImageFit: _screen.bgImageFit,
        scrollDirection: _screen.scrollDirection,
        spacing: _screen.spacing,
        tags: _screen.tags,
        description: _screen.description,
        bannerImage: _screen.bannerImage,
        rows: _screen.rows,
      );
    } else {
      thisScreen = _screen.copyWith(screenBorderConfig: borderConfig);
    }

    setState(() {
      _screen = thisScreen;
    });

    widget.onDashboardScreenSaved(_screen);
  }

  void _deleteBanner() {
    refresh(sync: () {
      _screen = _screen.copyWith(bannerImage: '');
    });
    widget.onDashboardScreenSaved(_screen);
  }

  Future _uploadBanner() async {
    await execute(() async {
      var res = await TwinImageHelper.uploadDomainImage();
      if (null == res) return;
      if (!res.ok) {
        alert('Upload Failed', 'Unknown failure');
      } else {
        refresh(sync: () {
          _screen = _screen.copyWith(bannerImage: res?.entity?.id ?? '');
        });
        widget.onDashboardScreenSaved(_screen);
      }
    });
  }

  Future _uploadBackground() async {
    await execute(() async {
      var res = await TwinImageHelper.uploadDomainImage();
      if (null == res) return;
      if (!res.ok) {
        alert('Upload Failed', 'Unknown failure');
      } else {
        refresh(sync: () {
          _screen = _screen.copyWith(bgImage: res?.entity?.id ?? '');
        });
        widget.onDashboardScreenSaved(_screen);
      }
    });
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              hexInputBar: true,
              labelTypes: [],
              pickerColor: Color(_screen.bgColor ?? Colors.white.value),
              onColorChanged: (color) {
                setState(() {
                  _screen = _screen.copyWith(bgColor: color.value);
                });
              },
              enableAlpha: true,
              displayThumbColor: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                widget.onDashboardScreenSaved(_screen);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}
