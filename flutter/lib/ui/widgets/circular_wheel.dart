import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/accessibility.dart';
import '../../domain/option_item.dart';

class CircularWheel extends StatelessWidget {
  const CircularWheel(
      {super.key,
      required this.items,
      required this.turns,
      this.size = AppSizes.wheelSize,
      this.selectedIndex});

  final List<OptionItem> items;
  final Animation<double> turns;
  final double size;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
            child: RepaintBoundary(
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              RotationTransition(
                turns: turns,
                child: CustomPaint(
                  size: Size.square(size),
                  painter:
                      _WheelPainter(items: items, selectedIndex: selectedIndex),
                ),
              ),
              const _WheelPointer(),
            ],
          ),
        )),
        const SizedBox(height: Spacing.m),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: Spacing.m,
          runSpacing: Spacing.s,
          children: [
            for (var index = 0; index < items.length; index++)
              Semantics(
                  selected: selectedIndex == index,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                        selectedIndex == index
                            ? Icons.check_circle
                            : Icons.circle,
                        color: items[index].color),
                    const SizedBox(width: Spacing.xs),
                    Flexible(
                        child: Text(items[index].label,
                            style: Theme.of(context).textTheme.bodySmall)),
                  ])),
          ],
        ),
      ],
    );
  }
}

class _WheelPointer extends StatelessWidget {
  const _WheelPointer();

  @override
  Widget build(BuildContext context) => Transform.translate(
        offset: const Offset(0, -4),
        child: const Icon(Icons.arrow_drop_down,
            color: Colors.white, size: AppSizes.minTouchTarget),
      );
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter({required this.items, required this.selectedIndex});

  final List<OptionItem> items;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final section = 2 * math.pi / items.length;
    final start = -math.pi / 2 - section / 2;
    canvas.drawCircle(center, radius, Paint()..color = AppPalette.separator);
    canvas.drawCircle(center, radius - 2,
        Paint()..color = Colors.black.withValues(alpha: .22));
    final rect = Rect.fromCircle(center: center, radius: radius - 5);
    for (var index = 0; index < items.length; index++) {
      final item = items[index];
      final paint = Paint()..color = item.color;
      canvas.drawArc(rect, start + section * index, section, true, paint);
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selectedIndex == index ? 5 : 2
        ..color = selectedIndex == index
            ? Colors.white
            : Colors.black.withValues(alpha: 0.28);
      canvas.drawArc(rect, start + section * index, section, true, stroke);
      _paintLabel(canvas, center, radius, start + section * (index + .5), item);
    }
    canvas.drawCircle(center, 14, Paint()..color = Colors.white);
    canvas.drawCircle(
        center, 7, Paint()..color = Colors.black.withValues(alpha: 0.25));
  }

  void _paintLabel(Canvas canvas, Offset center, double radius, double angle,
      OptionItem item) {
    final text = TextPainter(
      text: TextSpan(
        text: item.label,
        style: TextStyle(
            color: readableForeground(item.color),
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.wheelLabelSize),
      ),
      maxLines: 2,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: radius * .7);
    final offset =
        center + Offset(math.cos(angle), math.sin(angle)) * (radius * .59);
    text.paint(canvas,
        Offset(offset.dx - text.width / 2, offset.dy - text.height / 2));
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.selectedIndex != selectedIndex ||
      !_hasSamePaintData(oldDelegate.items, items);

  bool _hasSamePaintData(List<OptionItem> previous, List<OptionItem> next) {
    if (identical(previous, next)) return true;
    if (previous.length != next.length) return false;
    for (var index = 0; index < previous.length; index++) {
      final oldItem = previous[index];
      final newItem = next[index];
      if (oldItem.id != newItem.id ||
          oldItem.label != newItem.label ||
          oldItem.color != newItem.color) {
        return false;
      }
    }
    return true;
  }
}
