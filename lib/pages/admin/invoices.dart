import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import 'package:flutter/services.dart';
import 'package:twin_commons/widgets/common/label_text_field.dart';
import 'package:twin_commons/core/base_state.dart';

class Invoices extends StatefulWidget {
  const Invoices({super.key});

  @override
  State<Invoices> createState() => _InvoicesState();
}

class _InvoicesState extends BaseState<Invoices> {
  @override
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
              hintText: "Search Invoices",
            ),
          ),
        ),
        divider(),
        const Expanded(
          child: AccordionPage(),
        ),
      ],
    );
  }

  @override
  void setup() {}
}

class AccordionPage extends StatefulWidget {
  const AccordionPage({super.key});

  @override
  State<AccordionPage> createState() => _AccordionPageState();
}

class _AccordionPageState extends State<AccordionPage> {
  TextEditingController invoiceNameController =
      TextEditingController(text: 'BASIC');

  TextEditingController invoiceAmountController =
      TextEditingController(text: '\$499.0');
  TextEditingController invoiceStatusController =
      TextEditingController(text: 'Completed');
  TextEditingController dueOnController =
      TextEditingController(text: '26 May 2024');
  TextEditingController paidOnController =
      TextEditingController(text: '26 May 2024');
  TextEditingController generatedController =
      TextEditingController(text: '26 May 2024');

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

  @override
  Widget build(BuildContext context) {
    return Accordion(
      headerBorderColor: Colors.blueGrey,
      headerBorderColorOpened: Colors.transparent,
      headerBorderWidth: 1,
      headerBackgroundColor: Colors.deepOrange.shade200,
      headerBackgroundColorOpened: Colors.lightBlueAccent,
      contentBackgroundColor: Colors.white,
      contentBorderColor: Colors.lightBlueAccent,
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
                  label: 'Invoice Name',
                  controller: invoiceNameController,
                ),
              ),
              SizedBox(
                width: 150,
                child: LabelTextField(
                  label: 'Invoice Amount',
                  controller: invoiceAmountController,
                  readOnlyVal: true,
                ),
              ),
              SizedBox(
                width: 150,
                child: LabelTextField(
                  label: 'Generated On',
                  controller: generatedController,
                ),
              ),
              SizedBox(
                width: 150,
                child: LabelTextField(
                  label: 'Due On',
                  controller: dueOnController,
                ),
              ),
              SizedBox(
                width: 150,
                child: LabelTextField(
                  label: 'Paid On',
                  controller: paidOnController,
                ),
              ),
              SizedBox(
                width: 150,
                child: LabelTextField(
                  label: 'Invoice Status',
                  controller: invoiceStatusController,
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
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Data Points',
                            controller: dataPointsController,
                            readOnlyVal: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            suffixText: dataPointsPriceController.text,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Devices',
                            controller: devicesController,
                            readOnlyVal: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            suffixText: devicesPriceController.text,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Device Libraries',
                            controller: deviceLibrariesController,
                            readOnlyVal: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            suffixText: deviceLibrariesPriceController.text,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Device Parameters',
                            controller: deviceParametersController,
                            readOnlyVal: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            suffixText: deviceParametersPriceController.text,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Users',
                            controller: usersController,
                            readOnlyVal: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            suffixText: usersPriceController.text,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Clients',
                            controller: clientsController,
                            readOnlyVal: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            suffixText: clientsPriceController.text,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Dashboards',
                            controller: dashboardsController,
                            readOnlyVal: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            suffixText: dashboardsPriceController.text,
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: LabelTextField(
                            label: 'Archivals',
                            controller: archivalController,
                            readOnlyVal: true,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            suffixText: archivalPriceController.text,
                          ),
                        ),
                      ]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget buildWrap(List<Widget> children) {
  return Wrap(
    spacing: 10.0,
    runSpacing: 10.0,
    children: children,
  );
}