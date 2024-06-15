import 'package:flutter/material.dart';
import 'package:twin_app/pages/landing.dart';
import 'package:twin_app/router.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:pinput/pinput.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class VerifyOtpPage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const VerifyOtpPage({super.key, required this.loggedInState});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  @override
  Widget build(BuildContext context) {
    if (smallSreen)
      return _VerifyOtpMobilePage(loggedInState: widget.loggedInState);
    return Row(
      children: [
        Expanded(flex: 1, child: LandingPage()),
        SizedBox(
            width: credScreenWidth,
            child: _VerifyOtpMobilePage(loggedInState: widget.loggedInState)),
      ],
    );
  }
}

class _VerifyOtpMobilePage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const _VerifyOtpMobilePage({super.key, required this.loggedInState});

  @override
  State<_VerifyOtpMobilePage> createState() => _VerifyOtpMobilePageState();
}

class _VerifyOtpMobilePageState extends BaseState<_VerifyOtpMobilePage> {
  final TextEditingController pinController = TextEditingController();

  @override
  void setup() {
    // TODO: implement setup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        decoration: theme.getCredentialsPageDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 100,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "verifyOtp",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ).tr(),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(60),
                    )),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 50,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Color.fromRGBO(225, 95, 27, .3),
                                  blurRadius: 20,
                                  offset: Offset(0, 10))
                            ]),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 40,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Pinput(
                                controller: pinController,
                                length: 6,
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.getSecondaryColor(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side:
                                    BorderSide(color: theme.getPrimaryColor()),
                              ),
                              minimumSize: const Size(140, 40),
                            ),
                            onPressed: () {
                              context.pop();
                            },
                            child: Text(
                              "cancel",
                              style: TextStyle(
                                color: theme.getPrimaryColor(),
                                fontSize: 14,
                              ),
                            ).tr(),
                          ),
                          const BusyIndicator(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.getPrimaryColor(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              minimumSize: const Size(140, 40),
                            ),
                            onPressed: () {
                              GoRouter.of(context).push(Routes.reset);
                            },
                            child: Text(
                              'verify',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.getSecondaryColor(),
                              ),
                            ).tr(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                      Wrap(
                        spacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            "Powered By",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                          poweredBy,
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
