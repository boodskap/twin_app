import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/widgets/commons/primary_button.dart';
import 'package:twin_commons/core/base_state.dart';

class TankData {
  final String tankId;
  final String name;
  final DateTime triggeredTime;
  final String eventName;
  final List<Alert> alerts;

  TankData({
    required this.tankId,
    required this.name,
    required this.triggeredTime,
    required this.eventName,
    required this.alerts,
  });
}

class Alert {
  final String type;
  final String subject;
  final String content;

  Alert({
    required this.type,
    required this.subject,
    required this.content,
  });
}

List<TankData> getHardCodedTankData() {
  return [
    TankData(
      tankId: 'A123456',
      name: 'Bladder Storage 02',
      triggeredTime: DateTime(2024, 7, 22, 10, 30),
      eventName: 'Tank Low Level Alert',
      alerts: [
        Alert(
            type: 'Email',
            subject: 'Tank Low Level Alert',
            content:
                '''<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <meta name="format-detection" content="telephone=no">
  <title></title>
  <style>
    .confirmbtn {
      padding: 10px;
      background: #E62365;
      border-radius: 5px;
      color: #ffffff !important;
      border: 1px solid #E62365;
      font-size: 15px;
      text-decoration: none;
    }

    h1 a {
      color: #2d3e50;
      text-decoration: none;
    }

    .workflow-header {
      border-bottom: 1px solid #ddd;
      padding: 10px;
      text-align: center;
      height: 10px;
      background: {{color}};
    }

    body,
    table,
    td,
    p,
    a,
    li,
    blockquote {
      -webkit-text-size-adjust: 100%;
      -ms-text-size-adjust: 100%;
    }

    table,
    td {
      mso-table-lspace: 0pt;
      mso-table-rspace: 0pt;
    }

    img {
      -ms-interpolation-mode: bicubic;
    }

    body {
      margin: 0;
      font-family: Helvetica;
      padding: 0;
    }

    img {
      border: 0;
      height: auto;
      line-height: 100%;
      outline: none;
      text-decoration: none;
    }

    table {
      border-collapse: collapse !important;
    }

    body,
    #bodyTable,
    #bodyCell {
      height: 100% !important;
      margin: 0;
      padding: 0;
      width: 100% !important;
    }

    #bodyCell {
      padding: 20px;
    }

    #templateContainer {
      width: 600px;
    }

    body,
    #bodyTable {
      background-color: #ffffff;
    }

    h1,
    h3 {
      font-family: Helvetica;
      font-style: normal;
      line-height: 100%;
      letter-spacing: normal;
      margin-right: 0;
      margin-left: 0;
      text-align: center;
    }

    h1 {
      font-size: 36px;
      margin-top: 30px;
      margin-bottom: 10px;
    }

    h3 {
      font-size: 17px;
      margin-top: 0;
      margin-bottom: 30px;
    }

    #templateBody {
      background-color: #ffffff;
      border-top: 1px solid #FFFFFF;
      border-bottom: 1px solid #CCCCCC;
    }

    .bodyContent {
      color: #505050;
      font-family: Helvetica;
      font-size: 16px;
      line-height: 112%;
      padding-right: 30px;
      padding-bottom: 30px;
      padding-left: 30px;
      text-align: left;
    }

    .bodyContent a:link,
    .bodyContent a:visited,
    .bodyContent a .yshortcuts {
      color: #EB4102;
      font-weight: normal;
      text-decoration: underline;
    }

    .bodyContent img {
      display: inline;
      height: auto;
      min-width: 100px;
    }

    .otp {
      font-size: 25px;
      letter-spacing: 5px;
    }

    @media only screen and (max-width: 480px) {

      body,
      table,
      td,
      p,
      a,
      li,
      blockquote {
        -webkit-text-size-adjust: none !important;
      }

      body {
        width: 100% !important;
        min-width: 100% !important;
      }

      #bodyCell {
        padding: 10px !important;
      }

      #templateContainer {
        max-width: 600px !important;
        width: 100% !important;
      }

      h1 {
        font-size: 30px !important;
        line-height: 100% !important;
      }

      h3 {
        font-size: 18px !important;
        line-height: 100% !important;
      }

      #bodyImage {
        height: auto !important;
        max-width: 560px !important;
        width: 100% !important;
      }

      .bodyContent {
        font-size: 18px !important;
        line-height: 125% !important;
      }
    }


    p a {
      color: #ffffff !important;

    }

    a {
      color: #444444 !important;
      text-decoration: none !important;
    }
  </style>
</head>
<center>
  <table align="center" border="0" cellpadding="0" cellspacing="0" height="100%" id="bodyTable" width="100%">
    <tbody>
      <tr>
        <td align="center" id="bodyCell" valign="top" style="background-color: #eeeeee;">
          <table border="0" cellpadding="0" cellspacing="0" id="templateContainer" style="width: 600px;">
            <tbody>
              <tr>
                <td align="center" valign="top">
                  <table bgcolor="#ebebeb" border="0" cellpadding="0" cellspacing="0" class="ct-container" style="margin: auto; background-color:#ffffff;" width="100%">
                    <tbody>
                      <tr>
                        <td>
                          <div class="workflow-header">
                            <div style="float: left;">
                            </div>
                          </div>
                          <table border="0" cellpadding="0" cellspacing="0" id="templateBody" width="100%">
                            <tbody>
                              <tr>
                                <td>
                                  <h1 style="text-align: left; padding-left: 10px">{{event}}</h1>
                                </td>
                              </tr>
                              <tr>
                                <td class="bodyContent" mc:edit="body_content00" valign="top" style="padding-bottom:0px;">
                                  <h3 style="color:#2d3e50; font-size:14px; text-align: left;">{{time}}</h3>
                                </td>
                              </tr>
                             <tr>
                              <td class="bodyContent" mc:edit="body_content00" valign="top" style="padding-bottom:5px;">
                                <h3 style="color:#2d3e50; font-size:24px;font-weight:bold; text-align: center;">{{message}}</h3>
                              </td>
                              </tr>
                    </tbody>
                  </table>
                </td>
              </tr>
            </tbody>
          </table>
        </td>
      </tr>
      <tr>
        <td align="center" valign="top">
          <div mc:edit="footertext" style="text-align: center;background-color: #3e3b3b;font-size:13px; padding-bottom: 0px;padding-top: 10px;padding-left:10px;padding-right:10px;color: #fff;">
            <p style="color: #fff;">
              <span href="" style="color: #fff;font-size: 13px;margin-bottom:10px;text-decoration:none;font-family:arial,sans-serif;" target="">If you would prefer to no longer receive messages like this you can <a href="http://tracking.boodskap.io/tracking/unsubscribe?msgid=UJT9R_VgjMnRtBO0okU3jw2&c=1180062405439469098" target="_blank" style="color:#fff;"> Unsubscribe.</a> If you have any questions or concerns,
    please contact us <a href="https://boodskap.io/contact-us" style="border: none; color:#fff;text-decoration:none;">at boodskap/contact-us.</a></span>

            </p>
            <p style="color: #fff;margin-bottom:10px;text-decoration:none;font-family:arial,sans-serif;font-size: 12px; margin-bottom: 0px;">
              <a href="https://boodskap.io/privacy-policy" style="color: #fff;margin-bottom:0px;text-decoration:none;font-family:arial,sans-serif;">Privacy
                Policy</a><span style="display: inline-block; width: 4px; height: 4px; -moz-border-radius: 7.5px; -webkit-border-radius: 7.5px; border-radius: 7.5px;background-color: #fff;margin: 2px 4px;"></span><a href="https://boodskap.io/contact-us" style="border: none; text-decoration:none; color: #fff;"><span>Contact us</span></a><span style="display: inline-block; width: 4px; height: 4px; -moz-border-radius: 7.5px; -webkit-border-radius: 7.5px; border-radius: 7.5px;background-color: #fff;margin: 2px 4px;"></span><a href="https://boodskap.io/" style="border: none; text-decoration:none; color: #fff;"><span>Read our blog</span></a>
            </p>
            <div mc:edit="socialicons" style="text-align: center;background-color: #3e3b3b;padding-top: 0px;">
              <br>
              <a href="https://www.linkedin.com/company/boodskap/" style="border:none;" target="_blank">
                <img alt="linkedin" src="https://static.boodskap.io/linkedin.png" style="width: 22px; padding-left:16px"></a>
              <a href="https://www.facebook.com/boodskapiot" style="border:none;" target="_blank"><img alt="Facebook" src="https://static.boodskap.io/fb.png" style="width: 22px; padding-left:16px;"></a>
              <a href="https://twitter.com/boodskapiot?lang=en" style="border:none;" target="_blank"> <img alt="twitter" src="https://static.boodskap.io/twitter.png" style="width: 22px; padding-left:16px;">
              </a>
            </div>
            <p style="color:#fff !important;font-family:arial,sans-serif;margin-bottom: 0px; margin-top: 0px; font-size: 12px;">
              <br>
    © All rights reserved.<br>
              <br>
    Powered by<a href="https://boodskap.io/" style="color:#fff; text-decoration:none"> Boodskap
                Inc.</a><br>
              <br>
    &nbsp;
            </p>
          </div>

        </td>
      </tr>
    </tbody>
  </table>
  </td>
  </tr>
  </tbody>
  </table>
</center>

</html>'''),
      ],
    ),
    TankData(
      tankId: 'A123456',
      name: 'Bladder Storage 02',
      triggeredTime: DateTime(2024, 7, 15, 10, 30),
      eventName: 'Tank overflow Alert',
      alerts: [
        Alert(
          type: 'SMS',
          subject: 'Tank Overflow Alert',
          content:
              'This is an urgent alert indicating that the tank level has exceeded the defined threshold. Immediate action is required to prevent potential damage or overflow..',
        ),
      ],
    ),
    TankData(
      tankId: 'A123456',
      name: 'Bladder Storage 02',
      triggeredTime: DateTime(2024, 7, 17, 10, 30),
      eventName: 'Tank Low Level Alert',
      alerts: [
        Alert(
          type: 'Voice',
          subject: '',
          content: 'Voice alert content.',
        ),
        Alert(
          type: 'SMS',
          subject: '',
          content: 'SMS alert content.',
        ),
      ],
    ),
    TankData(
      tankId: 'A123456',
      name: 'Bladder Storage 02',
      triggeredTime: DateTime(2024, 7, 20, 10, 30),
      eventName: 'Tank overflow Alert',
      alerts: [
        Alert(
          type: 'SMS',
          subject: 'Tank Overflow Alert',
          content:
              'This is an urgent alert indicating that the tank level has exceeded the defined threshold. Immediate action is required to prevent potential damage or overflow..',
        ),
      ],
    ),
    TankData(
      tankId: 'A123456',
      name: 'Bladder Storage 02',
      triggeredTime: DateTime(2024, 7, 21, 10, 30),
      eventName: 'Tank overflow Alert',
      alerts: [
        Alert(
          type: 'SMS',
          subject: 'Tank Overflow Alert',
          content:
              'This is an urgent alert indicating that the tank level has exceeded the defined threshold. Immediate action is required to prevent potential damage or overflow..',
        ),
      ],
    ),
    TankData(
      tankId: 'A123456',
      name: 'Bladder Storage 02',
      triggeredTime: DateTime(2024, 7, 22, 10, 30),
      eventName: 'Tank overflow Alert',
      alerts: [
        Alert(
          type: 'SMS',
          subject: 'Tank Overflow Alert',
          content:
              'This is an urgent alert indicating that the tank level has exceeded the defined threshold. Immediate action is required to prevent potential damage or overflow..',
        ),
      ],
    ),
    TankData(
      tankId: 'A123456',
      name: 'Bladder Storage 02',
      triggeredTime: DateTime(2024, 7, 22, 10, 30),
      eventName: 'Tank overflow Alert',
      alerts: [
        Alert(
          type: 'SMS',
          subject: 'Tank Overflow Alert',
          content:
              'This is an urgent alert indicating that the tank level has exceeded the defined threshold. Immediate action is required to prevent potential damage or overflow..',
        ),
      ],
    ),
  ];
}

class AlarmsNotificationsGrid extends StatefulWidget {
  const AlarmsNotificationsGrid({super.key});

  @override
  State<AlarmsNotificationsGrid> createState() =>
      _AlarmsNotificationsGridState();
}

class _AlarmsNotificationsGridState extends BaseState<AlarmsNotificationsGrid> {
  late List<TankData> _tankData;
  int _currentPage = 0;
  static const int _itemsPerPage = 5;
  String _selectedFilter = 'Recent';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tankData = getHardCodedTankData();
  }

  List<TankData> _getFilteredData() {
    DateTime now = DateTime.now();
    DateTime startOfToday = DateTime(now.year, now.month, now.day);
    DateTime startOfYesterday = startOfToday.subtract(Duration(days: 1));

    DateTime startOfWeek =
        startOfToday.subtract(Duration(days: now.weekday - 1));
    DateTime startOfMonth = DateTime(now.year, now.month, 1);

    switch (_selectedFilter) {
      case 'Today':
        return _tankData
            .where((data) => data.triggeredTime.isAfter(startOfToday))
            .toList();
      case 'Yesterday':
        return _tankData
            .where((data) =>
                data.triggeredTime.isAfter(startOfYesterday) &&
                data.triggeredTime.isBefore(startOfToday))
            .toList();
      case 'This Week':
        return _tankData
            .where((data) =>
                data.triggeredTime.isAfter(startOfWeek) &&
                data.triggeredTime.isBefore(startOfToday))
            .toList();
      case 'This Month':
        return _tankData
            .where((data) =>
                data.triggeredTime.isAfter(startOfMonth) &&
                data.triggeredTime.isBefore(startOfToday))
            .toList();
      case 'Date Range':
        if (_selectedDateRange != null) {
          return _tankData
              .where((data) =>
                  data.triggeredTime.isAfter(_selectedDateRange!.start) &&
                  data.triggeredTime.isBefore(_selectedDateRange!.end))
              .toList();
        }
        return _tankData;
      default:
        return _tankData;
    }
  }

  List<TankData> _getPaginatedData() {
    final filteredData = _getFilteredData();
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;
    return filteredData.sublist(
      start,
      end > filteredData.length ? filteredData.length : end,
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _selectedFilter = 'Date Range';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Alarms & Notifications',
            style: TextStyle(
              fontSize: 24,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 1.5,
          child: Column(
            children: [
              _buildFilterDropdown(),
              _buildTableHeader(),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _buildTableRows(),
                ),
              ),
              divider(),
              _buildPaginationControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DropdownButton<String>(
            value: _selectedFilter,
            items: <String>[
              'Recent',
              'Today',
              'Yesterday',
              'This Week',
              'This Month',
              'Date Range'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedFilter = newValue!;
                if (_selectedFilter != 'Date Range') {
                  _selectedDateRange = null;
                }
              });
            },
          ),
          if (_selectedFilter == 'Date Range')
            TextButton(
              onPressed: () => _selectDateRange(context),
              child: Text('Select Date Range'),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Table(
      border: TableBorder.all(color: Colors.grey, width: 1),
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2.5),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Color(0xFFACD0EC)),
          children: [
            _buildTableCell('Name', true),
            _buildTableCell('Tank ID', true),
            _buildTableCell('Triggered Time', true),
            _buildTableCell('EventType', true),
          ],
        ),
      ],
    );
  }

  Widget _buildTableRows() {
    return Column(
      children: _getPaginatedData()
          .asMap()
          .map((index, tank) {
            return MapEntry(
              index,
              ExpansionTile(
                title: Table(
                  columnWidths: {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: _getRowColor(index),
                      ),
                      children: [
                        _buildTableCell(tank.name, false),
                        _buildTableCell(tank.tankId, false),
                        _buildTableCell(
                          DateFormat('yMd').add_jm().format(tank.triggeredTime),
                          false,
                        ),
                        _buildTableCell(tank.eventName, false),
                      ],
                    ),
                  ],
                ),
                children: tank.alerts.map((alert) {
                  return Container(
                    color: Colors.grey[
                        100], // Optional: Different background color for alert rows
                    child: ListTile(
                      title: Text(alert.type),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.subject,
                            style: theme
                                .getStyle()
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          HtmlWidget(alert.content),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.content_copy),
                                onPressed: () {},
                              ),
                             
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          })
          .values
          .toList(),
    );
  }

  Color _getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey[200]! : Colors.white;
  }

  Widget _buildTableCell(String text, bool isHeading) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeading ? 20 : 14,
          fontWeight: isHeading ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (_getFilteredData().length / _itemsPerPage).ceil();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PrimaryButton(
            onPressed: _currentPage > 0
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                  }
                : null,
            labelKey: 'Previous',
          ),
          divider(horizontal: true),
          Text('Page ${_currentPage + 1} of $totalPages'),
          divider(horizontal: true),
          PrimaryButton(
            onPressed: _currentPage < totalPages - 1
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                  }
                : null,
            labelKey: 'Next',
          ),
          divider(horizontal: true),
        ],
      ),
    );
  }

  @override
  void setup() {}
}
