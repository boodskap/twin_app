import 'package:flutter/material.dart';
import 'package:twin_app/widgets/change_password_alert_snippet.dart';
import 'package:twin_app/widgets/subscription_snippet.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({Key? key}) : super(key: key);

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends BaseState<ProfileInfoScreen>
    with SingleTickerProviderStateMixin {
  late Image bannerImage;
  late TabController _tabController;
  String twinUserId = "";
  String fullName = '';
  String initials = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool _isEmailExpanded = false;
  bool _isNameExpanded = false;
  bool _isAddressExpanded = false;
  bool _isPhoneExpanded = false;
  bool _isDescExpanded = false;
  List<String> roles = [];
  List<String> roleNames = [];
  List<String> clientIds = [];
  List<String> clients = [];

  @override
  void initState() {
    super.initState();
    bannerImage =
        Image.asset('assets/images/ldashboard_banner.png', fit: BoxFit.fill);
    _tabController = TabController(length: 3, vsync: this);
    setup();
  }

  Future<void> load() async {
    try {
      var response = await TwinnedSession.instance.twin
          .getMyProfile(apikey: TwinnedSession.instance.authToken);
      var res = response.body!.entity!;

      if (validateResponse(response)) {
        setState(() {
          fullName = res.name;
          initials = getInitials(fullName);
          _emailController.text = res.email;
          _nameController.text = res.name;
          _addressController.text = res.address ?? '';
          _phoneController.text = res.phone ?? '';
          _descController.text = res.description ?? '';
          twinUserId = res.id;
          roles = res.roles ?? [];
          clientIds = res.clientIds ?? [];
        });
      }

      var clientResponse = await TwinnedSession.instance.twin.getClients(
        apikey: TwinnedSession.instance.authToken,
        body: GetReq(
          ids: clientIds,
        ),
      );
      if (validateResponse(clientResponse)) {
        setState(() {
          clients = clientResponse.body!.values
                  ?.map((client) => client.name)
                  .toList() ??
              [];
        });
      }
      var roleResponse = await TwinnedSession.instance.twin.getRoles(
        apikey: TwinnedSession.instance.authToken,
        body: GetReq(
          ids: roles,
        ),
      );
      if (validateResponse(roleResponse)) {
        setState(() {
          roleNames =
              roleResponse.body!.values?.map((role) => role.name).toList() ??
                  [];
        });
      }
    } catch (e) {}
  }

  String getInitials(String fullName) {
    String firstLetter = fullName.isNotEmpty ? fullName[0].toUpperCase() : '';
    int spaceIndex = fullName.indexOf(' ');
    if (spaceIndex != -1) {
      String secondLetter = fullName[spaceIndex + 1].toUpperCase();
      return '$firstLetter$secondLetter';
    }
    return firstLetter;
  }

  Future<void> updateProfile() async {
    busy();
    try {
      var res = await TwinnedSession.instance.twin.updateTwinUser(
        twinUserId: twinUserId,
        apikey: TwinnedSession.instance.authToken,
        body: TwinUserInfo(
          email: _emailController.text,
          name: _nameController.text,
          address: _addressController.text,
          phone: _phoneController.text,
          description: _descController.text,
        ),
      );
      if (res.body!.ok) {
        alert('', 'Profile saved successfully!');
      } else {
        alert("Profile not Updated", res.body!.msg!);
      }
    } catch (e) {
      alert('Error', e.toString());
    }
    busy(busy: false);
  }

  Future<void> _editPersonalDetails(BuildContext context) async {
    final controllers = {
      'Email': _emailController,
      'Name': _nameController,
      'Address': _addressController,
      'Phone': _phoneController,
      'Description': _descController,
    };

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Edit Personal Details',
                style: TextStyle(
                  color: Color(0xff754893),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close_outlined,
                    color: Color(0xff754893), size: 24),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              height: 300,
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: controllers.entries.map((entry) {
                  String label = entry.key;
                  TextEditingController controller = entry.value;
                  IconData icon = Icons.label;
                  if (label == 'Email') {
                    icon = Icons.email_outlined;
                  } else if (label == 'Name') {
                    icon = Icons.person_2_outlined;
                  } else if (label == 'Address') {
                    icon = Icons.home_outlined;
                  } else if (label == 'Phone') {
                    icon = Icons.phone_android_outlined;
                  } else if (label == 'Description') {
                    icon = Icons.description;
                  }

                  return Row(
                    children: [
                      Expanded(flex: 10, child: Icon(icon)),
                      Expanded(
                        flex: 90,
                        child: TextField(
                          controller: controller,
                          readOnly: label == 'Email',
                          decoration: InputDecoration(labelText: label),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _emailController.text = _emailController.text;
                  _nameController.text = _nameController.text;
                  _addressController.text = _addressController.text;
                  _phoneController.text = _phoneController.text;
                  _descController.text = _descController.text;
                });
                updateProfile();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff754893),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              child: const Text('Save',
                  style: TextStyle(color: Color(0xffffffff))),
            ),
          ],
        );
      },
    );
  }

  Widget buildPersonalDetail(String title, TextEditingController controller,
      bool isExpanded, Function(bool) onExpansionChanged) {
    return ExpansionTile(
      trailing: isExpanded
          ? const Icon(Icons.expand_less)
          : const Icon(Icons.chevron_right),
      initiallyExpanded: true,
      onExpansionChanged: onExpansionChanged,
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 20),
      expandedAlignment: Alignment.centerLeft,
      shape: const Border(bottom: BorderSide.none),
      children: [
        Text(controller.text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 900,
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFFACD0EC),
              title: const Text(
                'Profile',
                style: TextStyle(
                    color: Color(0xFF245f96),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              bottom: TabBar(
                labelColor: const Color(0xFF245f96),
                unselectedLabelColor: const Color(0xFF245f96),
                labelStyle: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.normal),
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Personal Details'),
                  Tab(text: 'Change Password'),
                  Tab(
                    text: 'Subscriptions',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // Personal Details Tab
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              child: Text(
                                initials,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _nameController.text,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 50,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Personal Details',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Row(
                                    children: [
                                      Tooltip(
                                        message: "Edit ",
                                        child: IconButton(
                                          onPressed: () =>
                                              _editPersonalDetails(context),
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Color(0xff245f96),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      offset: const Offset(
                                          0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        buildPersonalDetail('Email',
                                            _emailController, _isEmailExpanded,
                                            (bool isExpanded) {
                                          setState(() =>
                                              _isEmailExpanded = isExpanded);
                                        }),
                                        buildPersonalDetail(
                                            'Name',
                                            _nameController,
                                            _isNameExpanded, (bool isExpanded) {
                                          setState(() =>
                                              _isNameExpanded = isExpanded);
                                        }),
                                        buildPersonalDetail(
                                            'Address',
                                            _addressController,
                                            _isAddressExpanded,
                                            (bool isExpanded) {
                                          setState(() =>
                                              _isAddressExpanded = isExpanded);
                                        }),
                                        buildPersonalDetail('Phone',
                                            _phoneController, _isPhoneExpanded,
                                            (bool isExpanded) {
                                          setState(() =>
                                              _isPhoneExpanded = isExpanded);
                                        }),
                                        buildPersonalDetail(
                                            'Description',
                                            _descController,
                                            _isDescExpanded, (bool isExpanded) {
                                          setState(() =>
                                              _isDescExpanded = isExpanded);
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      divider(height: 10),
                      Expanded(
                        flex: 25,
                        child: Container(
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
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Roles ",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 8.0,
                                          children: roleNames.map((role) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Chip(
                                                label: Text(role),
                                                backgroundColor:
                                                    Colors.grey[300],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Clients ",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Wrap(
                                          spacing: 8.0,
                                          children: clients.map((name) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Chip(
                                                label: Text(name),
                                                backgroundColor:
                                                    Colors.grey[300],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: ChangePasswordSnippet(),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: SubscriptionsPage()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void setup() {
    load();
  }
}