import 'dart:convert';

import 'package:flutter/Material.dart';
import 'package:twin_app/app.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twin_commons/core/storage.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:verification_api/api/verification.swagger.dart' as vapi;
import 'package:nocode_api/api/nocode.swagger.dart' as ncapi;
import 'package:chopper/chopper.dart' as chopper;
import 'package:twin_app/auth.dart';

class TwinHelper {
  static void registerNoCode() {}

  static Future<void> execute(Function f, {Function()? onError}) async {
    try {
      await f();
    } catch (e, s) {
      debugPrintStack();
      debugPrint('ERROR: $e');
      BuildContext? context = appKey.currentState?.context;
      if (null != context) {
        String errS = e.toString();
        if (errS.contains('ClientError')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Network Error, Please check your internet connection',
                  style: theme.getStyle())));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errS, style: theme.getStyle())));
        }
      }
    }
  }

  static bool validateResponse(chopper.Response r) {
    if (null == r.body) {
      return false;
    }
    if (!r.body.ok) {
      return false;
    }
    return true;
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

  static Future<bool> addStoredPassword(String userId, String password) async {
    Storage.putString('recent.user', userId);
    return await Storage.putString('${userId}.password', password);
  }

  static Future<String> getStoredPassword(String userId) async {
    return await Storage.getString('${userId}.password', '');
  }

  static Future<bool> removeStoredUser(String userId) async {
    List<String> users = await getStoredUsers();
    bool removed = users.remove(userId);
    await Storage.putStringList('users', users);
    return removed;
  }

  static Future<String> getLastStoredUser() async {
    return await Storage.getString('recent.user', '');
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
      var res = await config.nocode.getOrganization(
          token: TwinnedSession.instance.authToken, orgId: orgId);
      if (TwinUtils.validateResponse(res)) {
        entity = res.body?.entity;
      }
    });

    return entity;
  }

  static Future<List<tapi.DeviceModel>> getDeviceModels(
      {String search = '*', int page = 0, int size = 10000}) async {
    List<tapi.DeviceModel> models = [];

    await execute(() async {
      var res = await config.twinned.searchDeviceModels(
        apikey: TwinnedSession.instance.authToken,
        body: tapi.SearchReq(search: search, page: page, size: size),
      );
      if (TwinUtils.validateResponse(res)) {
        models.addAll(res.body?.values ?? []);
      }
    });

    return models;
  }

  static Future<tapi.DeviceModel?> getDeviceModel(String id) async {
    tapi.DeviceModel? entity;

    await execute(() async {
      var res = await config.twinned.getDeviceModel(
          apikey: TwinnedSession.instance.authToken, modelId: id);
      if (TwinUtils.validateResponse(res)) {
        entity = res.body?.entity;
      }
    });

    return entity;
  }

  static Future<tapi.Device?> getDevice(String id) async {
    tapi.Device? entity;

    await execute(() async {
      var res = await config.twinned
          .getDevice(apikey: TwinnedSession.instance.authToken, deviceId: id);
      if (TwinUtils.validateResponse(res)) {
        entity = res.body?.entity;
      }
    });

    return entity;
  }

  static Future<List<tapi.ScrappingTable>> getScrappingTables(
      List<String> ids) async {
    List<tapi.ScrappingTable> entities = [];

    await execute(() async {
      var res = await config.twinned.getScrappingTables(
          apikey: TwinnedSession.instance.authToken,
          body: tapi.GetReq(ids: ids));
      if (TwinUtils.validateResponse(res)) {
        entities.addAll(res.body?.values ?? []);
      }
    });

    return entities;
  }

  static Future<void> navigateToLogin(StreamAuth auth) async {
    selectedMenu = homeMenu;
    selectedMenuTitle = '';
    await auth.signOut();
  }
}
