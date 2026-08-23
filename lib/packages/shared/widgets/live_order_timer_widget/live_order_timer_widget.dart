import 'dart:async';
import 'package:flutter/material.dart';

class LiveOrderTimerWidget extends StatefulWidget {
  final DateTime? creationDate;
  final TextStyle? style;
  final IconData? icon;
  final Color? iconColor;

  const LiveOrderTimerWidget({
    super.key,
    this.creationDate,
    this.style,
    this.icon,
    this.iconColor,
  });

  @override
  State<LiveOrderTimerWidget> createState() => _LiveOrderTimerWidgetState();
}

class _LiveOrderTimerWidgetState extends State<LiveOrderTimerWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant LiveOrderTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.creationDate != widget.creationDate) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.creationDate != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(DateTime? creationDate) {
    if (creationDate == null) return '0m:0s';
    final now = DateTime.now();
    final creationLocal = creationDate.toLocal();
    final diff = now.difference(creationLocal);
    if (diff.isNegative) return '0m:0s';
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h:${minutes}m:${seconds}s';
    }
    return '${minutes}m:${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _formatDuration(widget.creationDate);

    if (widget.icon == null) {
      return Text(formatted, style: widget.style);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(widget.icon, size: 16, color: widget.iconColor),
        const SizedBox(width: 4),
        Text(formatted, style: widget.style),
      ],
    );
  }
}
