import 'package:flutter/material.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;

class LeaveEmptyView extends StatelessWidget {
  final String? message;

  const LeaveEmptyView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message ??
            (context.tr(
                  shared.LocaleKeys.noLeaveApplications,
                  track: shared.TrackConstants.staffManagementPageTrack,
                ) ??
                'No Leave Applications'),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
