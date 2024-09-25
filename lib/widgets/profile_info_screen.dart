import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:twin_app/auth.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/change_password_alert_snippet.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/country_codes.dart';
import 'package:twin_app/widgets/subscription_snippet.dart';
import 'package:twin_app/widgets/unregister_snippet.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart';

class ProfileInfoScreen extends StatefulWidget {
  final StreamAuth auth;
  final int selectedTab;
  const ProfileInfoScreen({Key? key, required this.auth, this.selectedTab = 0})
      : super(key: key);

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
  String countryCode = 'US';
  bool _isPhoneValid = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  List<String> roles = [];
  List<String> roleNames = [];
  List<String> clientIds = [];
  List<String> clients = [];

  // TwinUserInfo _twinUserInfo = const TwinUserInfo(
  //   name: '',
  //   email: '',
  //   address: '',
  //   city: '',
  //   clientIds: [],
  //   description: '',
  //   phone: '',
  //   images: [],
  //   countryCode: 'US',
  //   roles: [],
  //   tags: [],
  // );

  @override
  void initState() {
    super.initState();
    bannerImage =
        Image.asset('assets/images/ldashboard_banner.png', fit: BoxFit.fill);
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: widget.selectedTab);
    _nameController.addListener(_onNameChanged);
  }

  String formatPhoneNumber(String? phoneNumber, String countryCode) {
    final countryDialCode = countryCodeMap[countryCode] ?? '';
    return phoneNumber != null && phoneNumber.isNotEmpty
        ? '$countryDialCode $phoneNumber'
        : '';
  }

  @override
  Widget build(BuildContext context) {
    final formattedPhone =
        formatPhoneNumber(_phoneController.text, countryCode);

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
                tabs: [
                  if (!smallScreen) Tab(text: 'Personal Details'),
                  if (!smallScreen) Tab(text: 'Change Password'),
                  if (!smallScreen)
                    Tab(
                      text: 'Subscriptions',
                    ),
                  if (smallScreen)
                    Tab(
                      child: Icon(
                        Icons.person_3_rounded,
                      ),
                    ),
                  if (smallScreen)
                    Tab(
                      child: Icon(
                        Icons.phonelink_lock_rounded,
                      ),
                    ),
                  if (smallScreen)
                    Tab(
                      child: Icon(
                        Icons.event_available_rounded,
                      ),
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
                                      if (!smallScreen)
                                        PrimaryButton(
                                          labelKey: 'Delete My Account',
                                          onPressed: _deleteMyAccount,
                                        ),
                                      divider(horizontal: true),
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
                                                "Name",
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
                                              toCamelCase(_nameController.text),
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
                                              formattedPhone,
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
                                        if (smallScreen)
                                          Center(
                                            child: PrimaryButton(
                                              labelKey: 'Delete My Account',
                                              onPressed: _deleteMyAccount,
                                            ),
                                          ),
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

  Future _deleteMyAccount() async {
    await super.alertDialog(
      title: 'Delete My Account',
      body: UnregisterSnippet(auth: widget.auth),
      height: 200,
    );
  }

  Future<void> load() async {
    if (loading) return;
    loading = true;
    await execute(() async {
      TwinUser? user = await TwinnedSession.instance.getUser();

      if (null != user) {
        refresh(sync: () {
          fullName = user.name;
          initials = getInitials(fullName);
          _emailController.text = user.email;
          _nameController.text = user.name;
          _addressController.text = user.address ?? '';
          _phoneController.text = user.phone ?? '';
          _descController.text = user.description ?? '';
          twinUserId = user.id;
          roles = user.roles ?? [];
          clientIds = user.clientIds ?? [];
          countryCode = (user.countryCode?.isNotEmpty ?? false)
              ? user.countryCode!
              : 'US';
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

  String toCamelCase(String text) {
    return text.split(' ').map((word) {
      return word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
          : '';
    }).join(' ');
  }

  Future<void> updateProfile() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.twin.updateTwinUser(
        twinUserId: twinUserId,
        apikey: TwinnedSession.instance.authToken,
        body: TwinUserInfo(
          email: _emailController.text,
          name: toCamelCase(_nameController.text),
          address: _addressController.text,
          phone: _phoneController.text,
          description: _descController.text,
          countryCode: countryCode,
          clientIds: await getClientIds(),
        ),
      );

      if (validateResponse(res)) {
        alert(
          res.body!.entity!.name,
          'Profile saved successfully!',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
        TwinnedSession.instance.setUser(res.body!.entity!);
      }
    });

    loading = false;
    refresh();
  }

  Future<void> _editPersonalDetails(BuildContext context) async {
    final initialValues = {
      'Email': _emailController.text,
      'Name': _nameController.text,
      'Address': _addressController.text,
      'Phone': _phoneController.text,
      'Description': _descController.text,
      'countryCode': countryCode,
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
          titleTextStyle: theme
              .getStyle()
              .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          contentTextStyle: theme.getStyle(),
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
                              style: theme.getStyle(),
                              dropdownTextStyle: theme.getStyle(),
                              controller: controller,
                              keyboardType: TextInputType.phone,
                              initialCountryCode: countryCode,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                  errorStyle: theme.getStyle(),
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
                                  hintStyle: theme.getStyle()),
                              validator: (phone) {
                                if (phone == null || phone.number.isEmpty) {
                                  return 'Enter a valid phone number';
                                }
                                return null;
                              },
                              onChanged: (phone) {
                                setState(() {
                                  _isPhoneValid =
                                      phone.completeNumber.isNotEmpty &&
                                          phone.completeNumber.length >= 10 &&
                                          phone.isValidNumber();

                                  countryCode = phone.countryISOCode;
                                });
                              },
                              onCountryChanged: (country) {
                                setState(() {
                                  countryCode = country.code;
                                });
                              }),
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
                          _phoneController.text = _phoneController.text;
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

  void _onNameChanged() {
    setState(() {});
  }

  @override
  void setup() {
    load();
  }

  @override
  void dispose() {
    _phoneController.text = '';
    countryCode = 'US';

    _nameController.removeListener(_onNameChanged);

    super.dispose();
  }
}
