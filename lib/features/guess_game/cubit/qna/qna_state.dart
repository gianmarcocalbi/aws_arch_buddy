part of 'qna_cubit.dart';

class QnaState extends Equatable {
  final AwsServiceQnaHelper helper;
  final bool isReversed;
  final Map<AwsService, double> serviceWeights;
  final double totalWeight;

  QnaState({
    required this.helper,
    required this.serviceWeights,
    required this.isReversed,
  }) : totalWeight = serviceWeights.values.reduce((a, b) => a + b);

  AwsService getRandomService() {
    var randomValue = _rnd.nextDouble() * totalWeight;
    return serviceWeights.entries
        .firstWhere((entry) => (randomValue -= entry.value) <= 0)
        .key;
  }

  double getServiceWeight(AwsService service) {
    return serviceWeights[service]!;
  }

  @override
  List<Object> get props => [
        totalWeight,
        serviceWeights,
        helper,
        isReversed,
      ];

  QnaState copyWith({
    bool? isReversed,
    AwsServiceQnaHelper? helper,
    Map<AwsService, double>? serviceWeights,
  }) {
    return QnaState(
      isReversed: isReversed ?? this.isReversed,
      helper: helper ?? this.helper,
      serviceWeights: serviceWeights ?? this.serviceWeights,
    );
  }
}
