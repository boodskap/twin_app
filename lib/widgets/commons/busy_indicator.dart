import 'package:flutter/material.dart';
import 'package:eventify/eventify.dart' as event;
import 'package:nocode_commons/core/base_state.dart';

class BusyIndicator extends StatefulWidget {
  final double? padding;
  final double? width;
  final double? height;
  const BusyIndicator({super.key, this.padding, this.width, this.height});

  @override
  State<BusyIndicator> createState() => _BusyIndicatorState();
}

class _BusyIndicatorState extends State<BusyIndicator> {
  final List<event.Listener> listeners = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    listeners
        .add(BaseState.layoutEvents.on(PageEvent.busyOn.name, this, (o, e) {
      if (mounted) {
        setState(() {
          _busy = true;
        });
      }
    }));
    listeners
        .add(BaseState.layoutEvents.on(PageEvent.busyOff.name, this, (o, e) {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }));
  }

  @override
  void dispose() {
    super.dispose();
    for (event.Listener l in listeners) {
      BaseState.layoutEvents.off(l);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_busy) {
      return Row(
        children: [
          SizedBox(
            width: widget.padding ?? 8,
          ),
          SizedBox(
            width: widget.width ?? 24,
            height: widget.height ?? 24,
            child: const CircularProgressIndicator(
              color: Colors.grey,
            ),
          ),
          SizedBox(
            width: widget.padding ?? 8,
          ),
        ],
      );
    }
    return const Text('');
  }
}
