import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/country_codes.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

// ignore: must_be_immutable
class AddEditPhoneGroup extends StatefulWidget {
  pulse.SmsGroup? SmsGroup;
  pulse.VoiceGroup? VoiceGroup;
  final ValueChanged<String> onNameSaved;
  final ValueChanged<List<pulse.PhoneNumber>> onPhoneNumberSaved;

  AddEditPhoneGroup({
    super.key,
    required this.onNameSaved,
    required this.onPhoneNumberSaved,
    this.SmsGroup,
    this.VoiceGroup,
  });
  @override
  _AddEditPhoneGroupState createState() => _AddEditPhoneGroupState();
}

class _AddEditPhoneGroupState extends BaseState<AddEditPhoneGroup> {
  final TextEditingController _nameController = TextEditingController();
  pulse.PhoneNumber? selectedPhoneNumber;
  List<pulse.PhoneNumber> _phoneNumbers = [];
  bool _isPhoneNumberValid = false;
  bool _isEditPhoneNumberValid = true;
  String initialPhoneNumber = '';
  @override
  void initState() {
    super.initState();
    selectedPhoneNumber = pulse.PhoneNumber(countryCode: '', phoneNumber: '');
    if (widget.SmsGroup != null) {
      _phoneNumbers = widget.SmsGroup!.phoneList;
      _nameController.text = widget.SmsGroup!.name;
    }
     if (widget.VoiceGroup != null) {
      _phoneNumbers = widget.VoiceGroup!.phoneList;
      _nameController.text = widget.VoiceGroup!.name;
    }
  }

  void _addPhoneNumber() {
    if (selectedPhoneNumber != null &&
        !_phoneNumbers.contains(selectedPhoneNumber)) {
      setState(() {
        _phoneNumbers.add(selectedPhoneNumber!);
        widget.onPhoneNumberSaved(_phoneNumbers);
      });
    } else {
      alert(
        'Warning',
        'This phone number is already added',
        titleStyle: theme
            .getStyle()
            .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
        contentStyle: theme.getStyle(),
      );
    }
  }

  void _editPhoneNumber(int index) {
    String currentPhoneNumber = _phoneNumbers[index].phoneNumber;
    String currentCountryCode = _phoneNumbers[index].countryCode ?? 'US';
print(currentPhoneNumber);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Phone Number',
            style: theme.getStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
        content: Container(
          width: MediaQuery.of(context).size.width * 0.2,
          height: 120,
          child: Column(
            children: [
              IntlPhoneField(
                initialValue: currentPhoneNumber,
                initialCountryCode:
                    currentCountryCode, 
                decoration: InputDecoration(
                    labelText: "Edit phone number", counterText: ''),
                
                onCountryChanged: (country) {
                  setState(() {
                    selectedPhoneNumber = selectedPhoneNumber!
                        .copyWith(countryCode: country.code);
                  });
                },
                onChanged: (currentphone) {
                  try {
                    setState(() {
                      selectedPhoneNumber = pulse.PhoneNumber(
                        countryCode: currentphone.countryISOCode,
                        phoneNumber: currentphone.number,
                      );

                      _isEditPhoneNumberValid = currentphone.isValidNumber();
                    });
                  } on NumberTooShortException catch (e) {
                    setState(() {
                      _isEditPhoneNumberValid = false;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              if (_isEditPhoneNumberValid) {
                return _saveEditedPhoneNumber(index);
              } else {
                return null;
              }
            },
          ),
        ],
      ),
    );
  }

  void _saveEditedPhoneNumber(int index) {
    if (_phoneNumbers.isNotEmpty) {
      if (!_phoneNumbers.contains(selectedPhoneNumber) ||
          _phoneNumbers[index] == selectedPhoneNumber) {
        setState(() {
          _phoneNumbers[index] = selectedPhoneNumber!;
          widget.onPhoneNumberSaved(_phoneNumbers);
        });
        Navigator.of(context).pop();
      } else {
        alert(
          'Warning',
          'This phone number is already in the list',
          titleStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentStyle: theme.getStyle(),
        );
      }
    }
  }

  void _removePhoneNumber(int index) {
    setState(() {
      _phoneNumbers.removeAt(index);
      widget.onPhoneNumberSaved(_phoneNumbers);
    });
  }

  String formatPhoneNumber(String? phoneNumber, String countryCode) {
    final countryDialCode = countryCodeMap[countryCode] ?? '';

    return phoneNumber != null && phoneNumber.isNotEmpty
        ? '$countryDialCode $phoneNumber'
        : '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameController,
          onChanged: (value) {
            widget.onNameSaved(_nameController.text);
          },
          decoration: InputDecoration(
            labelText: 'Name',
          ),
        ),
        IntlPhoneField(
          decoration: InputDecoration(
            labelText: 'Phone Number',
            counterText: '',
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: _isPhoneNumberValid ? _addPhoneNumber : null,
            ),
          ),
          initialValue: initialPhoneNumber,
          initialCountryCode: 'US',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onCountryChanged: (country) {
            setState(() {
              selectedPhoneNumber =
                  selectedPhoneNumber!.copyWith(countryCode: country.code);
            });
          },
          onChanged: (phone) {
            try {
              setState(() {
                selectedPhoneNumber = pulse.PhoneNumber(
                  countryCode: phone.countryISOCode,
                  phoneNumber: phone.number,
                );
                _isPhoneNumberValid = phone.isValidNumber();
                initialPhoneNumber = phone.number;
              });
            } on NumberTooShortException catch (e) {
              setState(() {
                _isPhoneNumberValid = false;
              });
            }
          },
        ),
        SizedBox(height: 20),
        Expanded(
          child: _phoneNumbers.isNotEmpty
              ? ListView.builder(
                  itemCount: _phoneNumbers.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(formatPhoneNumber(
                          _phoneNumbers[index].phoneNumber,
                          _phoneNumbers[index].countryCode)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editPhoneNumber(index),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _removePhoneNumber(index),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Center(
                  child: Text('No phone numbers added'),
                ),
        ),
      ],
    );
  }

  @override
  void setup() {}
}


