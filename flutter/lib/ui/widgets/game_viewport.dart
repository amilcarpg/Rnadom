import 'package:flutter/material.dart';

/// Center short games and allow scrolling with a keyboard or enlarged text.
class GameViewport extends StatelessWidget {
  const GameViewport({super.key, required this.builder});

  final Widget Function(BuildContext, BoxConstraints) builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: builder(context, constraints)),
          ),
        ),
      );
}
