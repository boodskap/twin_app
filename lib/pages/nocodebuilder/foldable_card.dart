import 'package:flutter/material.dart';

typedef OnCollapsed = void Function(bool collapsed);

class FoldableCard extends StatefulWidget {
  final String title;
  final double elevation;
  final bool collapsed;
  final TextStyle headerStyle;
  final TextStyle labelStyle;
  final List<Widget> children;
  final Widget? icon;
  final OnCollapsed onCollapsed;
  const FoldableCard(
      {super.key,
      required this.title,
      this.elevation = 5,
      this.collapsed = false,
      this.headerStyle = const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis),
      this.labelStyle = const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          overflow: TextOverflow.ellipsis),
      this.icon,
      this.children = const [],
      required this.onCollapsed});

  @override
  State<FoldableCard> createState() => _FoldableCardState();
}

class _FoldableCardState extends State<FoldableCard> {
  bool collapsed = false;

  @override
  void initState() {
    collapsed = widget.collapsed;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.greenAccent,
        ),
      ),
      elevation: widget.elevation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  collapsed = !collapsed;
                });
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Wrap(
                  spacing: 10.0,
                  children: [
                    if (null != widget.icon) widget.icon!,
                    Text(
                      widget.title,
                      style: widget.headerStyle,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 1,
                child: Container(
                  color: Colors.greenAccent.withBlue(50),
                )),
            if (widget.children.isNotEmpty && !collapsed)
              const SizedBox(
                height: 8,
              ),
            if (widget.children.isNotEmpty && !collapsed) ...widget.children
          ],
        ),
      ),
    );
  }
}
