import 'package:flutter/material.dart';

import '../../data/data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(
          title: Text('Service Guess'),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              ListTile(
                title: const Text('Reset statistics'),
                trailing: const Icon(Icons.restart_alt),
                onTap: ServiceRepository.I.resetStats,
              ),
              ListTile(
                title: const Text('Clear all data'),
                subtitle: const Text('Clear all data from the storage'),
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
