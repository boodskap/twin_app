import 'package:flutter/material.dart';

typedef OnMoveClicked = void Function();

class MoveLeftRightTopBottomWidget extends StatefulWidget {
  final int currentIndex;
  final int totalItems;
  final Axis direction;
  final OnMoveClicked onMoveBack;
  final OnMoveClicked onMoveFront;
  const MoveLeftRightTopBottomWidget(
      {super.key,
      required this.currentIndex,
      required this.totalItems,
      required this.direction,
      required this.onMoveBack,
      required this.onMoveFront});

  @override
  State<MoveLeftRightTopBottomWidget> createState() =>
      _MoveLeftRightTopBottomWidgetState();
}

class _MoveLeftRightTopBottomWidgetState
    extends State<MoveLeftRightTopBottomWidget> {
  @override
  Widget build(BuildContext context) {
    bool backEnabled = widget.currentIndex > 0;
    bool frontEnabled = widget.currentIndex < (widget.totalItems - 1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.direction == Axis.horizontal)
          InkWell(
              onTap: backEnabled
                  ? () {
                      widget.onMoveBack();
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.arrow_back,
                  color: backEnabled ? Colors.lightGreen : Colors.grey,
                ),
              )),
        if (widget.direction == Axis.vertical)
          InkWell(
              onTap: backEnabled
                  ? () {
                      widget.onMoveBack();
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.arrow_upward,
                  color: backEnabled ? Colors.lightGreen : Colors.grey,
                ),
              )),
        if (widget.direction == Axis.horizontal)
          InkWell(
              onTap: frontEnabled
                  ? () {
                      widget.onMoveFront();
                    }
                  : null,
              child: Icon(
                Icons.arrow_forward,
                color: frontEnabled ? Colors.lightGreen : Colors.grey,
              )),
        if (widget.direction == Axis.vertical)
          InkWell(
              onTap: frontEnabled
                  ? () {
                      widget.onMoveFront();
                    }
                  : null,
              child: Icon(
                Icons.arrow_downward,
                color: frontEnabled ? Colors.lightGreen : Colors.grey,
              )),
      ],
    );
  }
}
