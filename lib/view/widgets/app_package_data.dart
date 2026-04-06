import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppPackageData extends StatefulWidget {
  const AppPackageData({super.key});

  @override
  State<AppPackageData> createState() => _AppPackageDataState();
}

class _AppPackageDataState extends State<AppPackageData> {
  String? appVersion;
  String? buildNumber;

  Future<void> loadData() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (appVersion == null || buildNumber == null) return SizedBox.shrink();
    return Text(
      'v$appVersion+$buildNumber',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
