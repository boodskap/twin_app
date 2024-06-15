import 'package:flutter/material.dart';
import 'package:twin_app/pages/landing.dart';
import 'package:twin_app/router.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPasswordPage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const ForgotPasswordPage({super.key, required this.loggedInState});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    if (smallSreen)
      return _ForgotPasswordMobilePage(loggedInState: widget.loggedInState);
    return Row(
      children: [
        Expanded(flex: 1, child: LandingPage()),
        SizedBox(
            width: credScreenWidth,
            child:
                _ForgotPasswordMobilePage(loggedInState: widget.loggedInState)),
      ],
    );
  }
}

class _ForgotPasswordMobilePage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const _ForgotPasswordMobilePage({super.key, required this.loggedInState});

  @override
  State<_ForgotPasswordMobilePage> createState() =>
      _ForgotPasswordMobilePageState();
}

class _ForgotPasswordMobilePageState
    extends BaseState<_ForgotPasswordMobilePage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void setup() {
    // TODO: implement setup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: theme.getCredentialsPageDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 100),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "resetPassword",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ).tr(),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 50),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(225, 95, 27, .3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ),
                              child: TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: "email".tr(),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
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
                              minimumSize: const Size(120, 40),
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
                              minimumSize: const Size(100, 40),
                            ),
                            onPressed: () {
                              context.push(Routes.otp);
                            },
                            child: Text(
                              'generateOtp',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.getSecondaryColor(),
                              ),
                            ).tr(),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "noAccountYet",
                            style: TextStyle(),
                          ).tr(),
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).push(Routes.signup);
                            },
                            child: Text(
                              "signUp",
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.getPrimaryColor(),
                              ),
                            ).tr(),
                          ),
                        ],
                      ),
                      SizedBox(height: 80),
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
