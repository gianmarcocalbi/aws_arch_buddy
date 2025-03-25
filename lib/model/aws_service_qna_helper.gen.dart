import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'model.dart';

part 'aws_service_qna_helper.gen.g.dart';

@JsonSerializable()
class AwsServiceQnaHelper extends Equatable {
  final AwsService service;
  final bool isEnabled;
  @JsonKey(defaultValue: false)
  final bool isFlagged;
  final AwsServiceAnswerStats stats;
  final AwsServiceAnswerStats reverseStats;

  const AwsServiceQnaHelper({
    required this.service,
    required this.isEnabled,
    required this.isFlagged,
    required this.stats,
    required this.reverseStats,
  });

  AwsServiceQnaHelper copyWith({
    bool? isEnabled,
    bool? isFlagged,
    AwsServiceAnswerStats? stats,
    AwsServiceAnswerStats? reverseStats,
  }) {
    return AwsServiceQnaHelper(
      service: service,
      isFlagged: isFlagged ?? this.isFlagged,
      isEnabled: isEnabled ?? this.isEnabled,
      stats: stats ?? this.stats,
      reverseStats: reverseStats ?? this.reverseStats,
    );
  }

  factory AwsServiceQnaHelper.fromJson(Map<String, dynamic> json) =>
      _$AwsServiceQnaHelperFromJson(json);

  Map<String, dynamic> toJson() => _$AwsServiceQnaHelperToJson(this);

  @override
  List<Object?> get props => [
        service,
        isEnabled,
        isFlagged,
        stats,
        reverseStats,
      ];
}
