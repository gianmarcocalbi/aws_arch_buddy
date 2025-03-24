import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../data/service_repository.dart';
import '../../../../model/model.dart';

part 'qna_state.dart';

final _rnd = Random();

class QnaCubit extends Cubit<QnaState> {
  final QnaGameType gameType;
  final ServiceRepository serviceRepository;

  QnaCubit({
    required this.serviceRepository,
    required this.gameType,
  }) : super(
          QnaState(
            helper: serviceRepository.getRandom(),
            isReversed: getNextIsReversed(gameType),
            serviceWeights: Map.fromEntries(
              serviceRepository.enabledItems.map(
                (helper) => MapEntry(helper.service, 1.0),
              ),
            ),
          ),
        );

  static bool getNextIsReversed(QnaGameType gameType) => switch (gameType) {
        QnaGameType.tellServiceGoal => false,
        QnaGameType.guessServiceName => true,
        QnaGameType.shuffled => _rnd.nextBool(),
      };

  AwsService question() {
    final service = state.getRandomService();
    emit(
      state.copyWith(
        helper: serviceRepository.getByService(service),
        serviceWeights: {
          ...state.serviceWeights,
          service:
              state.getServiceWeight(service) / state.serviceWeights.length,
        },
        isReversed: getNextIsReversed(gameType),
      ),
    );
    return service;
  }

  Future<void> answer({required bool isCorrect}) async {
    await serviceRepository.answer(
      service: state.helper.service,
      isReversed: state.isReversed,
      isCorrect: isCorrect,
    );
    emit(
      state.copyWith(
        helper: serviceRepository.getOrThrow(state.helper.service.name),
      ),
    );
  }

  Future<void> enableService() async {
    await serviceRepository.enable(state.helper.service);
    emit(
      state.copyWith(
        helper: serviceRepository.getOrThrow(state.helper.service.name),
      ),
    );
  }

  Future<void> disableService() async {
    await serviceRepository.disable(state.helper.service);
    emit(
      state.copyWith(
        helper: serviceRepository.getOrThrow(state.helper.service.name),
      ),
    );
  }
}
