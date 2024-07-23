import 'package:flutter/material.dart';
import 'package:twin_app/pages/landing.dart';
import 'package:twin_app/router.dart';
import 'package:twin_app/widgets/commons/password_field.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:verification_api/api/verification.swagger.dart' as vapi;

class ResetPasswordPage extends StatefulWidget {
  final bool? signUp;
  const ResetPasswordPage({super.key, required this.signUp});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    if (smallScreen || landingPages.isEmpty)
      return _ResetPasswordMobilePage(
        signUp: widget.signUp,
      );
    return Row(
      children: [
        Expanded(flex: 1, child: LandingPage()),
        SizedBox(
            width: credScreenWidth,
            child: _ResetPasswordMobilePage(
              signUp: widget.signUp,
            )),
      ],
    );
  }
}

class _ResetPasswordMobilePage extends StatefulWidget {
  final bool? signUp;
  const _ResetPasswordMobilePage({required this.signUp});

  @override
  State<_ResetPasswordMobilePage> createState() =>
      _ResetPasswordMobilePageState();
}

class _ResetPasswordMobilePageState
    extends BaseState<_ResetPasswordMobilePage> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void setup() {
    // TODO: implement setup
  }

  Future<void> _doResetPassword() async {
    if (_formKey.currentState!.validate()) {
      String newPassword = _newPassController.text.trim();
      String confirmPassword = _confPassController.text.trim();

      String userId = localVariables['userId'] ?? '';
      String pinToken = localVariables['pinToken'] ?? '';
      String pin = localVariables['pin'] ?? '';

      if (userId.isEmpty || pinToken.isEmpty || pin.isEmpty) {
        alert("Failure", "Missing required information for password reset.");
        return;
      }

      try {
        final vapi.ResetPassword body = vapi.ResetPassword(
          userId: userId,
          pinToken: pinToken,
          pin: pin,
          password: confirmPassword,
        );
        var res = await config.verification
            .resetPassword(body: body, dkey: config.twinDomainKey);
        if (validateResponse(res)) {
          localVariables.clear();
          alert("Success", "Password Changed Successfully");

          if ((widget.signUp ?? false) && null != postSignUpHook) {
            await postSignUpHook!(res.body!);
          }

          context.push(Routes.login, extra: {'signUp': widget.signUp ?? false});
        }
      } catch (e) {
        alert("Error", "Error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: smallScreen ? null : credScreenWidth,
              decoration: theme.getCredentialsPageDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 100, child: logo),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "changePassword",
                          style: theme.getStyle().copyWith(
                                color: theme.getPrimaryColor(),
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                        ).tr(),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                    child: Container(
                      decoration: theme.getCredentialsContentDecoration(),
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: Form(
                          key: _formKey,
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
                                    PasswordField(
                                      hintKey: 'New Password',
                                      controller: _newPassController,
                                      // onChanged: (value) {
                                    //   setState(() {
                                    //     if (value == null || value.isEmpty) {
                                    //       return;
                                    //     }
                                    //     return null;
                                    //   });
                                    // },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a new password.';
                                        }
                                        if (value.length < 4) {
                                          return 'Password must be at least 4 characters long.';
                                        }
                                        return null;
                                      },
                                    ),
                                    PasswordField(
                                      hintKey: 'confirmPassword',
                                      controller: _confPassController,
                                      // onChanged: (value) {
                                    //   setState(() {
                                    //     if (_newPassController.text ==
                                    //         _confPassController.text) {
                                    //       _doResetPassword();
                                    //     } else {
                                    //       alert("", "Password Mismatch");
                                    //     }
                                    //   });
                                    // },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password.';
                                        }
                                        if (value.length < 4) {
                                          return 'Confirm password must be at least 4 characters long.';
                                        }
                                        if (value != _newPassController.text) {
                                          return 'Passwords do not match.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 70),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SecondaryButton(
                                    labelKey: 'cancel',
                                    minimumSize: Size(125, 50),
                                    onPressed: () {
                                      context.pop();
                                    },
                                  ),
                                  const BusyIndicator(),
                                  PrimaryButton(
                                    labelKey: 'continue',
                                    minimumSize: Size(200, 50),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _doResetPassword();
                                      }
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
                                            fontSize: 14,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
