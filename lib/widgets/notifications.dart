import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twin_app/core/session_variables.dart';

class TankData {
  final String tankId;
  final String name;
  final DateTime triggeredTime;
  final String parameter;

  TankData({
    required this.tankId,
    required this.name,
    required this.triggeredTime,
    required this.parameter,
  });
}

List<TankData> getHardCodedTankData() {
  return [
    TankData(
      tankId: 'A123456',
      name: 'Bladder Storage 02',
      triggeredTime: DateTime(2023, 6, 15, 10, 30),
      parameter: 'level',
    ),
    TankData(
      tankId: 'B234567',
      name: 'Bladder Storage 02S',
      triggeredTime: DateTime(2023, 6, 15, 11, 0),
      parameter: 'temperature',
    ),
    TankData(
      tankId: 'C345678',
      name: 'Bladder 01',
      triggeredTime: DateTime(2023, 6, 15, 11, 30),
      parameter: 'level',
    ),
    TankData(
      tankId: 'D456789',
      name: 'Blader Storage',
      triggeredTime: DateTime(2023, 6, 15, 12, 0),
      parameter: 'temperature',
    ),
    TankData(
      tankId: 'E567890',
      name: 'Nalco Dual-Tank',
      triggeredTime: DateTime(2023, 6, 15, 12, 30),
      parameter: 'level',
    ),
    TankData(
      tankId: 'F678901',
      name: 'PValve #201',
      triggeredTime: DateTime(2023, 6, 15, 1, 0),
      parameter: 'temperature',
    ),
    TankData(
      tankId: 'G789012',
      name: 'PValve #202',
      triggeredTime: DateTime(2023, 6, 15, 1, 30),
      parameter: 'level',
    ),
    TankData(
      tankId: 'H890123',
      name: 'RIOT DEV B001',
      triggeredTime: DateTime(2023, 6, 15, 2, 0),
      parameter: 'temperature',
    ),
    TankData(
      tankId: 'I901234',
      name: 'RIOT DEV C001',
      triggeredTime: DateTime(2023, 6, 15, 2, 30),
      parameter: 'level',
    ),
    TankData(
      tankId: 'J012345',
      name: 'RIOT DEV S001',
      triggeredTime: DateTime(2023, 6, 15, 3, 0),
      parameter: 'temperature',
    ),
    TankData(
      tankId: 'I901235',
      name: 'RIOT DEV C002',
      triggeredTime: DateTime(2023, 6, 15, 4, 30),
      parameter: 'level',
    ),
  ];
}

class AlarmsNotificationsGrid extends StatefulWidget {
  const AlarmsNotificationsGrid({super.key});

  @override
  State<AlarmsNotificationsGrid> createState() =>
      _AlarmsNotificationsGridState();
}

class _AlarmsNotificationsGridState extends State<AlarmsNotificationsGrid> {
  late List<TankData> _tankData;

  @override
  void initState() {
    super.initState();
    _tankData = getHardCodedTankData();
  }

  Color _getRowColor(int index) {
    return index % 2 == 0 ? Colors.grey[200]! : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Alarms & Notifications',
            style: theme.getStyle().copyWith(
                  fontSize: 24,
                  color: theme.getPrimaryColor(),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: double.infinity,
          child: Table(
            border: TableBorder.all(color: Colors.grey, width: 1),
            columnWidths: {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(color: Color(0xFFACD0EC)),
                children: [
                  _buildTableCell('Name', true),
                  _buildTableCell('Tank ID', true),
                  _buildTableCell('Triggered Time', true),
                  _buildTableCell('Parameter', true),
                ],
              ),
              ..._tankData
                  .asMap()
                  .map((index, tank) {
                    return MapEntry(
                      index,
                      TableRow(
                        decoration: BoxDecoration(
                          color: _getRowColor(index),
                        ),
                        children: [
                          _buildTableCell(tank.name, false),
                          _buildTableCell(tank.tankId, false),
                          _buildTableCell(
                            DateFormat('yMd')
                                .add_jm()
                                .format(tank.triggeredTime),
                            false,
                          ),
                          _buildTableCell(tank.parameter, false),
                        ],
                      ),
                    );
                  })
                  .values
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, bool isHeading) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: theme.getStyle().copyWith(
              fontSize: 18,
              fontWeight: isHeading ? FontWeight.bold : FontWeight.normal,
            ),
      ),
    );
  }
}
