import 'package:flutter/material.dart';
import 'package:twin_app/auth.dart';
import 'package:twin_app/core/twin_helper.dart';
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
import 'package:twin_commons/core/twinned_session.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    if (smallScreen) return _LoginMobilePage();
    return Row(
      children: [
        Expanded(flex: 1, child: LandingPage()),
        SizedBox(width: credScreenWidth, child: _LoginMobilePage()),
      ],
    );
  }
}

class _LoginMobilePage extends StatefulWidget {
  const _LoginMobilePage();

  @override
  State<_LoginMobilePage> createState() => _LoginMobilePageState();
}

class _LoginMobilePageState extends BaseState<_LoginMobilePage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _hasEmail = false;
  bool _hasPassword = false;
  bool _loggedIn = false;

  @override
  void setup() async {
    _userController.text = await TwinHelper.getLastStoredUser();
    if (_userController.text.trim().isNotEmpty) {
      _rememberMe = true;
      _passwordController.text =
          await TwinHelper.getStoredPassword(_userController.text.trim());
    }
    if (_userController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty) {
      _hasEmail = true;
      _hasPassword = true;
    }
    refresh();
  }

  Future _doLogin() async {
    if (loading) return false;
    loading = true;

    await execute(() async {
      String userId = _userController.text.trim();
      String password = _passwordController.text.trim();
      var lRes = await config.verification.loginUser(
          dkey: config.twinDomainKey,
          body: vapi.Login(userId: userId, password: password));
      if (validateResponse(lRes)) {
        setState(() {
          _loggedIn = true;
        });
        bool debug = TwinnedSession.instance.debug;
        String host = TwinnedSession.instance.host;
        String domainKey = TwinnedSession.instance.domainKey;
        String noCodeAuthToken = TwinnedSession.instance.noCodeAuthToken;
        TwinnedSession.instance.init(
            debug: debug,
            host: host,
            authToken: lRes.body!.authToken ?? '',
            domainKey: domainKey,
            noCodeAuthToken: noCodeAuthToken);
        if (_rememberMe) {
          TwinHelper.addStoredPassword(userId, password);
        }
        StreamAuthScope.of(context).signIn(userId);
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
          children: <Widget>[
            SizedBox(height: 100, child: logo),
            if (!_loggedIn)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "login",
                    style: theme.getStyle().copyWith(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                  ).tr(),
                ),
              ),
            if (!_loggedIn)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "welcomeBack",
                    style: theme
                        .getStyle()
                        .copyWith(color: Colors.white, fontSize: 18),
                  ).tr(),
                ),
              ),
            divider(height: _loggedIn ? 200 : 8),
            if (_loggedIn)
              Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        color: theme.getSecondaryColor(),
                      ))),
            if (!_loggedIn)
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
                                onChanged: (value) async {
                                  String password =
                                      await TwinHelper.getStoredPassword(
                                          _userController.text.trim());
                                  setState(() {
                                    _hasEmail = true;
                                    if (password.isNotEmpty) {
                                      _passwordController.text = password;
                                    }
                                  });
                                },
                              ),
                              PasswordField(
                                onSubmitted: (!_hasEmail || !_hasPassword)
                                    ? null
                                    : (value) {
                                        _doLogin();
                                      },
                                controller: _passwordController,
                                onChanged: (value) {
                                  setState(() {
                                    _hasPassword = _passwordController.text
                                        .trim()
                                        .isNotEmpty;
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
                          onPressed: (!_hasEmail || !_hasPassword)
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
