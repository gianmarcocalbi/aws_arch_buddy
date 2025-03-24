import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'aws_service_answer_stats.gen.g.dart';

@JsonSerializable()
class AwsServiceAnswerStats extends Equatable {
  final int questionCount;
  final int correctCount;

  const AwsServiceAnswerStats({
    required this.questionCount,
    required this.correctCount,
  });

  const AwsServiceAnswerStats.zero()
      : questionCount = 0,
        correctCount = 0;

  AwsServiceAnswerStats copyWith({
    int? questionCount,
    int? correctCount,
  }) {
    return AwsServiceAnswerStats(
      questionCount: questionCount ?? this.questionCount,
      correctCount: correctCount ?? this.correctCount,
    );
  }

  @override
  List<Object?> get props => [questionCount, correctCount];

  factory AwsServiceAnswerStats.fromJson(Map<String, dynamic> json) =>
      _$AwsServiceAnswerStatsFromJson(json);

  Map<String, dynamic> toJson() => _$AwsServiceAnswerStatsToJson(this);
}
