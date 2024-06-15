import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twin_app/app.dart';
import 'package:twin_app/pages/login/forgotpassword.dart';
import 'package:twin_app/pages/login/verify_otp.dart';
import 'package:twin_app/pages/login/login.dart';
import 'package:twin_app/pages/login/reset_password.dart';
import 'package:twin_app/pages/login/signup.dart';

abstract class Routes {
  static const home = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgot = '/forgot';
  static const otp = '/otp';
  static const reset = '/reset';
}

class LoggedInStateInfo extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }
}

LoggedInStateInfo _loggedInState = LoggedInStateInfo();

GoRouter router = GoRouter(
  initialLocation: Routes.home,
  redirect: (c, s) {
    debugPrint('NAME: ${s.name} PATH: ${s.path}, FULL PATH:${s.fullPath}');
    if (Routes.home == s.fullPath && !_loggedInState.isLoggedIn) {
      return Routes.login;
    } else if (s.fullPath != Routes.home && _loggedInState.isLoggedIn) {
      return Routes.home;
    }
    return s.fullPath;
  },
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (_, __) => HomeScreen(
        loggedInState: _loggedInState,
      ),
    ),
    GoRoute(
      path: Routes.login,
      builder: (_, __) {
        _loggedInState.addListener(() {
          if (_loggedInState.isLoggedIn) {
            GoRouter.of(_).pushReplacement(Routes.home);
          }
        });
        return LoginPage(loggedInState: _loggedInState);
      },
    ),
    GoRoute(
      path: Routes.signup,
      builder: (_, __) => SignUpPage(loggedInState: _loggedInState),
    ),
    GoRoute(
      path: Routes.forgot,
      builder: (_, __) => ForgotPasswordPage(loggedInState: _loggedInState),
    ),
    GoRoute(
      path: Routes.otp,
      builder: (_, __) => VerifyOtpPage(loggedInState: _loggedInState),
    ),
    GoRoute(
      path: Routes.reset,
      builder: (_, __) => ResetPasswordPage(loggedInState: _loggedInState),
    ),
  ],
);
