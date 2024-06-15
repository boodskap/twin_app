import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/landing.dart';
import 'package:twin_app/router.dart';
import 'package:twin_app/widgets/commons/email_field.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:twin_commons/core/busy_indicator.dart';

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
                    "registerNew",
                    style: theme.getStyle().copyWith(
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
                              color: Color.fromRGBO(225, 95, 27, .3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            EmailField(
                              controller: _emailController,
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
                                  hintStyle: theme
                                      .getStyle()
                                      .copyWith(color: Colors.grey),
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
                                  hintStyle: theme
                                      .getStyle()
                                      .copyWith(color: Colors.grey),
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
                          SecondaryButton(
                            labelKey: 'cancel',
                            onPressed: () {
                              context.pop();
                            },
                          ),
                          BusyIndicator(),
                          PrimaryButton(
                            labelKey: 'signUp',
                            minimumSize: Size(200, 50),
                            onPressed: () {
                              context.push(Routes.login);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "haveAccount",
                            style: theme.getStyle().copyWith(),
                          ).tr(),
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).push(Routes.login);
                            },
                            child: Text(
                              "login",
                              style: theme.getStyle().copyWith(
                                  fontSize: 18, color: theme.getPrimaryColor()),
                            ).tr(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
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
