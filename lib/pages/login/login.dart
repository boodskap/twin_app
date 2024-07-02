import 'package:flutter/material.dart';
import 'package:twin_app/pages/landing.dart';
import 'package:twin_app/router.dart';
import 'package:twin_app/widgets/commons/email_field.dart';
import 'package:twin_app/widgets/commons/password_field.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/primary_text_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;

class LoginPage extends StatefulWidget {
  final LoggedInStateInfo loggedInState;
  const LoginPage({super.key, required this.loggedInState});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    if (smallScreen)
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
  final TextEditingController _userController =
      TextEditingController(text: 'jeganbose.vincent@gmail.com');
  final TextEditingController _passwordController =
      TextEditingController(text: 'welcome123');
  bool _rememberMe = false;
  bool _canLogin = false;

  @override
  void setup() {
    // TODO: implement setup
  }

  Future _doLogin() async {
    if (loading) return false;
    loading = true;

    await execute(() async {
      var lRes = await config.verification.loginUser(
          dkey: config.twinDomainKey,
          body: vapi.Login(
              userId: _userController.text.trim(),
              password: _passwordController.text.trim()));
      if (validateResponse(lRes)) {
        setState(() {
          widget.loggedInState.login();
        });
      }
    });

    loading = false;
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
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Align(alignment: Alignment.center, child: logo),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "login",
                    style: theme.getStyle().copyWith(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                  ).tr(),
                  SizedBox(height: 10),
                  Text(
                    "welcomeBack",
                    style: theme
                        .getStyle()
                        .copyWith(color: Colors.white, fontSize: 18),
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
                decoration: theme.getCredentialsContentDecoration(),
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
                              color: theme.getSecondaryColor(),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            EmailField(
                              controller: _userController,
                              onChanged: (value) {
                                setState(() {
                                  _canLogin =
                                      _userController.text.trim().length > 0 &&
                                          _passwordController.text
                                                  .trim()
                                                  .length >
                                              0;
                                });
                              },
                            ),
                            PasswordField(
                              controller: _passwordController,
                              onChanged: (value) {
                                setState(() {
                                  _canLogin =
                                      _userController.text.trim().length > 0 &&
                                          _passwordController.text
                                                  .trim()
                                                  .length >
                                              0;
                                });
                              },
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
                                Text(
                                  'rememberMe',
                                  style:
                                      theme.getStyle().copyWith(fontSize: 14),
                                ).tr(),
                              ],
                            ),
                          ),
                          BusyIndicator(),
                          PrimaryTextButton(
                            labelKey: 'forgotPassword',
                            onPressed: () {
                              context.push(Routes.forgot);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      PrimaryButton(
                        labelKey: 'login',
                        minimumSize: Size(400, 50),
                        onPressed: !_canLogin
                            ? null
                            : () {
                                _doLogin();
                              },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "noAccountYet",
                            style: theme.getStyle().copyWith(),
                          ).tr(),
                          PrimaryTextButton(
                            labelKey: 'signUp',
                            onPressed: () {
                              GoRouter.of(context).push(Routes.signup);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 50),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Wrap(
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Powered By",
                              style: theme.getStyle().copyWith(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                            ),
                            poweredBy,
                          ],
                        ),
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
