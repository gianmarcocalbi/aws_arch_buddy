import 'package:a2f_sdk/a2f_sdk.dart';
import 'package:flutter/material.dart';

import '../../model/model.dart';
import '../guess_game/guess_game.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(
          title: Text('Welcome!'),
        ),
        SliverPadding(
          padding: $style.insets.screenH.asPaddingH,
          sliver: SliverMainAxisGroup(
            slivers: [
              ElevatedButton.icon(
                onPressed: () => ServiceGuessGame.push(
                  gameType: QnaGameType.tellServiceGoal,
                  context: context,
                ),
                icon: const Icon(Icons.question_answer),
                label: const Text('Guess service goal'),
              ).asSliver,
              $style.insets.sm.asVSpan.asSliver,
              ElevatedButton.icon(
                onPressed: () => ServiceGuessGame.push(
                  gameType: QnaGameType.guessServiceName,
                  context: context,
                ),
                icon: const Icon(Icons.question_answer),
                label: const Text('Guess service name'),
              ).asSliver,
              $style.insets.sm.asVSpan.asSliver,
              ElevatedButton.icon(
                onPressed: () => ServiceGuessGame.push(
                  gameType: QnaGameType.shuffled,
                  context: context,
                ),
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffled'),
              ).asSliver,
            ],
          ),
        ),
      ],
    );
  }
}
