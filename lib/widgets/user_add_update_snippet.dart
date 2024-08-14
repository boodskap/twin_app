import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_app/widgets/commons/secondary_button.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twinned_api/twinned_api.dart' as twinned;
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

var userDefaultImage = Center(
  child: Image.asset(
    'assets/images/user.png',
    height: 100.0,
    width: 100.0,
    fit: BoxFit.contain,
  ),
);

class UserAddUpdateSnippet extends StatefulWidget {
  final twinned.TwinUser? twinUser;
  const UserAddUpdateSnippet({super.key, this.twinUser});

  @override
  State<UserAddUpdateSnippet> createState() => _UserAddUpdateSnippetState();
}

class _UserAddUpdateSnippetState extends BaseState<UserAddUpdateSnippet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isPhoneValid = true;
  String countryCode = 'US';

  twinned.TwinUserInfo _twinUserInfo = const twinned.TwinUserInfo(
      name: '',
      email: '',
      phone: '',
      address: '',
      tags: [],
      roles: [],
      images: [],
      clientIds: [],
      description: '',
      countryCode: 'US');

  @override
  void initState() {
    super.initState();
    if (null != widget.twinUser) {
      twinned.TwinUser u = widget.twinUser!;
      _twinUserInfo = _twinUserInfo.copyWith(
        name: u.name,
        email: u.email,
        phone: u.phone,
        countryCode: u.countryCode,
        address: u.address,
        clientIds: u.clientIds,
        description: u.description,
        images: u.images,
        roles: u.roles,
        selectedImage: u.selectedImage,
        tags: u.tags,
      );
    }
    nameController.text = _twinUserInfo.name;
    emailController.text = _twinUserInfo.email;
    phoneController.text = _twinUserInfo.phone ?? '';
    countryCode = _twinUserInfo.countryCode ?? '';
    nameController.addListener(_onNameChanged);
    emailController.addListener(_onNameChanged);
    phoneController.addListener(_onNameChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 2.5,
        height: MediaQuery.of(context).size.height / 1.1,
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.getPrimaryColor(),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Name',
                          style: theme.getStyle(),
                          controller: nameController,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.getPrimaryColor()),
                          ),
                        ),
                      ),
                      divider(height: 15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: LabelTextField(
                          label: 'Email',
                          style: theme.getStyle(),
                          controller: emailController,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.getPrimaryColor()),
                          ),
                        ),
                      ),
                      divider(height: 15),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: IntlPhoneField(
                          controller: phoneController,
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
                          ),
                          validator: (phone) {
                            if (phone == null || phone.number.isEmpty) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                          onChanged: (phone) {
                            setState(() {
                              _isPhoneValid = phone.completeNumber.isNotEmpty &&
                                  phone.completeNumber.length >= 10 &&
                                  phone.isValidNumber();

                              countryCode = phone.countryISOCode;

                              _twinUserInfo = _twinUserInfo.copyWith(
                                  countryCode: phone.countryISOCode);
                            });
                          },
                          onCountryChanged: (country) {
                            setState(() {
                              countryCode = country.code;

                              _twinUserInfo = _twinUserInfo.copyWith(
                                  countryCode: country.code);
                            });
                          },
                        ),
                      ),
                      divider(height: 15),
                      Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: theme.getPrimaryColor(), width: 1.0),
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Tooltip(
                                message: "Upload Image",
                                child: IconButton(
                                  icon: const Icon(Icons.upload),
                                  onPressed: () {
                                    _uploadImage();
                                  },
                                ),
                              ),
                            ),
                            if (_twinUserInfo.images!.isEmpty)
                              widget.twinUser == null
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Upload User image',
                                        style: theme.getStyle(),
                                      ),
                                    )
                                  : userDefaultImage,
                            if (_twinUserInfo.images!.isNotEmpty)
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 250,
                                  height: 250,
                                  child: TwinImageHelper.getDomainImage(
                                      _twinUserInfo.images!.first),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: theme.getPrimaryColor(),
              thickness: 1.0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    labelKey: 'Cancel',
                    onPressed: () {
                      _close();
                    },
                  ),
                  divider(horizontal: true),
                  PrimaryButton(
                    labelKey: (widget.twinUser == null) ? 'Create' : 'Update',
                    onPressed: !_canCreateOrUpdate()
                        ? null
                        : () {
                            _save();
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.removeListener(_onNameChanged);
    emailController.removeListener(_onNameChanged);
    phoneController.removeListener(_onNameChanged);
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  bool _canCreateOrUpdate() {
    final text = nameController.text.trim();
    final email = emailController.text;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return text.isNotEmpty &&
        text.length >= 3 &&
        email.isNotEmpty &&
        emailRegex.hasMatch(email) &&
        _isPhoneValid;
  }

  void _close() {
    Navigator.of(context).pop();
  }

  Future _save({bool silent = false}) async {
    if (loading) return;
    loading = true;

    _twinUserInfo = _twinUserInfo.copyWith(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        countryCode: countryCode);

    await execute(() async {
      if (null == widget.twinUser) {
        var cRes = await TwinnedSession.instance.twin.createTwinUser(
            apikey: TwinnedSession.instance.authToken, body: _twinUserInfo);
        if (validateResponse(cRes)) {
          _close();
          alert('Success', 'User ${_twinUserInfo.name} created');
        }
      } else {
        var uRes = await TwinnedSession.instance.twin.updateTwinUser(
          apikey: TwinnedSession.instance.authToken,
          twinUserId: widget.twinUser!.id,
          body: _twinUserInfo,
        );
        if (validateResponse(uRes)) {
          if (!silent) {
            _close();
            alert('Success', 'User ${_twinUserInfo.name} updated successfully');
          }
        }
      }
    });

    loading = false;
    refresh();
  }

  Future _uploadImage() async {
    if (loading) return;
    loading = true;
    String? tempImageId;

    await execute(() async {
      var uRes = await TwinImageHelper.uploadDomainImage();
      if (null != uRes && null != uRes.entity) {
        tempImageId = uRes.entity!.id;
      }
    });
    if (tempImageId != null) {
      refresh(
        sync: () {
          _twinUserInfo = _twinUserInfo.copyWith(images: [tempImageId!]);
        },
      );
    }

    loading = false;
    refresh();
  }

  @override
  void setup() {}
}
