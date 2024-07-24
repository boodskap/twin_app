import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

class Premises extends StatefulWidget {
  const Premises({super.key});

  @override
  State<Premises> createState() => _PremisesState();
}

class _PremisesState extends BaseState<Premises> {
  final List<tapi.Premise> _entities = [];
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
                onPressed: () {
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
                  leading: Icon(Icons.search),
                  hintText: 'Search device library',
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
                'No premises found',
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

  Widget _buildCard(tapi.Premise e) {
    double width = MediaQuery.of(context).size.width / 8;
    return SizedBox(
      width: width,
      height: width,
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
                  style: theme.getStyle().copyWith(fontWeight: FontWeight.bold),
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
            if (null != e.images && e.images!.isNotEmpty)
              Align(
                alignment: Alignment.center,
                child: TwinImageHelper.getImage(e.domainKey, e.images!.first,
                    width: width / 2, height: width / 2),
              )
          ],
        ),
      ),
    );
  }

  Future _create() async {}

  Future _edit(tapi.Premise e) async {}

  Future _delete(tapi.Premise e) async {}

  Future _load() async {
    if (loading) return;
    loading = true;

    _entities.clear();
    _cards.clear();

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.searchPremises(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(sRes)) {
        _entities.addAll(sRes.body?.values ?? []);
      }

      for (tapi.Premise e in _entities) {
        _cards.add(_buildCard(e));
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() async {
    _load();
  }
}
