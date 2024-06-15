import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/landing.dart';
import 'package:twin_app/router.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const SignUpPage({super.key, required this.loggedInState});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    if (smallSreen)
      return _SignUpMobilePage(loggedInState: widget.loggedInState);
    return Row(
      children: [
        Expanded(flex: 1, child: LandingPage()),
        SizedBox(
            width: credScreenWidth,
            child: _SignUpMobilePage(loggedInState: widget.loggedInState)),
      ],
    );
  }
}

class _SignUpMobilePage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const _SignUpMobilePage({super.key, required this.loggedInState});

  @override
  State<_SignUpMobilePage> createState() => _SignUpMobilePageState();
}

class _SignUpMobilePageState extends BaseState<_SignUpMobilePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

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
            SizedBox(
              height: 128,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "registerNew",
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
                      SizedBox(height: 30),
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
                                controller: _firstNameController,
                                decoration: InputDecoration(
                                  hintText: "firstName".tr(),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
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
                                controller: _lastNameController,
                                decoration: InputDecoration(
                                  hintText: "lastName".tr(),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
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
                              minimumSize: Size(140, 40),
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
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.getPrimaryColor(),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              minimumSize: Size(140, 40),
                            ),
                            onPressed: () {
                              GoRouter.of(context).push(Routes.login);
                            },
                            child: Text(
                              'signUp',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.getSecondaryColor(),
                              ),
                            ).tr(),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "haveAccount",
                            style: TextStyle(),
                          ).tr(),
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).push(Routes.login);
                            },
                            child: Text(
                              "login",
                              style: TextStyle(
                                  fontSize: 18, color: theme.getPrimaryColor()),
                            ).tr(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Wrap(
                        spacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
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
