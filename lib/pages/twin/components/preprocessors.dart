import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/twin/components/widgets/preprocessor_content_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:uuid/uuid.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';

typedef BasicInfoCallback = void Function(
    String name, String? description, String? tags);

class Preprocessors extends StatefulWidget {
  const Preprocessors({super.key});

  @override
  State<Preprocessors> createState() => _PreprocessorsState();
}

class _PreprocessorsState extends BaseState<Preprocessors> {
  final List<tapi.Preprocessor> _entities = [];
  final List<Widget> _cards = [];
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BusyIndicator(),
            IconButton(
                onPressed: () async {
                  _load();
                },
                icon: Icon(Icons.refresh)),
            divider(horizontal: true),
            PrimaryButton(
              labelKey: 'Create New',
              leading: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                _create();
              },
            ),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  leading: Icon(Icons.search),
                  hintText: 'Search Preprocessor',
                  onChanged: (val) {
                    _search = val.trim();
                    _load();
                  },
                )),
          ],
        ),
        divider(),
        if (loading)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loading...',
                style: theme.getStyle(),
              ),
            ],
          ),
        if (!loading && _cards.isEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No preprocessors found',
                style: theme.getStyle(),
              ),
            ],
          ),
        if (!loading && _cards.isNotEmpty)
          SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: _cards,
            ),
          ),
      ],
    );
  }

  Widget _buildCard(tapi.Preprocessor e) {
    double width = MediaQuery.of(context).size.width / 8;
    return SizedBox(
      width: width,
      height: width,
      child: InkWell(
        onDoubleTap: () => _edit(e),
        child: Tooltip(
          textStyle: theme.getStyle().copyWith(color: Colors.white),
          message: '${e.name}\n${e.description ?? ""}',
          child: Card(
            elevation: 8,
            color: Colors.white,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      e.name,
                      style:
                          theme.getStyle().copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                            onTap: () {
                              _edit(e);
                            },
                            child:
                                Icon(Icons.edit, color: theme.getPrimaryColor())),
                        InkWell(
                          onTap: () {
                            _delete(e);
                          },
                          child: Icon(
                            Icons.delete,
                            color: theme.getPrimaryColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _create() async {
    if (loading) return;
    loading = true;

    await _getPreprocessorInfo(context, 'New Preprocessor',
        onPressed: (name, desc, className) async {
      var mRes = await TwinnedSession.instance.twin.createPreprocessor(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.PreprocessorInfo(
            name: name,
            description: desc,
            tags: [],
            className: className!,
          ));
      if (validateResponse(mRes)) {
        await _edit(mRes.body!.entity!);
        // alert('Success', 'Preprocessor ${name} created successfully!');
      }
    });

    loading = false;
    refresh();
  }

  Future _edit(tapi.Preprocessor e) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreprocessorContentPage(
          preprocessor: e,
          key: Key(
            Uuid().v4(),
          ),
        ),
      ),
    );
    await _load();
  }

  Future<void> _getPreprocessorInfo(BuildContext context, String title,
      {required BasicInfoCallback onPressed}) async {
    String? nameText = '';
    String? descText = '';
    String? classText = '';
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 500,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        nameText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        descText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Description',
                      hintStyle: theme.getStyle(),
                    ),
                  ),
                  TextField(
                    style: theme.getStyle(),
                    onChanged: (value) {
                      setState(() {
                        classText = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Class Name',
                      hintStyle: theme.getStyle(),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              SecondaryButton(
                labelKey: 'Cancel',
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              PrimaryButton(
                onPressed: () {
                  if (nameText!.length < 3) {
                    alert('Invalid',
                        'Name is required and should be minimum 3 characters');
                    return;
                  }
                  if (classText!.length < 3) {
                    alert('Invalid',
                        'Class name is required and should be minimum 3 characters');
                    return;
                  }
                  setState(() {
                    onPressed(nameText!, descText, classText);
                    Navigator.pop(context);
                  });
                },
                labelKey: 'Ok',
              ),
            ],
          );
        });
  }

  Future _delete(tapi.Preprocessor e) async {
    if (loading) return;
    loading = true;
    await confirm(
      title: "Warning",
      message:
          'Deleting is unrecoverable\nIt may also delete all the related models and components\n\nDo you want to proceed?',
      titleStyle: theme.getStyle().copyWith(color: Colors.red),
      messageStyle: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
      onPressed: () async {
        await execute(() async {
          int index = _entities.indexWhere((element) => element.id == e.id);
          var res = await TwinnedSession.instance.twin.deletePreprocessor(
              apikey: TwinnedSession.instance.authToken, preprocessorId: e.id);
          if (validateResponse(res)) {
            await _load();
            _entities.removeAt(index);
            _cards.removeAt(index);
            alert('Success', 'Preprocessor ${e.name} deleted!');
          }
        });
      },
    );
    loading = false;
    refresh();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.searchPreprocessors(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.Preprocessor e in _entities) {
        _cards.add(_buildCard(e));
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() async {
    await _load();
  }
}
