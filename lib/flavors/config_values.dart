import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/foundation/extensions/dotenv_ext.dart';
import 'package:twinned_api/twinned_api.dart' as tapi;
import 'package:verification_api/api/verification.swagger.dart' as vapi;
import 'package:nocode_api/api/nocode.swagger.dart' as ncapi;
import 'package:universal_html/html.dart' as html;

class ConfigValues {
  final bool showLogs;
  final String apiHost;
  final tapi.Twinned twinned;
  final vapi.Verification verification;
  final ncapi.Nocode nocode;
  final String noCodeDomainKey;
  final String? twinDomainKey;
  final String? twinClientId;
  final List<String> roles;
  final String emailSubject;
  final String activationTemplate;
  final String resetPswdTemplate;

  const ConfigValues({
    required this.showLogs,
    required this.apiHost,
    required this.twinned,
    required this.verification,
    required this.nocode,
    required this.noCodeDomainKey,
    this.twinDomainKey,
    this.twinClientId,
    required this.roles,
    required this.emailSubject,
    required this.activationTemplate,
    required this.resetPswdTemplate,
  });

  static ConfigValues fromEnvironment() {
    String apiHost = dotenv.env['API_HOST'] ?? 'restdev.boodskap.io';
    var twinned =
        tapi.Twinned.create(baseUrl: Uri.https(apiHost, '/rest/nocode'));
    var verification =
        vapi.Verification.create(baseUrl: Uri.https(apiHost, '/rest/nocode'));
    var nocode =
        ncapi.Nocode.create(baseUrl: Uri.https(apiHost, '/rest/nocode'));
    String noCodeDomainKey = dotenv.env['NOCODE_DKEY']!;
    String? twinDomainKey = dotenv.env['TWIN_DKEY'];
    String? twinClientId = dotenv.env['TWIN_CID'];
    List<String> roles = dotenv.env['ROLES']?.split(',') ?? [];
    String emailSubject = dotenv.env["EMAIL_SUBJECT"]!;
    String activationTemplate = dotenv.env["ACTIVATION_TEMPLATE"]!;
    String resetPswdTemplate = dotenv.env["RESET_PSWD_TEMPLATE"]!;

    debugPrint(
        'N_DKEY: $noCodeDomainKey, T_DKEY $twinDomainKey, T_CID: $twinClientId');

    return ConfigValues(
      showLogs: dotenv.getBoolOrDefault("SHOW_LOGS", fallback: false),
      apiHost: apiHost,
      nocode: nocode,
      noCodeDomainKey: noCodeDomainKey,
      twinned: twinned,
      verification: verification,
      twinClientId: twinClientId,
      twinDomainKey: twinDomainKey,
      roles: roles,
      emailSubject: emailSubject,
      activationTemplate: activationTemplate,
      resetPswdTemplate:resetPswdTemplate,
    );
  }
}
