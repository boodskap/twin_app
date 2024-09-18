import 'package:flutter/services.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as tapi;

class CapitalizeAndDisallowSpacesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Capitalize the first letter
    if (newValue.text.isNotEmpty) {
      newValue = newValue.copyWith(
        text: newValue.text[0].toUpperCase() + newValue.text.substring(1),
      );
    }
    // Ensure the first letter is not an underscore
    if (newValue.text.isNotEmpty && newValue.text[0] == '_') {
      newValue = newValue.copyWith(text: newValue.text.substring(1));
    }
    // Disallow spaces
    if (newValue.text.contains(' ')) {
      return oldValue;
    }
    return newValue;
  }
}

class Utils {
  static tapi.AlarmInfo alarmInfo(tapi.Alarm e) {
    return tapi.AlarmInfo(
      name: e.name,
      modelId: e.modelId,
      state: e.state,
      conditions: e.conditions,
      tags: e.tags,
      showOnlyIfMatched: e.showOnlyIfMatched,
      stateIcons: e.stateIcons,
      label: e.label,
      description: e.description,
      clientIds: e.clientIds,
    );
  }

  static tapi.PremiseInfo premiseInfo(tapi.Premise e,
      {required String? name,
      String? description,
      List<String>? tags,
      List<String>? roles,
      List<String>? clientIds,
      List<String>? images,
      tapi.GeoLocation? location,
      int? selectedImage}) {
    return tapi.PremiseInfo(
      name: name ?? e.name,
      description: description ?? e.description,
      tags: tags ?? e.tags,
      roles: roles ?? e.roles,
      clientIds: clientIds ?? e.clientIds,
      images: images ?? e.images,
      location: location ?? e.location,
      selectedImage: selectedImage ?? e.selectedImage,
    );
  }

  static tapi.FacilityInfo facilityInfo(tapi.Facility e,
      {required String? name,
      String? description,
      List<String>? tags,
      List<String>? roles,
      List<String>? clientIds,
      List<String>? images,
      tapi.GeoLocation? location,
      int? selectedImage}) {
    return tapi.FacilityInfo(
      name: name ?? e.name,
      description: description ?? e.description,
      tags: tags ?? e.tags,
      roles: roles ?? e.roles,
      clientIds: clientIds ?? e.clientIds,
      images: images ?? e.images,
      location: location ?? e.location,
      selectedImage: selectedImage ?? e.selectedImage,
      premiseId: e.premiseId,
    );
  }

  static tapi.FloorInfo floorInfo(
    tapi.Floor e, {
    required String? name,
    String? description,
    List<String>? tags,
    List<String>? roles,
    List<String>? clientIds,
    String? floorPlan,
    tapi.GeoLocation? location,
    int? floorLevel,
    tapi.FloorInfoFloorType? floorType,
  }) {
    return tapi.FloorInfo(
      name: name ?? e.name,
      description: description ?? e.description,
      tags: tags ?? e.tags,
      roles: roles ?? e.roles,
      clientIds: clientIds ?? e.clientIds,
      floorPlan: floorPlan ?? e.floorPlan,
      location: location ?? e.location,
      premiseId: e.premiseId,
      facilityId: e.facilityId,
      floorLevel: floorLevel ?? e.floorLevel,
      floorType: tapi.FloorInfoFloorType.values.byName(null != floorType
          ? floorType.name
          : tapi.FloorInfoFloorType.onground.name),
      assets: e.assets,
    );
  }

  static tapi.AssetInfo assetInfo(
    tapi.Asset e, {
    String? name,
    String? description,
    List<String>? tags,
    List<String>? roles,
    required List<String> clientIds,
    List<String>? images,
    List<String>? devices,
    tapi.GeoLocation? location,
    int? selectedImage,
    String? premiseId,
    String? facilityId,
    String? floorId,
  }) {
    return tapi.AssetInfo(
      name: name ?? e.name,
      assetModelId: e.assetModelId,
      description: description ?? e.description,
      tags: tags ?? e.tags,
      roles: roles ?? e.roles,
      clientIds: clientIds,
      images: images ?? e.images,
      location: location ?? e.location,
      selectedImage: selectedImage ?? e.selectedImage,
      premiseId: premiseId,
      facilityId: facilityId,
      floorId: floorId,
      devices: devices ?? e.devices,
      position: e.position,
    );
  }
}
