import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;

class DeviceInfoSnippet extends StatefulWidget {
  final twin.Device device;
  final Axis axis;
  const DeviceInfoSnippet(
      {super.key, required this.device, this.axis = Axis.vertical});

  @override
  State<DeviceInfoSnippet> createState() => _DeviceInfoSnippetState();
}

class _DeviceInfoSnippetState extends BaseState<DeviceInfoSnippet> {
  String modelName = '';
  Widget image = BaseState.missingImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.axis == Axis.horizontal)
          SizedBox(
            width: 72,
            height: 72,
            child: image,
          ),
        Expanded(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            divider(),
            if (widget.axis == Axis.vertical)
              SizedBox(
                width: 48,
                height: 48,
                child: image,
              ),
            if (widget.axis == Axis.vertical) divider(),
            Wrap(
              spacing: 8,
              children: [
                Text(
                  widget.device.deviceId,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis),
                ),
                InkWell(
                  onTap: () {
                    _copySN(widget.device.deviceId);
                  },
                  child: const Tooltip(
                      message: 'Copy device serial number',
                      child: Icon(Icons.content_copy)),
                )
              ],
            ),
            divider(),
            Text(
              'Model: $modelName',
              style: const TextStyle(
                  fontSize: 14, overflow: TextOverflow.ellipsis),
            ),
            divider(),
          ],
        )),
      ],
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    execute(() async {
      var mRes = await TwinnedSession.instance.twin.getDeviceModel(
          apikey: TwinnedSession.instance.authToken,
          modelId: widget.device.modelId);
      if (validateResponse(mRes)) {
        twin.DeviceModel deviceModel = mRes.body!.entity!;

        if (deviceModel.images!.isNotEmpty) {
          image = TwinImageHelper.getImage(
              deviceModel.domainKey, deviceModel.images!.first);
        }
        refresh(sync: () {
          modelName = deviceModel.name;
        });
      }
    });

    loading = false;
    refresh();
  }

  void _copySN(String deviceId) {
    Clipboard.setData(ClipboardData(text: deviceId));
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device SN copied to clipboard')));
  }

  @override
  void setup() {
    _load();
  }
}
