import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;

class MyConditions extends StatefulWidget {
  const MyConditions({super.key});

  @override
  State<MyConditions> createState() => _MyConditionsState();
}

class _MyConditionsState extends BaseState<MyConditions> {
  List<tapi.Condition> _conditionEntities = [];
  String _searchQuery = '*';
  bool isAdmin = false;
  bool isClientAdmin = false;

  @override
  void initState() {
    super.initState();
    isAdmin = TwinnedSession.instance.isAdmin();
    isClientAdmin = TwinnedSession.instance.isClientAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
            divider(
              horizontal: true,
            ),
            Tooltip(
              message: "Refresh",
              child: IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
              ),
            ),
            divider(
              horizontal: true,
            ),
            if (isAdmin || isClientAdmin)
              PrimaryButton(
                leading: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                labelKey: 'Add New Condition',
                onPressed: (isAdmin || isClientAdmin) ? () {} : null,
              ),
            divider(
              horizontal: true,
            ),
            SizedBox(
              width: 250,
              height: 30,
              child: SearchBar(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = '*${value.trim()}*';
                  });
                  _load();
                },
                hintText: "Search Conditions",
                leading: Icon(
                  Icons.search,
                ),
              ),
            ),
            divider(
              horizontal: true,
            ),
          ],
        ),
        divider(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Wrap(
                  spacing: 5.0,
                  runSpacing: 5.0,
                  children: _conditionEntities.map((condition) {
                    return _buildCard(condition);
                  }).toList(),
                ),
                divider(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    _conditionEntities.clear();

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryEqlCondition(
        apikey: TwinnedSession.instance.authToken,
        body: tapi.EqlSearch(
          source: [],
          mustConditions: [
            {
              "query_string": {
                "query": _searchQuery,
                "fields": ["name", "description", "tags"]
              }
            }
          ],
          sort: {"namek": "asc"},
          page: 0,
          size: 25,
        ),
      );

      if (validateResponse(qRes)) {
        _conditionEntities.addAll(qRes.body!.values!);
        debugPrint('Found ${_conditionEntities.length} conditions');
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    _load();
  }

  Widget _buildCard(tapi.Condition c) {
    return Tooltip(
      message: c.description,
      child: Card(
        color: Colors.transparent,
        elevation: 5,
        child: Container(
          height: 350,
          width: 350,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: theme.getPrimaryColor(),
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      c.name,
                      style: theme.getStyle().copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isAdmin || isClientAdmin)
                    Expanded(
                      flex: 1,
                      child: Tooltip(
                        message: 'Delete',
                        child: InkWell(
                          child: const Icon(
                            Icons.delete,
                            color: Colors.black,
                          ),
                          onTap: (isAdmin || isClientAdmin) ? () {} : null,
                        ),
                      ),
                    ),
                  if (isAdmin || isClientAdmin)
                    Expanded(
                      flex: 1,
                      child: Tooltip(
                        message: "Update",
                        child: InkWell(
                          onTap: (isAdmin || isClientAdmin) ? () {} : null,
                          child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Divider(
                color: theme.getPrimaryColor(),
                thickness: 2.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
