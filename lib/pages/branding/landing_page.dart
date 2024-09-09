import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/branding/add_landing_page.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:uuid/uuid.dart';

class LandingContentPage extends StatefulWidget {
  const LandingContentPage({
    super.key,
  });

  @override
  State<LandingContentPage> createState() => _LandingContentPageState();
}

class _LandingContentPageState extends BaseState<LandingContentPage> {
  twinned.TwinSysInfo? twinSysInfo;
  final List<twinned.LandingPage> _entities = [];
  final List<Widget> _cards = [];
  void _buildCard(twinned.LandingPage landingPage, int index) {
    String? imgPath = landingPage.logoImage;

    Widget newCard = Tooltip(
      message: '${landingPage.heading}',
      child: InkWell(
        onDoubleTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LandingWidgetType(
                key: Key(const Uuid().v4()),
                load: _reload,
                twinSysInfo: twinSysInfo!,
                landingPage: landingPage,
                index: index,
              ),
            ),
          );
        },
        child: Card(
          color: Colors.transparent,
          elevation: 5,
          child: Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                if (imgPath != null && imgPath.isNotEmpty)
                  Positioned(
                    top: 40,
                    left: 30,
                    bottom: 30,
                    right: 30,
                    child: Container(
                      height: 64,
                      width: 64,
                      child: TwinImageHelper.getCachedDomainImage(
                          landingPage.logoImage!),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        landingPage.heading!,
                        style: theme.getStyle().copyWith(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          confirmDeletion(context, landingPage);
                        },
                        icon:
                            Icon(Icons.delete, color: theme.getPrimaryColor()),
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

    setState(() {
      _cards.add(newCard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PrimaryButton(
                labelKey: 'Add New Landing Page',
                onPressed: () {
                  twinned.LandingPage landingPage = twinned.LandingPage(
                      logoImage: '',
                      bgColor: Colors.black.value,
                      heading: 'My Application Heading',
                      subHeading: 'My Application Sub Heading',
                      line1: 'Punch line',
                      line2: '',
                      line3: '',
                      line4: '',
                      line5: '');
                  twinSysInfo!.landingPages!.add(landingPage);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LandingWidgetType(
                        key: Key(const Uuid().v4()),
                        twinSysInfo: twinSysInfo!,
                        landingPage: landingPage,
                        index: twinSysInfo!.landingPages!.length - 1,
                        load: _reload,
                      ),
                    ),
                  );
                },
              ),
              divider(horizontal: true),
            ],
          ),
          divider(),
          Expanded(
            flex: 1,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  itemCount: _cards.length,
                  itemBuilder: (ctx, index) {
                    return _cards[index];
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      _entities.clear();
      _cards.clear();

      var res = await TwinnedSession.instance.twin.getTwinSysInfo(
        domainKey: TwinnedSession.instance.domainKey,
      );

      if (validateResponse(res)) {
        twinSysInfo = res.body!.entity;
        var landingPages = res.body!.entity!.landingPages;
        for (var page in landingPages!) {
          _entities.add(page);
          _buildCard(page, _entities.length - 1);
        }
      }
      refresh();
    });
    loading = false;
  }

  Future _removeEntity(twinned.LandingPage landingPage) async {
    await execute(() async {
      twinSysInfo!.landingPages!.remove(landingPage);

      var upRes = await TwinnedSession.instance.twin.upsertTwinConfig(
        apikey: TwinnedSession.instance.authToken,
        body: twinSysInfo,
      );

      if (validateResponse(upRes)) {
        _load();
      }

      refresh();
    });
  }

  Future _reload(load) async {
    if (load) {
      await _load();
    }
  }

  confirmDeletion(BuildContext context, twinned.LandingPage landingPage) {
    AlertDialog alert = AlertDialog(
      title: Text(
        "WARNING",
        style: theme.getStyle().copyWith(
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: Text(
        "Deleting a Landing Page can not be undone.\nYou will loose all of the Landing Page data, history, etc.\n\nAre you sure you want to delete?",
        style: theme.getStyle().copyWith(fontSize: 16),
        maxLines: 10,
      ),
      actions: [
        SecondaryButton(
          labelKey: "Cancel",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        PrimaryButton(
          labelKey: "Delete",
          onPressed: () {
            Navigator.pop(context);
            _removeEntity(landingPage);
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void setup() async {
    await _load();
  }
}
