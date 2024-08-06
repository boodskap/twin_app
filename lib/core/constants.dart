import 'package:twin_commons/core/twinned_session.dart';

const bool production = true;

const String mqttTcpUrl =
    production ? 'platform.boodskap.io' : 'nocode.boodskap.io';
const String mqttWsUrl = 'wss://$mqttTcpUrl/mqtt';
const int mqttTcpPort = 1883;
const int mqttTcpSslPort = 1883;
const int mqttWsPort = 443;
const String hostName = production ? 'rest.boodskap.io' : 'restdev.boodskap.io';

String getDeviceConnectionInfo(String hardwareDeviceId, String apiKey) {
  return """
MQTT TCP URL          = "tcp://${mqttTcpUrl}";
MQTT TCP Port         = $mqttTcpPort
MQTT TCP SSL Port     = $mqttTcpSslPort
MQTT Web Socket URL   = 'wss://$mqttTcpUrl/mqtt';
ClientID              = $apiKey

Topic                 = /${TwinnedSession.instance.domainKey}/$hardwareDeviceId/pub/0

Ex: mosquitto_pub -i $apiKey -h $mqttTcpUrl -p $mqttTcpPort -t "/${TwinnedSession.instance.domainKey}/$hardwareDeviceId/pub/0" -m "{"rpm": 1024}"

curl -X 'POST' \
  'https://$hostName/rest/nocode/DeviceData/send' \
  -H 'accept: application/json' \
  -H 'hardwareDeviceId: $hardwareDeviceId' \
  -H 'APIKEY: $apiKey' \
  -H 'Content-Type: application/json' \
  -d '{"rpm": 99}'""";
}
