import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:twin_app/widgets/change_password_alert_snippet.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/subscription_snippet.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twin_app/core/session_variables.dart';

class ProfileInfoScreen extends StatefulWidget {
  final int selectedTab;
  const ProfileInfoScreen({Key? key, this.selectedTab = 0}) : super(key: key);

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
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  List<String> roles = [];
  List<String> roleNames = [];
  List<String> clientIds = [];
  List<String> clients = [];
  String fullNumber = "";
  String countryCode = "";

  bool _isPhoneValid = true;
  void _onNameChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    bannerImage =
        Image.asset('assets/images/ldashboard_banner.png', fit: BoxFit.fill);
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: widget.selectedTab);
    _nameController.addListener(_onNameChanged);
    String? input = _phoneController.text;

    List<String> splitString = input!.split('/');

    if (splitString.length > 1) {
      countryCode = splitString[0];
      _phoneController.text = splitString[1];
    } else {
      countryCode = "IN";
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String fullnum = "";
    String? input = _phoneController.text;
    List<String> splitString = input!.split('/');

    if (splitString.length > 2) {
      countryCode = splitString[0];
      _phoneController.text = splitString[2];
      fullnum = splitString[1]+splitString[2];
    } else {
      countryCode = "IN";
      _phoneController.text = _phoneController.text;
      fullnum = _phoneController.text;
    }

    return Center(
      child: SizedBox(
        width: 900,
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              bottom: TabBar(
                labelColor: const Color(0xFF245f96),
                unselectedLabelColor: const Color(0xFF245f96),
                labelStyle: theme.getStyle().copyWith(
                      fontSize: smallScreen ? 14 : 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                unselectedLabelStyle: theme.getStyle().copyWith(
                      fontSize: smallScreen ? 14 : 18.0,
                      fontWeight: FontWeight.bold,
                    ),
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
                                style: theme.getStyle().copyWith(fontSize: 24),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _nameController.text,
                              style: theme.getStyle().copyWith(
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
                                  Text('Personal Details',
                                      style: theme.getStyle().copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
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
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 0,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Text(
                                              "Email",
                                              style: theme.getStyle().copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )),
                                            Expanded(
                                                child: Text(
                                              _emailController.text,
                                              style: theme.getStyle().copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        // Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "name",
                                                style: theme
                                                    .getStyle()
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                              ),
                                            ),
                                            Expanded(
                                                child: Text(
                                              _nameController.text,
                                              style: theme.getStyle().copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),

                                        // Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Text(
                                              "Address",
                                              style: theme.getStyle().copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )),
                                            Expanded(
                                                child: Text(
                                              _addressController.text,
                                              style: theme.getStyle().copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),

                                        // Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Text(
                                              "Phone",
                                              style: theme.getStyle().copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )),
                                            Expanded(
                                                child: Text(
                                              fullnum,
                                              style: theme.getStyle().copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),

                                        // Divider(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Text(
                                              "Description",
                                              style: theme.getStyle().copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )),
                                            Expanded(
                                                child: Text(
                                              _descController.text,
                                              style: theme.getStyle().copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            )),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),

                                        // Divider(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          child: Text(
                            initials,
                            style: theme.getStyle().copyWith(fontSize: 24),
                          ),
                        ),
                        divider(),
                        const SizedBox(height: 8),
                        Text(
                          _nameController.text,
                          style: theme.getStyle().copyWith(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        divider(
                          height: 15,
                        ),
                        ChangePasswordSnippet(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        child: Text(
                          initials,
                          style: theme.getStyle().copyWith(fontSize: 24),
                        ),
                      ),
                      divider(),
                      const SizedBox(height: 8),
                      Text(
                        _nameController.text,
                        style: theme.getStyle().copyWith(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      divider(
                        height: 15,
                      ),
                      Center(child: SubscriptionsPage()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> load() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      var response = await TwinnedSession.instance.twin
          .getMyProfile(apikey: TwinnedSession.instance.authToken);
      var res = response.body!.entity!;

      if (validateResponse(response)) {
        refresh(sync: () {
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
    });
    loading = false;
    refresh();
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
    final initialValues = {
      'Email': _emailController.text,
      'Name': _nameController.text,
      'Address': _addressController.text,
      'Phone': _phoneController.text,
      'Description': _descController.text,
    };

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
              Text(
                'Edit Personal Details',
                style: theme.getStyle().copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);

                  _emailController.text = initialValues['Email']!;
                  _nameController.text = initialValues['Name']!;
                  _addressController.text = initialValues['Address']!;
                  _phoneController.text = initialValues['Phone']!;
                  _descController.text = initialValues['Description']!;
                },
                child: const Icon(Icons.close_outlined,
                    color: Color(0xff754893), size: 24),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: SizedBox(
                height: 400,
                width: 600,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: controllers.entries.map((entry) {
                    String label = entry.key;
                    TextEditingController controller = entry.value;
                    IconData icon = Icons.label;
                    Widget field;

                    if (label == 'Email') {
                      icon = Icons.email_outlined;
                      field = Column(
                        children: [
                          TextField(
                            style: theme.getStyle(),
                            controller: controller,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: label,
                              labelStyle: theme.getStyle(),
                            ),
                          ),
                          divider(height: 20),
                        ],
                      );
                    } else if (label == 'Name') {
                      icon = Icons.person_2_outlined;
                      field = Column(
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name cannot be empty.';
                              } else if (value.length <= 4) {
                                return 'Name should be greater than 4 characters.';
                              }
                              return null;
                            },
                            style: theme.getStyle(),
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: label,
                              labelStyle: theme.getStyle(),
                            ),
                          ),
                          divider(height: 20),
                        ],
                      );
                    } else if (label == 'Address') {
                      icon = Icons.home_outlined;
                      field = Column(
                        children: [
                          TextField(
                            style: theme.getStyle(),
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: label,
                              labelStyle: theme.getStyle(),
                            ),
                          ),
                          divider(height: 20),
                        ],
                      );
                    } else if (label == 'Phone') {
                      icon = Icons.phone_android_outlined;
                      field = Column(
                        children: [
                          IntlPhoneField(
                            controller: controller,
                            keyboardType: TextInputType.phone,
                            initialCountryCode: countryCode,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Enter Phone Number',
                              counterText: "",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4.0),
                                borderSide: BorderSide(
                                  color: theme.getPrimaryColor(),
                                ),
                              ),
                              labelStyle: theme.getStyle(),
                            ),
                            validator: (phone) {
                              if (phone == null || phone.number.isEmpty) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                            onChanged: (phone) {
                              setState(() {
                                fullNumber =
                                    "${phone.countryISOCode}/${phone.countryCode}/${phone.number}";
                                _isPhoneValid =
                                    phone.completeNumber.isNotEmpty &&
                                        phone.completeNumber.length >= 10 &&
                                        phone.isValidNumber();
                              });
                            },
                          ),
                          divider(height: 20),
                        ],
                      );
                    } else if (label == 'Description') {
                      icon = Icons.description;
                      field = Column(
                        children: [
                          TextField(
                            style: theme.getStyle(),
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: label,
                              labelStyle: theme.getStyle(),
                            ),
                          ),
                          divider(height: 20),
                        ],
                      );
                    } else {
                      field = Column(
                        children: [
                          TextField(
                            style: theme.getStyle(),
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: label,
                              labelStyle: theme.getStyle(),
                            ),
                          ),
                          divider(height: 20),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 10, child: Icon(icon)),
                        Expanded(
                          flex: 90,
                          child: field,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          actions: [
            PrimaryButton(
              labelKey: "Save",
              onPressed: _nameController.text.isNotEmpty
                  ? () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _emailController.text = _emailController.text;
                          _nameController.text = _nameController.text;
                          _addressController.text = _addressController.text;
                          _phoneController.text = fullNumber.trim();
                          _descController.text = _descController.text;
                        });
                        updateProfile();
                        Navigator.of(context).pop();
                      }
                    }
                  : null,
            ),
          ],
        );
      },
    );
  }

  @override
  void setup() {
    load();
  }
}
