import 'package:a2f_sdk/a2f_sdk.dart';
import 'package:flext_core/flext_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/data.dart';
import '../../model/model.dart';
import '../../widgets/widgets.dart';
import 'cubit/cubit.dart';

class ServiceGuessGame extends StatefulWidget {
  const ServiceGuessGame({super.key});

  static Future<void> push({
    required QnaGameType gameType,
    required BuildContext context,
  }) async {
    await context.navRoot.push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BlocProvider(
          create: (_) => QnaCubit(
            serviceRepository: ServiceRepository.I,
            gameType: gameType,
          )..question(),
          child: const ServiceGuessGame(),
        ),
      ),
    );
  }

  @override
  State<ServiceGuessGame> createState() => _ServiceGuessGameState();
}

class _ServiceGuessGameState extends State<ServiceGuessGame> {
  bool isRevealed = false;

  void _onAnswer(BuildContext context, {required bool isCorrect}) {
    final cubit = context.read<QnaCubit>();
    setState(() => isRevealed = false);
    cubit
      ..answer(isCorrect: isCorrect)
      ..question();
    SnackBarHelper.I.showInfo(context: context, message: 'Answer submitted');
  }

  List<Widget> _buildQaWidgets(BuildContext context, QnaState state) {
    return [
      $style.insets.md.asVSpan.asSliver,
      Text(
        (state.isReversed
            ? state.helper.service.description
            : state.helper.service.name),
        textAlign: TextAlign.center,
        style: context.tt.bodyLarge?.copyWith(
          fontStyle: FontStyle.italic,
          color: context.col.primary,
          fontWeight: FontWeight.bold,
        ),
      ).asSliver,
      $style.insets.sm.asVSpan.asSliver,
      Text(
        state.isReversed
            ? 'Can you guess the service/feature name?'
            : 'Can you guess what does this service or feature is?',
        textAlign: TextAlign.center,
        style: context.tt.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ).asSliver,
      if (isRevealed) ...[
        $style.insets.lg.asVSpan.asSliver,
        Text(
          (state.isReversed
              ? state.helper.service.name
              : state.helper.service.description),
          textAlign: TextAlign.center,
          style: context.tt.bodyLarge?.copyWith(
            color: context.col.primary,
            fontWeight: FontWeight.w500,
            fontFamily: 'Noto Sans',
          ),
        ).asSliver,
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<QnaCubit, QnaState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(
                  'Game - ' + context.read<QnaCubit>().gameType.title,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.flag),
                    color: state.helper.isFlagged ? Colors.pink : null,
                    onPressed: () {
                      final newValue = !state.helper.isFlagged;
                      context.read<QnaCubit>().flagService(isFlagged: newValue);
                      SnackBarHelper.I.showInfo(
                        context: context,
                        message:
                            newValue ? 'Service flagged' : 'Service unflagged',
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      final isEnabled = state.helper.isEnabled;
                      if (state.helper.isEnabled) {
                        context.read<QnaCubit>().disableService();
                      } else {
                        context.read<QnaCubit>().enableService();
                      }
                      SnackBarHelper.I.showInfo(
                        context: context,
                        message: isEnabled
                            ? 'Service hidden'
                            : 'Service is now visible',
                      );
                    },
                    color: state.helper.isEnabled ? Colors.green : Colors.pink,
                    icon: Icon(
                      state.helper.isEnabled
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: $style.insets.screenH.asPaddingH,
                sliver: SliverMainAxisGroup(
                  slivers: [
                    ..._buildQaWidgets(context, state),
                    $style.insets.lg.asVSpan.asSliver,
                    if (!isRevealed) ...[
                      ElevatedButton.icon(
                        onPressed: () => setState(() => isRevealed = true),
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('Reveal answer'),
                      ).asSliver,
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                _onAnswer(context, isCorrect: false);
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Incorrect'),
                              style: TextButton.styleFrom(
                                iconColor: Colors.white,
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.pink,
                              ),
                            ),
                          ),
                          $style.insets.sm.asHSpan,
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                _onAnswer(context, isCorrect: true);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Correct'),
                              style: TextButton.styleFrom(
                                iconColor: Colors.white,
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ).asSliver,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
