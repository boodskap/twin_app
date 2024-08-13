import 'package:flutter/material.dart';
import 'package:twin_app/pages/nocodebuilder/foldable_card.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widgets.dart';
import 'package:twin_app/core/session_variables.dart';
import 'package:twin_commons/core/base_state.dart';

typedef OnPaletteWidgetPicked = void Function(
    String widgetId, TwinnedWidgetBuilder builder);

class WidgetPalette extends StatefulWidget {
  final OnPaletteWidgetPicked onPaletteWidgetPicked;
  const WidgetPalette({super.key, required this.onPaletteWidgetPicked});

  @override
  State<WidgetPalette> createState() => _WidgetPaletteState();
}

class _WidgetPaletteState extends BaseState<WidgetPalette> {
  static bool collapsed = false;
  final List<Widget> _chartsAndGraphs = [];
  final List<Tuple<String, TwinnedWidgetBuilder>> _allWidgets = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Fetch all widgets in the charts and graphs category
    var values = TwinnedWidgets.filterBuilders(PaletteCategory.chartsAndGraphs);
    
    // Store all widgets
    _allWidgets.addAll(values);
    
    // Initially, display all widgets
    for (var val in values) {
      _chartsAndGraphs.add(_buildPaletteIcon(val));
    }
    
    // Listen to search input changes
    _searchController.addListener(_filterWidgets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterWidgets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _chartsAndGraphs.clear();
      for (var val in _allWidgets) {
        if (val.value.getPaletteName().toLowerCase().contains(query)) {
          _chartsAndGraphs.add(_buildPaletteIcon(val));
        }
      }
    });
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
                val.value.getPaletteIcon(),
                Text(
                  val.value.getPaletteName(),
                  style: theme.getStyle().copyWith(
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
          headerStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          labelStyle: theme
              .getStyle()
              .copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          collapsed: collapsed,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                height: 40,
                child: SearchBar(
                  controller: _searchController,
                  hintStyle: WidgetStatePropertyAll(theme.getStyle()),
                  textStyle: WidgetStatePropertyAll(theme.getStyle()),
                  hintText: 'Search widgets',
                )),
            divider(),
            Text(
              'Charts & Graphs',
              style: theme.getStyle().copyWith(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.normal),
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

  @override
  void setup() {}
}
