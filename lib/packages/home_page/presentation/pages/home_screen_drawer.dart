import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/coozy_core.dart' as core;

import '../../../shared/coozy_shared.dart' as shared;
import 'package:package_info_plus/package_info_plus.dart';
import 'home_screen_drawer_actions.dart';

class HomeScreenDrawer extends StatefulWidget {
  const HomeScreenDrawer({super.key});

  @override
  State<HomeScreenDrawer> createState() => _HomeScreenDrawerState();
}

class _HomeScreenDrawerState extends State<HomeScreenDrawer> {
  final ValueNotifier<PackageInfo> _packageInfoNotifier = ValueNotifier(
    PackageInfo(
      appName: 'Unknown',
      packageName: 'Unknown',
      version: 'Unknown',
      buildNumber: 'Unknown',
      buildSignature: 'Unknown',
      installerStore: 'Unknown',
    ),
  );

  @override
  void initState() {
    super.initState();
    HomeScreenDrawerActions.initPackageInfo().then((info) {
      if (mounted) {
        _packageInfoNotifier.value = info;
      }
    });
  }

  @override
  void dispose() {
    _packageInfoNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Center(
              child: Text(
                shared.AppConfig.appName,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: PrimaryScrollController(
              controller: ScrollController(),
              child: Scrollbar(
                interactive: true,
                child: ListView(
                key: const PageStorageKey<String>('drawer_list_scroll_key'),
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.zero,
                children: <Widget>[
                  _buildDrawerItem(
                    context,
                    icon: Icons.home,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerHomeLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Home',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.homeRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.homeRoute,
                      )) {
                        context.go(core.AppRoutePath.homeRoute);
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.table_restaurant,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerTableInfoLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Table Info',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.tableInfoScreenRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.tableInfoScreenRoute,
                      )) {
                        context.push(core.AppRoutePath.tableInfoScreenRoute);
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.category,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerCategoriesLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Menu Categories',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.menuCategoryFullListRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.menuCategoryFullListRoute,
                      )) {
                        context.push(
                          core.AppRoutePath.menuCategoryFullListRoute,
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.category,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerMenuSubCategoryLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Menu Sub-Categories',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.menuSubCategoryFullListRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.menuSubCategoryFullListRoute,
                      )) {
                        context.push(
                          core.AppRoutePath.menuSubCategoryFullListRoute,
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.restaurant_menu,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerMenuItemLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Menu Items',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.menuItemFullListScreenRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.menuItemFullListScreenRoute,
                      )) {
                        context.push(
                          core.AppRoutePath.menuItemFullListScreenRoute,
                        );
                      }
                    },
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerInventoryLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Inventory',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.inventoryListScreenRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.inventoryListScreenRoute,
                      )) {
                        context.push(
                          core.AppRoutePath.inventoryListScreenRoute,
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.shopping_cart_checkout,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerPurchasesLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Purchases',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.purchaseListScreenRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.purchaseListScreenRoute,
                      )) {
                        context.push(core.AppRoutePath.purchaseListScreenRoute);
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.calendar_today,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerReservationsLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Reservations',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.reservationListScreenRoute,
                    ),
                    onTap: () => HomeScreenDrawerActions.showComingSoon(
                      context,
                      'Reservations Screen Coming Soon!',
                    ),
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.sort,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerOrderListLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Order List',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.orderListScreenRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.orderListScreenRoute,
                      )) {
                        context.push(core.AppRoutePath.orderListScreenRoute);
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.sort,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerInvoicesLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Invoices',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.invoiceListScreenRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.invoiceListScreenRoute,
                      )) {
                        context.push(core.AppRoutePath.invoiceListScreenRoute);
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.menu_book,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerSalesLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Sales',
                    isSelected: _isRouteActive(currentLocation, '/sales'),
                    onTap: () => HomeScreenDrawerActions.showComingSoon(
                      context,
                      'Sales Screen Coming Soon!',
                    ),
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.menu_book,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerRecipesLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Recipes',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.recipesListScreenRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.recipesListScreenRoute,
                      )) {
                        context.push(core.AppRoutePath.recipesListScreenRoute);
                      }
                    },
                  ),

                  _buildDrawerItem(
                    context,
                    icon: Icons.people,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerStaffLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Staff',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.staffManagementScreenRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.staffManagementScreenRoute,
                      )) {
                        context.push(
                          core.AppRoutePath.staffManagementScreenRoute,
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_outline,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerCustomersLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Customers',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.customerListScreenRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.customerListScreenRoute,
                      )) {
                        context.push(
                          core.AppRoutePath.customerListScreenRoute,
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerSettingsLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'Settings',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.settingsScreenRoute,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if (!_isRouteActive(
                        currentLocation,
                        core.AppRoutePath.settingsScreenRoute,
                      )) {
                        context.push(core.AppRoutePath.settingsScreenRoute);
                      }
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.workspace_premium,
                    title:
                        context.tr(
                          shared.LocaleKeys.homeDrawerLicenseLabel,
                          track: shared.TrackConstants.homePageTrack,
                        ) ??
                        'License',
                    isSelected: _isRouteActive(
                      currentLocation,
                      core.AppRoutePath.licenseRoute,
                    ),
                    onTap: () => HomeScreenDrawerActions.onLicenseTap(context),
                  ),
                ],
              ),
            ),
          ),
          ),

          Divider(color: Colors.grey.shade300, thickness: 1),
          ValueListenableBuilder<PackageInfo>(
                valueListenable: _packageInfoNotifier,
                builder: (context, packageInfo, _) {
                  return Text(
                    'Version ${packageInfo.version}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                },
              )
              .inExpandedRow(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
              )
              .paddingSymmetric(vertical: 15),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.25,
      ),
      leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          decoration: TextDecoration.none,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      onTap: onTap,
    );
  }

  bool _isRouteActive(String currentLocation, String targetRoute) {
    if (targetRoute == core.AppRoutePath.homeRoute) {
      return currentLocation == core.AppRoutePath.homeRoute;
    }
    return currentLocation == targetRoute ||
        currentLocation.startsWith('$targetRoute/');
  }
}
