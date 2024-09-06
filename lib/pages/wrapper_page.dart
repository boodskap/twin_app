import 'package:flutter/Material.dart';
import 'package:twin_app/core/session_variables.dart';

class WrapperPage extends StatelessWidget {
  final String title;
  final Widget child;
  const WrapperPage({super.key, required this.title, required this.child});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.getPrimaryColor(),
        centerTitle: true,
        leading: const BackButton(
          color: Color(0XFFFFFFFF),
        ),
        title: Text(title,
            style: theme.getStyle().copyWith(
                  color: Color(0XFFFFFFFF),
                )),
      ),
      body: Column(
        children: [
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
