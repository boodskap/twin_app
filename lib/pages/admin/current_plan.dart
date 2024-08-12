import 'package:flutter/material.dart';
import 'package:twin_app/core/session_variables.dart';

class CurrentPlan extends StatefulWidget {
  const CurrentPlan({super.key});

  @override
  State<CurrentPlan> createState() => _CurrentPlanState();
}

class _CurrentPlanState extends State<CurrentPlan> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'CURRENT PLAN',
        style: theme.getStyle().copyWith(
              fontSize: 20,
            ),
      ),
    );
  }
}
