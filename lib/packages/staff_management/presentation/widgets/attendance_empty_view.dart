import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class AttendanceEmptyView extends StatelessWidget {
  final String? message;

  const AttendanceEmptyView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message ??
            (context.tr(
                  shared.LocaleKeys.noAttendanceRecords,
                  track: shared.TrackConstants.staffManagementPageTrack,
                ) ??
                'No Attendance Records'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
