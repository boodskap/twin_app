import 'package:flutter/material.dart';
import 'package:twin_app/pages/nocodebuilder/foldable_card.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widgets.dart';
import 'dart:html' as html;

typedef OnPaletteWidgetPicked = void Function(
    String widgetId, TwinnedWidgetBuilder builder);

class WidgetPalette extends StatefulWidget {
  final OnPaletteWidgetPicked onPaletteWidgetPicked;
  const WidgetPalette({super.key, required this.onPaletteWidgetPicked});

  @override
  State<WidgetPalette> createState() => _WidgetPaletteState();
}

class _WidgetPaletteState extends State<WidgetPalette> {
  static const labelStyle = TextStyle(
      color: Colors.black, fontSize: 12, fontWeight: FontWeight.normal);

  static bool collapsed = false;

  final List<Widget> _chartsAndGraphs = [];

  @override
  void initState() {
    var values = TwinnedWidgets.filterBuilders(PaletteCategory.chartsAndGraphs);
    for (var val in values) {
      _chartsAndGraphs.add(_buildPaletteIcon(val));
    }
    super.initState();
  }

  Widget _buildPaletteIcon(Tuple<String, TwinnedWidgetBuilder> val) {
    return InkWell(
      onDoubleTap: () {
        widget.onPaletteWidgetPicked(val.key, val.value);
      },
      child: Tooltip(
        message: val.value.getPaletteTooltip(),
        child: SizedBox(
          width: 150,
          child: Card(
            elevation: 5,
            child: Wrap(
              spacing: 8.0,
              direction: Axis.vertical,
              children: [
                // InkWell(
                //     onTap: () {
                //       html.window.open(
                //           '$baseDocUrl/${val.key.toLowerCase()}', 'new tab');
                //     },
                //     child: val.value.getPaletteIcon()),
                Text(
                  val.value.getPaletteName(),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FoldableCard(
          title: 'Widgets',
          collapsed: collapsed,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                height: 40,
                child: const SearchBar(
                  hintText: 'search widgets',
                )),
            const Text(
              'Charts & Graphs',
              style: labelStyle,
            ),
            Wrap(
              spacing: 8.0,
              children: _chartsAndGraphs,
            ),
          ],
          onCollapsed: (value) {
            setState(() {
              collapsed = value;
            });
          },
        ),
      ],
    );
  }
}
