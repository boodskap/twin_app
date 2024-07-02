import '/flavors/config.dart';
import '/flavors/config_values.dart';

class FlavorConfig {
  final Config _flavor;
  final ConfigValues _values;

  static late FlavorConfig _instance;
  static var _initialized = false;

  factory FlavorConfig.initialize({required String flavorString}) {
    if (!_initialized) {
      final flavor = Config.fromString(flavor: flavorString);
      final values = ConfigValues.fromEnvironment();
      _instance = FlavorConfig._internal(flavor: flavor, values: values);
      _initialized = true;
    }
    return _instance;
  }

  FlavorConfig._internal({
    required Config flavor,
    required ConfigValues values,
  })  : _flavor = flavor,
        _values = values;

  static Config get flavor => _instance._flavor;

  static ConfigValues get values => _instance._values;

  static bool isPROD() => _instance._flavor == Config.prod;

  static bool isQA() => _instance._flavor == Config.qa;

  static bool isDEV() => _instance._flavor == Config.dev;
}
