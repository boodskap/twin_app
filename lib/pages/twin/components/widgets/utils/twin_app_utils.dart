import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twin_app/core/twin_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart' as twin;

class TwinAppUtils {
  static final List<String> _tankModels = [];
  static final List<String> _tankAssetModels = [];

  static Future<List<String>> getTankDeviceModels() async {
    return (dotenv.env['TANK_MODELS'] ?? '').split(',');
    if (_tankModels.isNotEmpty) return _tankModels;

    _tankModels.addAll((dotenv.env['TANK_MODELS'] ?? '').split(','));

    // await TwinHelper.execute(() async {
    //   var qRes = await TwinnedSession.instance.twin.queryEqlDeviceModel(
    //       apikey: TwinnedSession.instance.authToken,
    //       body: const twin.EqlSearch(source: [], mustConditions: [
    //         {
    //           "term": {"tags.keyword": "RIOT_TANK"}
    //         }
    //       ]));
    //   if (TwinHelper.validateResponse(qRes)) {
    //     for (twin.DeviceModel e in qRes.body!.values!) {
    //       _tankModels.add(e.id);
    //     }
    //   }
    // });

    return _tankModels;
  }

  static Future<List<String>> getTankAssetModels() async {
    if (_tankAssetModels.isNotEmpty) return _tankAssetModels;

    await TwinHelper.execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryEqlAssetModel(
          apikey: TwinnedSession.instance.authToken,
          body: const twin.EqlSearch(source: [], mustConditions: [
            {
              "term": {"tags.keyword": "RIOT_TANK"}
            }
          ]));
      if (TwinHelper.validateResponse(qRes)) {
        for (twin.AssetModel e in qRes.body!.values!) {
          _tankAssetModels.add(e.id);
        }
      }
    });

    return _tankAssetModels;
  }
}
