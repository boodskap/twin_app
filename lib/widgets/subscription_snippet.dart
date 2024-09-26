import 'package:flutter/material.dart';
import 'package:twin_app/core/twin_theme.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twin_app/core/session_variables.dart';

import 'country_codes.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends BaseState<SubscriptionsPage> {
  late Image bannerImage;
  final List<Widget> _rows = [];
  final List<Event> _events = [];
  final Map<String, EventRegistration> _eventRegistrations =
      Map<String, EventRegistration>();
  bool _emailSupported = false;
  bool _smsSupported = false;
  bool _voiceSupported = false;

  EventRegistration dummy = const EventRegistration(
    domainKey: '',
    id: '',
    name: '',
    rtype: '',
    createdStamp: 0,
    createdBy: '',
    updatedBy: '',
    updatedStamp: 0,
    eventId: '',
    userId: '',
    clientIds: [],
  );

  @override
  void initState() {
    super.initState();

    bannerImage = Image.asset(
      'assets/images/ldashboard_banner.png',
      fit: BoxFit.cover,
    );
  }

  @override
  void setup() {
    _load();
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    var user = await TwinnedSession.instance.getUser();
    _emailSupported = user?.email.isNotEmpty ?? false;
    _smsSupported = user?.phone?.isNotEmpty ?? false;
    _voiceSupported = _smsSupported;

    await execute(() async {
      await _loadEvents();
      await _loadEventRegistrations();

      for (Event e in _events) {
        _buildRow(e, _eventRegistrations[e.id]);
      }
    });

    loading = false;
    refresh();
  }

  Future<void> _loadEvents() async {
    _rows.clear();
    _events.clear();

    var res = await TwinnedSession.instance.twin.searchEvents(
      apikey: TwinnedSession.instance.authToken,
      body: const SearchReq(search: '*', page: 0, size: 10000),
    );

    if (validateResponse(res)) {
      _events.addAll(res.body?.values ?? []);
    }
  }

  Future<void> _loadEventRegistrations() async {
    _eventRegistrations.clear();

    var res = await TwinnedSession.instance.twin.listEventRegistrations(
      apikey: TwinnedSession.instance.authToken,
      body: const ListReq(page: 0, size: 10000),
    );

    if (validateResponse(res)) {
      for (EventRegistration er in res.body?.values ?? []) {
        _eventRegistrations[er.eventId] = er;
      }
    }
  }

  Future _upsertEventRegistration(
      {required Event event,
      required bool isEmail,
      required bool isSms,
      required bool isVoice}) async {
    await execute(() async {
      TwinUser? user = await TwinnedSession.instance.getUser();

      EventRegistrationInfo info = EventRegistrationInfo(
        eventId: event.id,
        name: event.name,
        email: isEmail,
        sms: isSms,
        voice: isVoice,
        fcm: false,
        notification: false,
        roles: [],
        tags: [],
        targetDeviceIds: [],
        clientIds: isClient() ? await getClientIds() : [],
        emailId: '${user?.email ?? ''}',
        phoneNumber: user?.phone,
        countryCode: countryCodeMap[user?.countryCode ?? 'US'] ?? '+1',
      );
      print(info);
      if (_eventRegistrations.containsKey(event.id)) {
        var res = await TwinnedSession.instance.twin.updateEventRegistration(
          eventRegistrationId: _eventRegistrations[event.id]!.id,
          body: info,
          apikey: TwinnedSession.instance.authToken,
        );

        if (validateResponse(res)) {
          debugPrint('UPDATED: ${res.body?.entity}');
          refresh(sync: () {
            _eventRegistrations[event.id] = res.body!.entity!;
          });
        }
      } else {
        var res = await TwinnedSession.instance.twin.createEventRegistration(
          body: info,
          apikey: TwinnedSession.instance.authToken,
        );

        if (validateResponse(res)) {
          debugPrint('CREATED: ${res.body?.entity}');
          refresh(sync: () {
            _eventRegistrations[event.id] = res.body!.entity!;
          });
        }
      }
    });

    _load();
  }

  void _buildRow(Event event, EventRegistration? reg) {
    Widget newRow = SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              children: [
                if (smallScreen)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      event.name,
                      style: theme.getStyle().copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: smallScreen ? 14 : 18,
                          ),
                    ),
                  ),
                Row(
                  children: [
                    if (!smallScreen)
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                event.name.toString(),
                                style: theme.getStyle().copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: smallScreen ? 14 : 18,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!smallScreen)
                            Text(
                              'Email',
                              style: theme.getStyle(),
                            ),
                          if (smallScreen)
                            Icon(
                              Icons.email,
                            ),
                          const SizedBox(width: 10),
                          Checkbox(
                            value: reg?.email ?? false,
                            onChanged: !_emailSupported
                                ? null
                                : (value) {
                                    _upsertEventRegistration(
                                      event: event,
                                      isEmail: value ?? false,
                                      isSms: reg?.sms ?? false,
                                      isVoice: reg?.voice ?? false,
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!smallScreen)
                            Text(
                              'SMS',
                              style: theme.getStyle(),
                            ),
                          if (smallScreen)
                            Icon(
                              Icons.chat,
                            ),
                          const SizedBox(width: 10),
                          Checkbox(
                            value: reg?.sms ?? false,
                            onChanged: !_smsSupported
                                ? null
                                : (value) {
                                    _upsertEventRegistration(
                                      event: event,
                                      isEmail: reg?.email ?? false,
                                      isSms: value ?? false,
                                      isVoice: reg?.voice ?? false,
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!smallScreen)
                            Text(
                              'Voice',
                              style: theme.getStyle(),
                            ),
                          if (smallScreen)
                            Icon(
                              Icons.voicemail_rounded,
                            ),
                          const SizedBox(width: 10),
                          Checkbox(
                            value: reg?.voice ?? false,
                            onChanged: !_voiceSupported
                                ? null
                                : (value) {
                                    _upsertEventRegistration(
                                      event: event,
                                      isEmail: reg?.email ?? false,
                                      isSms: reg?.sms ?? false,
                                      isVoice: value ?? false,
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey, thickness: 0.5, height: 0)
        ],
      ),
    );

    setState(() {
      _rows.add(newRow);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(
              //   width: MediaQuery.of(context).size.width,
              //   height: 150,
              //   child: bannerImage,
              // ),
              const SizedBox(height: 10),
              Expanded(
                child: _rows.isEmpty
                    ? Center(
                        child: Text(
                          'No subscriptions found',
                          style: theme.getStyle().copyWith(fontSize: 18),
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: _rows.length,
                          itemBuilder: (context, index) {
                            return _rows[index];
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
