import 'dart:convert';

import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:verification_api/api/verification.swagger.dart' as vapi;
import 'package:nocode_api/api/nocode.swagger.dart' as ncapi;
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twin_commons/core/storage.dart';
import '/foundation/logger/logger.dart';

class TwinHelper {
  static void registerNoCode() {}

  static Future<void> execute(Function f) async {
    try {
      await f();
    } catch (e, s) {
      log.e('Call failed', time: DateTime.now(), error: e, stackTrace: s);
    }
  }

  static Future<vapi.MultiVerificationRes?> login(
      String userId, String password) async {
    vapi.MultiVerificationRes? entity;

    await execute(() async {
      var res = await config.verification.loginUserSession(
          twinUser: false,
          body: vapi.Login(userId: userId, password: password));

      if (TwinUtils.validateResponse(res)) {
        entity = res.body;
      }
    });

    return entity;
  }

  static List<vapi.PlatformSession> getUserSessions(
      vapi.MultiVerificationRes res) {
    List<vapi.PlatformSession> list = [];

    if (null != res.sessions) {
      for (vapi.PlatformSession ps in res.sessions!) {
        if (null != ps.orgId && ps.orgId!.isNotEmpty) {
          list.add(ps);
          continue;
        }

        if (ps.user.domainKey == config.noCodeDomainKey) {
          list.add(ps);
        }
      }
    }

    return list;
  }

  static bool isAdmin(vapi.PlatformSession session) {
    List<String> roles = session.user.roles ?? [];
    return roles.contains('orgadmin');
  }

  static Future<List<String>> getStoredUsers() async {
    return await Storage.getStringList('users', []);
  }

  static Future<bool> addStoredUser(String userId) async {
    List<String> users = await getStoredUsers();
    bool added = !users.contains(userId);
    if (added) {
      users.add(userId);
      await Storage.putStringList('users', users);
    }
    return added;
  }

  static Future<bool> removeStoredUser(String userId) async {
    List<String> users = await getStoredUsers();
    bool removed = users.remove(userId);
    await Storage.putStringList('users', users);
    return removed;
  }

  static Future<vapi.PlatformSession?> getStoredSession() async {
    String session = await Storage.getString('session', '');
    if (session.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(session);
      return vapi.PlatformSession.fromJson(json);
    }
    return null;
  }

  static Future<ncapi.Organization?> getOrganization(String orgId) async {
    ncapi.Organization? entity;

    await execute(() async {
      var res = await config.nocode
          .getOrganization(token: session?.authToken, orgId: orgId);
      if (TwinUtils.validateResponse(res)) {
        entity = res.body?.entity;
      }
    });

    return entity;
  }
}
