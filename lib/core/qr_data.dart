enum QrType {
  deviceModel,
  device,
  assetModel,
  premise,
  facility,
  floor,
  asset,
  customEntity,
}

class QrData {
  final QrType qrType;
  final String targetId;
  final String? extraData;

  QrData({
    required this.qrType,
    required this.targetId,
    required this.extraData,
  });

  @override
  String toString() {
    return '${this.qrType.name},${this.targetId},${this.extraData}';
  }

  static QrData? parse(String text) {
    List<String> values = text.split(',');
    if (values.length >= 2) {
      QrType qrType = QrType.values.byName(values.first);
      String targetId = values[1];
      String? extraData = values.length > 2 ? values[2] : null;
      return QrData(qrType: qrType, targetId: targetId, extraData: extraData);
    }
  }
}
