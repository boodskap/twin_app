import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';

class ChangePasswordSnippet extends StatefulWidget {
  const ChangePasswordSnippet({super.key});

  @override
  State<ChangePasswordSnippet> createState() => _ChangePasswordSnippetState();
}

class _ChangePasswordSnippetState extends BaseState<ChangePasswordSnippet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isObscured = true;
  bool isObscuredNew = true;
  bool isLoading = false;
  bool rememberMe = false;
  String oldPassword = '';

  Color primaryColor = const Color(0xFF0C244A);
  Color secondaryColor = const Color(0xFFFFFFFF);

  bool isObscuredConfirm = true;

  @override
  void setup() async {
    // oldPassword = await Constants.getString('existing.password', '');
    // rememberMe = await Constants.getBool('remember.me', false);
  }

  void _changePassword() async {
    busy();

    try {
      if (formKey.currentState!.validate()) {
        var oPass = oldPasswordController.text;
        var nPass = newPasswordController.text;
        var cPass = confirmPasswordController.text;

        if (oPass.isNotEmpty) {
          if (nPass == cPass) {
            var response = await TwinnedSession.instance.twin
                .getMyProfile(apikey: TwinnedSession.instance.authToken);
            var userId = response.body!.entity!.email;
            var res = await TwinnedSession.instance.twin.changePassword(
              apikey: TwinnedSession.instance.authToken,
              body: ChangePassReq(
                oldPassword: oldPasswordController.text,
                newPassword: newPasswordController.text,
              ),
            );
            if (validateResponse(res)) {
              if (rememberMe) {}
              await alert('Success', 'Password Changed Successfully');
            }
          } else {
            alert('Warning', 'Changing Password Mismatched');
          }
        } else {
          alert('Warning', 'Wrong Old Password');
        }
      }
    } catch (e, x) {}
  }

  @override
  Widget build(BuildContext context) {
    const vDivider = SizedBox(height: 8);
    const hDivider = SizedBox(width: 8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Change Your Password',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //     color: primaryColor,
          //   ),
          // ),
          // const SizedBox(height: 16),
          Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Text(
                        "Existing Password",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    hDivider,
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: oldPasswordController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscured = !isObscured;
                              });
                            },
                            icon: isObscured
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: isObscured,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Old Password Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                vDivider,
                Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Text(
                        "New Password",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    hDivider,
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscuredNew = !isObscuredNew;
                              });
                            },
                            icon: isObscuredNew
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: isObscuredNew,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "New Password Required";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                vDivider,
                Row(
                  children: [
                    const Expanded(
                      flex: 1,
                      child: Text(
                        "Confirm Password",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    hDivider,
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscuredConfirm = !isObscuredConfirm;
                              });
                            },
                            icon: isObscuredConfirm
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: isObscuredConfirm,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Confirm Password Required";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: primaryColor,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: primaryColor),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                onPressed: _changePassword,
                child: Text('Change', style: TextStyle(color: secondaryColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
