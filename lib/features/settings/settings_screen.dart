import 'package:flutter/material.dart';

import '../../data/data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(
          title: Text('Settings'),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              ListTile(
                title: const Text('Reset statistics'),
                subtitle: const Text(
                  'Reset the statistics for all services (correct, wrong, '
                  'total, etc.)',
                ),
                subtitleTextStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                trailing: const Icon(Icons.restart_alt),
                onTap: ServiceRepository.I.resetStats,
              ),
              ListTile(
                title: const Text('Clear all data'),
                subtitle: const Text(
                  'Clear all data from the storage. The data will be rebuilt '
                  'on the next launch.',
                ),
                subtitleTextStyle: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                trailing: const Icon(Icons.delete),
                onTap: ServiceRepository.I.forceClearBox,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
