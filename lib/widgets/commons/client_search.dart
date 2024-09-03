import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/core/client_dropdown.dart';
import 'package:twinned_api/twinned_api.dart' as twin;

class ClientSearch extends StatefulWidget {
  final OnClientSelected onClientSelected;
  final TextStyle style;
  const ClientSearch({
    super.key,
    required this.onClientSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<ClientSearch> createState() => _ClientSearchState();
}

class _ClientSearchState extends BaseState<ClientSearch> {
  final List<Widget> _children = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SearchBar(
                  hintText: 'Search Clients',
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  trailing: [const BusyIndicator()],
                  onChanged: (value) async {
                    await _load(search: value);
                  },
                ),
              ),
            ],
          ),
          divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: _children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(twin.Client entity) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          widget.onClientSelected(entity);
          Navigator.pop(context);
        },
        child: Row(
          children: [
            if (entity.icon?.isNotEmpty ?? false)
              SizedBox(
                  width: 64,
                  height: 48,
                  child: TwinImageHelper.getCachedDomainImage(entity.icon!)),
            if (entity.icon?.isEmpty ?? true)
              SizedBox(width: 64, height: 48, child: const Icon(Icons.image)),
            divider(horizontal: true),
            Text(
              entity.name,
              style: theme.getStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Future _load({String search = '*'}) async {
    if (loading) return;
    loading = true;
    _children.clear();
    await execute(() async {
      var res = await TwinnedSession.instance.twin.searchClients(
        apikey: TwinnedSession.instance.authToken,
        body: twin.SearchReq(search: search, page: 0, size: 10),
      );

      if (validateResponse(res)) {
        for (twin.Client entity in res.body?.values ?? []) {
          _children.add(_buildRow(entity));
        }
      }
    });
    loading = false;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}
