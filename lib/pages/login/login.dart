import 'package:flutter/material.dart';
import 'package:twin_app/pages/landing.dart';
import 'package:twin_app/router.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const LoginPage({super.key, required this.loggedInState});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    if (smallSreen)
      return _LoginMobilePage(loggedInState: widget.loggedInState);
    return Row(
      children: [
        Expanded(flex: 1, child: LandingPage()),
        SizedBox(
            width: credScreenWidth,
            child: _LoginMobilePage(loggedInState: widget.loggedInState)),
      ],
    );
  }
}

class _LoginMobilePage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const _LoginMobilePage({required this.loggedInState});

  @override
  State<_LoginMobilePage> createState() => _LoginMobilePageState();
}

class _LoginMobilePageState extends BaseState<_LoginMobilePage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

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
              height: 100,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "login",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ).tr(),
                  SizedBox(height: 10),
                  Text(
                    "welcomeBack",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ).tr(),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
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
                                controller: _userController,
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
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: "password".tr(),
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
                          InkWell(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                                ),
                                const Text(
                                  'rememberMe',
                                  style: TextStyle(fontSize: 14),
                                ).tr(),
                              ],
                            ),
                          ),
                          InkWell(
                            child: Text(
                              'forgotPassword',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.getPrimaryColor(),
                              ),
                            ).tr(),
                            onTap: () {
                              GoRouter.of(context).push(Routes.forgot);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            widget.loggedInState.login();
                          });
                        },
                        child: Text(
                          'login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ).tr(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.getPrimaryColor(),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          minimumSize: const Size(330, 50),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                      SizedBox(height: 20),
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
