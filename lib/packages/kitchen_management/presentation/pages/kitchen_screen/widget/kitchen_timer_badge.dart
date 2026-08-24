import 'dart:async';
import 'package:flutter/material.dart';


class KitchenTimerBadge extends StatefulWidget {
  final String? creationDate;

  const KitchenTimerBadge({super.key, this.creationDate});

  @override
  State<KitchenTimerBadge> createState() => _KitchenTimerBadgeState();
}

class _KitchenTimerBadgeState extends State<KitchenTimerBadge> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateElapsed();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateElapsed();
    });
  }

  void _calculateElapsed() {
    if (widget.creationDate == null) return;
    try {
      final created = DateTime.tryParse(widget.creationDate!);
      if (created != null && mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(created);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getBadgeColor(BuildContext context) {
    final minutes = _elapsed.inMinutes;
    if (minutes < 5) {
      return Colors.green;
    } else if (minutes < 10) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _getBadgeColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            _formatDuration(_elapsed),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
