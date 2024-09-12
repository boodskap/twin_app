import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/pulse/widgets/template_content.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends BaseState<TemplatePage> {
  String _search = '*';
  final List<Widget> _children = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const BusyIndicator(),
            divider(horizontal: true),
            IconButton(
                onPressed: () {
                  _load();
                },
                icon: const Icon(Icons.refresh)),
            divider(horizontal: true),
            PrimaryButton(
                leading: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                labelKey: 'Add New',
                onPressed: _create),
            divider(horizontal: true),
            SizedBox(
                height: 40,
                width: 250,
                child: SearchBar(
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  leading: const Icon(Icons.search),
                  hintText: 'Search Template',
                  onChanged: (val) {
                    _search = val.trim().isEmpty ? '*' : val.trim();
                      _load();
                  },
                )),
          ],
        ),
        divider(),
        Flexible(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: _children,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future _edit(pulse.ContentTemplate entity) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateContentPage(
          title: 'Digital Twin - Template',
          template: entity,
        ),
      ),
    );
    _load();
  }

  Widget _buildChild(pulse.ContentTemplate entity) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Card(
        elevation: 5,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                    message: 'Edit ${entity.name}',
                    child: IconButton(
                        onPressed: () {
                          _edit(entity);
                        },
                        icon: const Icon(Icons.edit))),
                Tooltip(
                    message: 'Delete ${entity.name}',
                    child: IconButton(
                        onPressed: () {
                          _delete(entity);
                        },
                        icon: const Icon(Icons.delete))),
              ],
            ),
            divider(),
            Text(
              entity.name,
              style: theme
                  .getStyle()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            divider(),
            if (entity.contentType == pulse.ContentTemplateContentType.html)
              TemplateBadge(
                  text: 'HTML',
                  hintText: 'H',
                  badgeColor: theme.getPrimaryColor()),
            if (entity.contentType == pulse.ContentTemplateContentType.plain)
              TemplateBadge(
                  text: 'PLAIN', hintText: 'P', badgeColor: Colors.black)
          ],
        ),
      ),
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    _children.clear();
    refresh();
    await execute(() async {
      var res = await TwinnedSession.instance.pulseAdmin.searchContentTemplate(
          apikey: TwinnedSession.instance.authToken,
          body: pulse.SearchReq(search: _search, page: 0, size: 25));

      if (validateResponse(res)) {
        for (pulse.ContentTemplate entity in res.body?.values ?? []) {
          _children.add(_buildChild(entity));
        }
      }
    });
    loading = false;
    refresh();
  }

  Future _delete(pulse.ContentTemplate template) async {
    await confirm(
      title: 'Delete ${template.name}',
      message: 'Are you sure you want to delete this template?',
      onPressed: () async {
        await execute(() async {
          var res = await TwinnedSession.instance.pulseAdmin
              .deleteContentTemplate(
                  apikey: TwinnedSession.instance.authToken,
                  templateId: template.id);

          if (validateResponse(res)) {
            alert('Template ${template.name}', 'Deleted successfully');
          }
        });
      },
    );
    Future.delayed(Duration(seconds: 1), () {
      _load();
    });
  }

  Future _create() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TemplateContentPage(title: 'Digital Twin - Template'),
      ),
    );
    _load();
  }

  @override
  void setup() {
    _load();
  }
}

class TemplateBadge extends StatelessWidget {
  final String hintText;
  final String text;
  final Color badgeColor;
  const TemplateBadge(
      {super.key,
      required this.hintText,
      required this.text,
      required this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: badgeColor,
            radius: 10.0,
            child: Text(
              hintText,
              style: TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          ),
          SizedBox(width: 8.0),
          Text(
            text,
            style: TextStyle(color: badgeColor),
          ),
          SizedBox(width: 8.0),
        ],
      ),
    );
  }
}
