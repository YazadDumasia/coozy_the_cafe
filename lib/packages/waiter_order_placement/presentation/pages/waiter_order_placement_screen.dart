import 'package:coozy_the_cafe/packages/core/coozy_core.dart';
import 'package:coozy_the_cafe/packages/shared/config/app_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WaiterOrderPlacementScreen extends StatefulWidget {
  const WaiterOrderPlacementScreen({super.key});

  @override
  State<WaiterOrderPlacementScreen> createState() =>
      _WaiterOrderPlacementScreenState();
}

class _WaiterOrderPlacementScreenState
    extends State<WaiterOrderPlacementScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Material(
              type: MaterialType.card,
              child: Card(
                margin: EdgeInsets.all(20),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    context.push(AppRoutePath.tablePickerScreenRoute);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.add_circled_solid,
                        size: 30,
                        color: Colors.green,
                      ),
                      Text(
                        'Add New Order',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ).inExpandedRow().paddingSymmetric(vertical: 10),
                    ],
                  ).paddingSymmetric(horizontal: 10, vertical: 40),
                ),
              ),
            ).inExpandedRow(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
