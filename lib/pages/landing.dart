import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/landing_custom.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends BaseState<LandingPage> {
  final List<Widget> _landingPages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Column(
            children: _landingPages,
          ),
        ),
      ),
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.twin
          .getTwinSysInfo(domainKey: config.twinDomainKey);
      if (validateResponse(res)) {
        twinSysInfo = res.body!.entity!;
      }

      if (config.loadLandingPages &&
          landingPages.isEmpty &&
          null != twinSysInfo &&
          null != twinSysInfo!.landingPages) {
        for (var p in twinSysInfo!.landingPages!) {
          _landingPages.add(CustomLandingPage(
              landingPage: p, textOrientation: TextOrientation.top));
          refresh();
        }
      } else if (landingPages.isNotEmpty) {
        _landingPages.addAll(landingPages);
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
