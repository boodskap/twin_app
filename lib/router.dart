import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:twin_app/app.dart';
import 'package:twin_app/auth.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/pages/login/forgotpassword.dart';
import 'package:twin_app/pages/login/verify_otp.dart';
import 'package:twin_app/pages/login/login.dart';
import 'package:twin_app/pages/login/reset_password.dart';
import 'package:twin_app/pages/login/signup.dart';
import 'package:twin_commons/core/twinned_session.dart';

abstract class Routes {
  static const home = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgot = '/forgot';
  static const otp = '/otp';
  static const reset = '/reset';
}

GlobalKey<HomeScreenState> application = GlobalKey<HomeScreenState>();

GoRouter router = GoRouter(
  initialLocation: Routes.home,
  redirect: (BuildContext c, GoRouterState s) async {
    debugPrint('NAME: ${s.name} PATH: ${s.path}, FULL PATH:${s.fullPath}');
    final bool loggedIn = await StreamAuthScope.of(c).isSignedIn();
    if (!loggedIn && Routes.home == s.fullPath) {
      return Routes.login;
    } else if (loggedIn) {
      return Routes.home;
    }
    return s.fullPath;
  },
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (_, __) => HomeScreen(
        key: application,
      ),
    ),
    GoRoute(
      path: Routes.login,
      builder: (_, __) {
        return LoginPage();
      },
    ),
    GoRoute(
      path: Routes.signup,
      builder: (_, __) => SignUpPage(),
    ),
    GoRoute(
      path: Routes.forgot,
      builder: (_, __) => ForgotPasswordPage(),
    ),
    GoRoute(
      path: Routes.otp,
      builder: (_, __) => VerifyOtpPage(),
    ),
    GoRoute(
      path: Routes.reset,
      builder: (_, __) => ResetPasswordPage(),
    ),
  ],
);
