import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/shared/gen/assets.gen.dart'
    as assets_gen;

import 'developer_actions.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  late final ValueNotifier<PackageInfo?> _packageInfoNotifier;

  @override
  void initState() {
    super.initState();
    _packageInfoNotifier = ValueNotifier<PackageInfo?>(null);
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    _packageInfoNotifier.value = info;
  }

  @override
  void dispose() {
    _packageInfoNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = shared.ResponsiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr(
                shared.LocaleKeys.settingsDeveloperTitle,
                track: shared.TrackConstants.settingTrack,
              ) ??
              'Developer & Contributors',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 900 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            children: [
              // Header App Info Card
              _buildAppHeroCard(context),
              const SizedBox(height: 20),

              // Lead Developer Spotlight Card
              _buildSectionHeader(
                context,
                title:
                    context.tr(
                      shared.LocaleKeys.settingsDeveloperLeadTitle,
                      track: shared.TrackConstants.settingTrack,
                    ) ??
                    'Project Author & Lead',
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 10),
              _buildLeadDeveloperCard(context),
              const SizedBox(height: 24),

              // GitHub & Community Section
              _buildSectionHeader(
                context,
                title:
                    context.tr(
                      shared.LocaleKeys.settingsDeveloperCommunitySection,
                      track: shared.TrackConstants.settingTrack,
                    ) ??
                    'Community & Open-Source',
                icon: Icons.public_rounded,
              ),
              const SizedBox(height: 10),
              _buildCommunityCard(context),
              const SizedBox(height: 24),

              // Core Frameworks & Libraries
              _buildSectionHeader(
                context,
                title:
                    context.tr(
                      shared.LocaleKeys.settingsDeveloperPackagesTitle,
                      track: shared.TrackConstants.settingTrack,
                    ) ??
                    'Core Packages & Architecture',
                icon: Icons.hub_outlined,
              ),
              const SizedBox(height: 10),
              _buildLibrariesCard(context),
              const SizedBox(height: 24),

              // Licenses & Legal
              Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.workspace_premium_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    context.tr(
                          shared.LocaleKeys.settingsDeveloperLicensesBtn,
                          track: shared.TrackConstants.settingTrack,
                        ) ??
                        'Open Source Licenses',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'View all open source dependencies and third-party software notices',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () => DeveloperActions.showAppLicenses(context),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 46,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Image.asset(
                assets_gen.Assets.images.appLogoClearBg.path,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Coozy The Cafe',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            ValueListenableBuilder<PackageInfo?>(
              valueListenable: _packageInfoNotifier,
              builder: (context, packageInfo, _) {
                final version = packageInfo?.version ?? '1.0.0';
                final buildNumber = packageInfo?.buildNumber ?? '1';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Version $version ($buildNumber)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              context.tr(
                    shared.LocaleKeys.settingsDeveloperAboutAppDesc,
                    track: shared.TrackConstants.settingTrack,
                  ) ??
                  'A comprehensive open-source Cafe, Restaurant, & POS Management system crafted with Flutter, Drift (SQLite), and Clean Architecture.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadDeveloperCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.code_rounded,
                    size: 32,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                              shared.LocaleKeys.settingsDeveloperLeadName,
                              track: shared.TrackConstants.settingTrack,
                            ) ??
                            'Yazad H. Dumasia',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr(
                              shared.LocaleKeys.settingsDeveloperLeadRole,
                              track: shared.TrackConstants.settingTrack,
                            ) ??
                            'Senior Flutter Developer',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.tr(
                    shared.LocaleKeys.settingsDeveloperLeadBio,
                    track: shared.TrackConstants.settingTrack,
                  ) ??
                  'Passionate Flutter & Cross-Platform Software Engineer building modern, production-grade applications with Flutter & Dart.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => DeveloperActions.openUrl(
                    context,
                    'https://github.com/YazadDumasia',
                  ),
                  icon: const Icon(Icons.code_rounded, size: 16),
                  label: const Text('GitHub Profile'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => DeveloperActions.openUrl(
                    context,
                    'https://www.linkedin.com/in/yazad-dumasia-005438105/',
                  ),
                  icon: const Icon(Icons.business_center_outlined, size: 16),
                  label: const Text('LinkedIn'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.star_rounded, color: colorScheme.secondary),
              ),
              title: const Text(
                'GitHub Repository',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Star, fork, and track issues or pull requests on GitHub',
              ),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => DeveloperActions.openUrl(
                  context,
                  'https://github.com/YazadDumasia/coozy_the_cafe',
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Visit Repo'),
              ),
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bug_report_outlined,
                  color: colorScheme.tertiary,
                ),
              ),
              title: const Text(
                'Report Issues & Feedback',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Submit bug reports or suggest new feature ideas on the issue tracker',
              ),
              trailing: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => DeveloperActions.openUrl(
                  context,
                  'https://github.com/YazadDumasia/coozy_the_cafe/issues',
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 14),
                label: const Text('Issues'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibrariesCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final chips = [
      {'name': 'Flutter 3.x', 'desc': 'Cross-Platform UI'},
      {'name': 'Drift & SQLite', 'desc': 'Offline Database'},
      {'name': 'Bloc / Cubit', 'desc': 'State Management'},
      {'name': 'GoRouter', 'desc': 'Declarative Routing'},
      {'name': 'GetIt', 'desc': 'Dependency Injection'},
      {'name': 'Printing & ESC/POS', 'desc': 'Receipt & PDF Engine'},
      {'name': 'Clean Architecture', 'desc': 'Modular Structure'},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr(
                    shared.LocaleKeys.settingsDeveloperContributorsSubtitle,
                    track: shared.TrackConstants.settingTrack,
                  ) ??
                  'Special thanks to all open-source libraries, packages, and contributors powering Coozy The Cafe',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.map((item) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: colorScheme.primary.withValues(
                      alpha: 0.15,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: colorScheme.primary,
                    ),
                  ),
                  label: Text('${item['name']} • ${item['desc']}'),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
