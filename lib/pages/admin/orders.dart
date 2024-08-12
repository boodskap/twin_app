import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:accordion/accordion.dart';
import 'package:flutter/services.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_commons/core/base_state.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends BaseState<Orders> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        divider(),
        Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            width: 250,
            height: 30,
            child: SearchBar(
              onChanged: (value) {},
              hintText: "Search Orders",
            ),
          ),
        ),
        divider(),
        const Expanded(child: AccordionPage()),
      ],
    );
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}

class AccordionPage extends StatefulWidget {
  const AccordionPage({super.key});

  @override
  State<AccordionPage> createState() => _AccordionPageState();
}

class _AccordionPageState extends State<AccordionPage> {
  TextEditingController planNameController =
      TextEditingController(text: 'BASIC');
  TextEditingController planPriceController =
      TextEditingController(text: '\$499.0');
  TextEditingController orderAmountController =
      TextEditingController(text: '\$499.0');
  TextEditingController orderStatusController =
      TextEditingController(text: 'Completed');

  TextEditingController dataPointsController =
      TextEditingController(text: '20000');
  TextEditingController devicesController = TextEditingController(text: '10');
  TextEditingController deviceLibrariesController =
      TextEditingController(text: '5');
  TextEditingController deviceParametersController =
      TextEditingController(text: '25');
  TextEditingController usersController = TextEditingController(text: '3');
  TextEditingController clientsController = TextEditingController(text: '2');
  TextEditingController dashboardsController = TextEditingController(text: '5');
  TextEditingController archivalController = TextEditingController(text: '1');
  TextEditingController dataPointsPriceController =
      TextEditingController(text: '\$99.0');
  TextEditingController devicesPriceController =
      TextEditingController(text: '\$19.0');
  TextEditingController deviceLibrariesPriceController =
      TextEditingController(text: '\$100.0');
  TextEditingController deviceParametersPriceController =
      TextEditingController(text: '\$25.0');
  TextEditingController usersPriceController =
      TextEditingController(text: '\$20.0');
  TextEditingController clientsPriceController =
      TextEditingController(text: '\$200.0');
  TextEditingController dashboardsPriceController =
      TextEditingController(text: '\$250.0');
  TextEditingController archivalPriceController =
      TextEditingController(text: '\$99.0');
  bool isEditable = false;

  @override
  Widget build(BuildContext context) {
    return Accordion(
      headerBorderColor: Colors.blueGrey,
      headerBorderColorOpened: Colors.transparent,
      headerBorderWidth: 1,
      headerBackgroundColor: Colors.cyan,
      headerBackgroundColorOpened: Colors.yellow,
      contentBackgroundColor: Colors.white,
      contentBorderColor: Colors.yellow,
      contentBorderWidth: 3,
      contentHorizontalPadding: 20,
      scaleWhenAnimating: true,
      openAndCloseAnimation: true,
      headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
      children: [
        AccordionSection(
          isOpen: false,
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 150,
                child: LabelTextField(
                  label: 'Plan Name',
                  controller: planNameController,
                  readOnlyVal: true,
                ),
              ),
              SizedBox(
                width: 150,
                child: LabelTextField(
                  label: 'Plan Price',
                  controller: planPriceController,
                  readOnlyVal: true,
                ),
              ),
              SizedBox(
                width: 150,
                child: LabelTextField(
                  label: 'Order Amount',
                  controller: orderAmountController,
                  readOnlyVal: true,
                ),
              ),
              SizedBox(
                width: 150,
                child: LabelTextField(
                  label: 'Order Status',
                  controller: orderStatusController,
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                child: const Text(
                  'Pay',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: Column(
            children: [
              buildWrap(
                [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Tooltip(
                          message:
                              'Data point is a specific piece of information collected from IoT devices,'
                              '\nsuch as sensor readings, device status, or user interactions,'
                              '\nwhich is used for analysis and decision-making.',
                          child: SizedBox(
                            width: 150,
                            child: LabelTextField(
                              label: 'Data Points Count',
                              controller: dataPointsController,
                              readOnlyVal: !isEditable,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                        Tooltip(
                          message:
                              'Device is a physical object embedded with sensors, software, and'
                              '\nconnectivity to exchange data with other devices and systems over the internet',
                          child: SizedBox(
                            width: 150,
                            child: LabelTextField(
                              label: 'Devices Count',
                              controller: devicesController,
                              readOnlyVal: !isEditable,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                        Tooltip(
                          message:
                              'Device library describes the architecture and functionality of a connected device,'
                              '\ndetailing how it communicates, what are all the parameters (data) it communicates, etc.',
                          child: SizedBox(
                            width: 150,
                            child: LabelTextField(
                              label: 'Device Libraries Count',
                              controller: deviceLibrariesController,
                              readOnlyVal: !isEditable,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                        Tooltip(
                          message:
                              'Device parameter is a measurable attribute or setting of an IoT device,'
                              '\nsuch as temperature, humidity, or battery level, that can be monitored or controlled remotely.',
                          child: SizedBox(
                            width: 150,
                            child: LabelTextField(
                              label: 'Device Parameters Count',
                              controller: deviceParametersController,
                              readOnlyVal: !isEditable,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                        Tooltip(
                          message:
                              'User is an individual or entity that utilizes software systems to manage,'
                              '\nmonitor, and control IoT devices and data.',
                          child: SizedBox(
                            width: 150,
                            child: LabelTextField(
                              label: 'Users Count',
                              controller: usersController,
                              readOnlyVal: !isEditable,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                        Tooltip(
                          message:
                              'Client account allows users or devices under a separate account to access, manage,'
                              '\nand interact with IoT services and data, often with specific permissions and roles',
                          child: SizedBox(
                            width: 150,
                            child: LabelTextField(
                              label: 'Clients Count',
                              controller: clientsController,
                              readOnlyVal: !isEditable,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                        Tooltip(
                          message:
                              'Dashboard is a user interface that provides real-time monitoring, control,'
                              '\nand data visualization of connected devices and systems',
                          child: SizedBox(
                            width: 150,
                            child: LabelTextField(
                              label: 'Dashboards Count',
                              controller: dashboardsController,
                              readOnlyVal: !isEditable,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                        Tooltip(
                          message:
                              'Data archival refers to the process of systematically deleting'
                              '\ndevice data from to optimize storage and maintain performance.',
                          child: SizedBox(
                            width: 150,
                            child: LabelTextField(
                              label: 'Archivals Count',
                              controller: archivalController,
                              readOnlyVal: !isEditable,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ),
                      ]),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Data Points Price',
                            controller: dataPointsPriceController,
                            readOnlyVal: true,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Devices Price',
                            controller: devicesPriceController,
                            readOnlyVal: true,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Device Libraries Price',
                            controller: deviceLibrariesPriceController,
                            readOnlyVal: true,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Device Parameters Price',
                            controller: deviceParametersPriceController,
                            readOnlyVal: true,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Users Price',
                            controller: usersPriceController,
                            readOnlyVal: true,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Clients Price',
                            controller: clientsPriceController,
                            readOnlyVal: true,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Dashboards Price',
                            controller: dashboardsPriceController,
                            readOnlyVal: true,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Archivals Price',
                            controller: archivalPriceController,
                            readOnlyVal: true,
                          ),
                        ),
                      ]),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditable = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: const Text(
                        'Edit Orders',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _saveChanges();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _saveChanges() {
    setState(() {
      isEditable = false;
    });
  }
}

Widget buildWrap(List<Widget> children) {
  return Wrap(
    spacing: 10.0,
    runSpacing: 10.0,
    children: children,
  );
}
