import 'package:flutter/material.dart';
import 'package:twin_app/core/twin_theme.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twin_app/core/session_variables.dart';

class SubscriptionsPage extends StatefulWidget {
  const SubscriptionsPage({super.key});

  @override
  State<SubscriptionsPage> createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends BaseState<SubscriptionsPage> {
  late Image bannerImage;
  List<Widget> _rows = [];
  List<Event> _events = [];
  List<EventRegistration> _eventRegistrations = [];

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

  void _load() async {
    busy();

    try {
      await _loadEvents();
      await _loadEventRegistrations();

      for (int i = 0; i < _events.length; i++) {
        var temp = _eventRegistrations
            .where((element) => _events[i].id == element.eventId)
            .toList();

        ER er;
        if (temp.isNotEmpty) {
          er = ER(event: _events[i], eventRegistration: temp[0]);
        } else {
          er = ER(event: _events[i], eventRegistration: dummy);
        }

        _buildRow(er, i + 1);
      }

      refresh();
    } catch (e) {
      alert('Error', e.toString());
    }

    busy(busy: false);
  }

  Future<void> _loadEvents() async {
    _rows.clear();
    _events.clear();

    var res = await TwinnedSession.instance.twin.listEvents(
      apikey: TwinnedSession.instance.authToken,
      body: const ListReq(page: 0, size: 10000),
    );

    if (validateResponse(res)) {
      _events = res.body!.values!;
    }
  }

  Future<void> _loadEventRegistrations() async {
    _eventRegistrations.clear();

    var res = await TwinnedSession.instance.twin.listEventRegistrations(
      apikey: TwinnedSession.instance.authToken,
      body: const ListReq(page: 0, size: 10000),
    );

    if (validateResponse(res)) {
      _eventRegistrations = res.body!.values!;
    }
  }

  void _upsertEventRegistration(
    String key,
    bool value,
    String id,
    String eventId,
    EventRegistration eventRegistration,
  ) async {
    busy();

    EventRegistrationInfo evInfo;
    var res;

    bool isEmail = false;
    bool isSms = false;
    bool isVoice = false;

    try {
      switch (key) {
        case 'email':
          isEmail = true;
          break;
        case 'sms':
          isSms = true;
          break;
        case 'voice':
          isVoice = true;
          break;
        default:
          break;
      }

      if (id.isNotEmpty) {
        evInfo = EventRegistrationInfo(
          eventId: eventId,
          email: isEmail ? value : eventRegistration.email,
          sms: isSms ? value : eventRegistration.sms,
          voice: isVoice ? value : eventRegistration.voice,
          notification: eventRegistration.notification,
          fcm: eventRegistration.fcm,
          emailId: eventRegistration.emailId,
          phoneNumber: eventRegistration.phoneNumber,
          name: eventRegistration.name,
          targetDeviceIds: eventRegistration.targetDeviceIds,
          tags: eventRegistration.tags,
        );

        res = await TwinnedSession.instance.twin.updateEventRegistration(
          eventRegistrationId: id,
          body: evInfo,
          apikey: TwinnedSession.instance.authToken,
        );
      } else {
        evInfo = EventRegistrationInfo(
          eventId: eventId,
          email: isEmail ? value : false,
          sms: isSms ? value : false,
          voice: isVoice ? value : false,
          notification: false,
          fcm: false,
          emailId: "TwinnedSession.instance.loginResponse!.user.email",
          phoneNumber: '0000000000',
          name: 'name',
          targetDeviceIds: [],
          tags: [],
        );

        res = await TwinnedSession.instance.twin.createEventRegistration(
          body: evInfo,
          apikey: TwinnedSession.instance.authToken,
        );
      }

      if (validateResponse(res)) {
        setup();
        // alert('Success', 'Event Registered');
      }
    } catch (e) {
      alert('Error', e.toString());
    }

    busy(busy: false);
  }

  void _removeEventRegistration(String id) async {
    busy();

    try {
      var res = await TwinnedSession.instance.twin.deleteEventRegistration(
        eventRegistrationId: id,
        apikey: TwinnedSession.instance.authToken,
      );

      if (validateResponse(res)) {
        setup();
      }
    } catch (e) {
      alert('Error', e.toString());
    }

    busy(busy: false);
  }

  void _buildRow(ER er, int sl) {
    bool subscribed = er.eventRegistration!.id.isNotEmpty;
    bool email = false;
    bool sms = false;
    bool voice = false;

    if (subscribed) {
      email = er.eventRegistration!.email ?? false;
      sms = er.eventRegistration!.sms ?? false;
      voice = er.eventRegistration!.voice ?? false;
    }

    Widget newRow = SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Padding(
              padding: const EdgeInsets.only(left: 60.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            er.event!.name.toString(),
                            style: theme.getStyle().copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                          ),
                        ),
                        Text('Email', style: theme.getStyle()),
                        const SizedBox(width: 10),
                        Checkbox(
                          value: email,
                          onChanged: (value) {
                            setState(() {
                              email = value!;
                            });

                            bool isNotEmpty = email || sms || voice;

                            if (isNotEmpty) {
                              _upsertEventRegistration(
                                'email',
                                email,
                                er.eventRegistration!.id,
                                er.event!.id,
                                er.eventRegistration!,
                              );
                            } else {
                              _removeEventRegistration(
                                  er.eventRegistration!.id);
                            }
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
                        Text(
                          'SMS',
                          style: theme.getStyle(),
                        ),
                        const SizedBox(width: 10),
                        Checkbox(
                          value: sms,
                          onChanged: (value) {
                            setState(() {
                              sms = value!;
                            });

                            bool isNotEmpty = email || sms || voice;

                            if (isNotEmpty) {
                              _upsertEventRegistration(
                                'sms',
                                sms,
                                er.eventRegistration!.id,
                                er.event!.id,
                                er.eventRegistration!,
                              );
                            } else {
                              _removeEventRegistration(
                                  er.eventRegistration!.id);
                            }
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
                        Text(
                          'Voice',
                          style: theme.getStyle(),
                        ),
                        const SizedBox(width: 10),
                        Checkbox(
                          value: voice,
                          onChanged: (value) {
                            setState(() {
                              voice = value!;
                            });

                            bool isNotEmpty = email || sms || voice;

                            if (isNotEmpty) {
                              _upsertEventRegistration(
                                'voice',
                                voice,
                                er.eventRegistration!.id,
                                er.event!.id,
                                er.eventRegistration!,
                              );
                            } else {
                              _removeEventRegistration(
                                  er.eventRegistration!.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

class ER {
  Event? event;
  EventRegistration? eventRegistration;

  ER({this.event, this.eventRegistration});

  // Map<String, dynamic> toJson() {
  //   Map<String, dynamic> map = {
  //     'event': event,
  //     'eventRegistration': eventRegistration
  //   };
  //   return map;
  // }

  static ER fromJson(Event ev, EventRegistration er) {
    return ER(event: ev, eventRegistration: er);
  }
}
