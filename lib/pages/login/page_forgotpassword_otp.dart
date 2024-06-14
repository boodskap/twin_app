import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:pinput/pinput.dart';
import 'package:twin_app/core/constants.dart';
import 'package:twin_app/pages/login/page_reset_password.dart';
import 'package:twin_commons/core/busy_indicator.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  const ForgotPasswordOtpPage({super.key});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends BaseState<ForgotPasswordOtpPage> {
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
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
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
                      "OTP And Password",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60))),
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
                              SystemNavigator.pop();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: theme.getPrimaryColor(),
                                fontSize: 14,
                              ),
                            ),
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ResetPasswordPage()),
                              );
                            },
                            child: Text(
                              'Verify',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.getSecondaryColor(),
                              ),
                            ),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
