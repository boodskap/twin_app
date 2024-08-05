import 'package:chopper/chopper.dart' as chopper;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twin_app/pages/twin/components/widgets/display_state.dart';
import 'package:twin_app/pages/twin/components/widgets/show_overlay_widget.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_app/core/session_variables.dart';

class DisplayContentStatePage extends StatefulWidget {
  final DeviceModel deviceModel;
  Display display;
  DisplayContentStatePage(
      {super.key, required this.deviceModel, required this.display});

  @override
  State<DisplayContentStatePage> createState() =>
      _DisplayContentStatePageState();
}

class _DisplayContentStatePageState extends BaseState<DisplayContentStatePage> {
  final List<Widget> _cards = [];
  List _displayState = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  bool _showDisplayStateSection = false;
  bool _displayStateEditMode = false;
  int currentStateIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void setup() {
    Display e = widget.display!;
    _nameController.text = e.name;
    _descController.text = e.description ?? '';
    _tagsController.text = null != e.tags ? e.tags!.join(' ') : '';

    _displayState = widget.display.conditions;

    _loadDisplayState(_displayState);
  }

  void _loadDisplayState(conditions) {
    _cards.clear();
    if (conditions.length > 0) {
      for (var stateIndex = 0; stateIndex < conditions.length; stateIndex++) {
        _buildCard(conditions[stateIndex], stateIndex);
      }
    }
    refresh();
  }

  void _addDisplayState() {
    setState(() {
      currentStateIndex = _displayState.length > 0 ? _displayState.length : 0;
    });
    var amg = DisplayMatchGroup(
        matchType: DisplayMatchGroupMatchType.any,
        conditions: [],
        fontSize: 12,
        font: 'Open Sans',
        fontColor: Colors.black.value,
        width: 40,
        height: 40);

    widget.display.conditions.add(amg);

    setState(() {
      _showDisplayStateSection = !_showDisplayStateSection;
      _displayStateEditMode = false;
    });
  }

  void _save() async {
    busy();
    try {
      if (isBlank(_nameController.text)) {
        alert('Missing', 'Name is required');
        return;
      }

      if (widget.display.conditions.isEmpty) {
        alert('Error', 'At least one display state group is required');
        return;
      }

      for (int i = 0; i < widget.display.conditions.length; i++) {
        if (widget.display.conditions[i].conditions.isEmpty) {
          alert('Error',
              'Display state group $i should have at least one condition');
          return;
        }
      }

      chopper.Response<DisplayEntityRes> res;

      var body = DisplayInfo(
        modelId: widget.display!.modelId,
        name: _nameController.text,
        description: _descController.text,
        tags: _tagsController.text.split(' '),
        conditions: widget.display.conditions,
      );

      res = await TwinnedSession.instance.twin.updateDisplay(
          apikey: TwinnedSession.instance.authToken,
          displayId: widget.display!.id,
          body: body);

      if (validateResponse(res)) {
        alert('Display ${_nameController.text}', 'saved successfully');
      }
      // setup();
    } catch (e, s) {
      debugPrint('$e\n$s');
    } finally {
      busy(busy: false);
    }
  }

  void _buildCard(conditions, stateIndex) {
    // ImageProvider? image = const AssetImage('images/new-display.png');
    Widget newCard = Tooltip(
      message: 'State ${stateIndex + 1}',
      child: InkWell(
        onDoubleTap: () async {
          setState(() {
            currentStateIndex = stateIndex;
            _showDisplayStateSection = true;
            _displayStateEditMode = true;
          });
        },
        child: Card(
          color: Colors.transparent,
          elevation: 5,
          child: Container(//justtt_dumb_
            height: 250,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: theme.getPrimaryColor(),
                ),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Stack(
              children: [
                // Positioned(
                //   top: 40,
                //   left: 30,
                //   bottom: 30,
                //   right: 30,
                //   child: Container(
                //       height: 64,
                //       width: 64,
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(10),
                //         image: DecorationImage(
                //           image: image,
                //           fit: BoxFit.cover,
                //         ),
                //       )),
                // ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'State  ${stateIndex + 1}',
                        style: theme.getStyle().copyWith(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          confirmDeletion(context, stateIndex);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: theme.getPrimaryColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _cards.add(newCard);

    refresh();
  }

  confirmDeletion(BuildContext context, dynamic id) {
    // set up the buttons
    var cancelButton = SecondaryButton(
      labelKey: 'Cancel',
      onPressed: () {
        setState(() {
          Navigator.pop(context);
        });
      },
    );
    var deleteButton = PrimaryButton(
      labelKey: "Delete",
      onPressed: () {
        _removeEntity(id);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle().copyWith(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Text(
        "Deleting a display state can not be undone.\nYou will loose all of the display state data, history, etc.\n\nAre you sure you want to delete?",
        style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        deleteButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _removeEntity(id) {
    widget.display.conditions.removeAt(id);
    _loadDisplayState(widget.display.conditions);
  }

  @override
  Widget build(BuildContext context) {
    const SizedBox hdivider = SizedBox(
      width: 8,
    );
    const SizedBox vdivider = SizedBox(
      height: 8,
    );

    return Scaffold(
      body: Column(
        children: [
          TopBar(
            title: 'Digital Twin - Display  - ${widget.display.name}',
          ),
          vdivider,
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    vdivider,
                    Row(
                      children: [
                        hdivider,
                        Expanded(
                          flex: 20,
                          child: LabelTextField(
                            labelTextStyle: theme.getStyle(),
                            style: theme.getStyle(),
                            suffixIcon: Tooltip(
                              message: 'Copy display id',
                              preferBelow: false,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: widget.display.id),
                                  );
                                  OverlayWidget.showOverlay(
                                    context: context,
                                    topPosition: 140,
                                    leftPosition: 250,
                                    message: 'Display id copied!',
                                  );
                                },
                                child: const Icon(
                                  Icons.content_copy,
                                  size: 20,
                                ),
                              ),
                            ),
                            label: 'Display Name',
                            controller: _nameController,
                          ),
                        ),
                        hdivider,
                        Expanded(
                            flex: 50,
                            child: LabelTextField(
                              labelTextStyle: theme.getStyle(),
                              style: theme.getStyle(),
                              label: 'Description',
                              controller: _descController,
                            )),
                        hdivider,
                        Expanded(
                            flex: 30,
                            child: LabelTextField(
                              labelTextStyle: theme.getStyle(),
                              style: theme.getStyle(),
                              label: 'Tags',
                              controller: _tagsController,
                            )),
                      ],
                    ),
                    vdivider,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const BusyIndicator(padding: 4.0),
                        hdivider,
                        if (!_showDisplayStateSection) ...[
                          SecondaryButton(
                            labelKey: "Close",
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          hdivider,
                          PrimaryButton(
                            labelKey: "Add Display State",
                            onPressed: () {
                              _addDisplayState();
                            },
                          ),
                          hdivider,
                          PrimaryButton(
                            labelKey: "Save",
                            onPressed: () {
                              _save();
                            },
                          ),
                        ]
                      ],
                    ),
                    SizedBox(height: 25),
                    if (!_showDisplayStateSection) ...[
                      if (_cards.isEmpty)
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          child:  Center(
                              child: Text(
                            'No Display State Found',
                            style: theme.getStyle(),
                          )),
                        ),
                      if (_cards.isNotEmpty)
                        SingleChildScrollView(
                          child: GridView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            itemCount: _cards.length,
                            itemBuilder: (ctx, index) {
                              return _cards[index];
                            },
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 10,
                              childAspectRatio: 1.0,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                          ),
                        ),
                    ],
                    Visibility(
                      visible: _showDisplayStateSection,
                      child: DisplayStateSection(
                        deviceModel: widget.deviceModel,
                        display: widget.display,
                        index: currentStateIndex,
                        onSave: (value, int index) {
                          widget.display.conditions[index] = value;
                          setState(() {
                            _showDisplayStateSection = false;
                          });
                          _loadDisplayState(widget.display.conditions);
                        },
                        onClose: () {
                          setState(() {
                            _showDisplayStateSection = false;
                          });
                        },
                        isEditMode: _displayStateEditMode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool isBlank(String text) {
  return text.isEmpty;
}
