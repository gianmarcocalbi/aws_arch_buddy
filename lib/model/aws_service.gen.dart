import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'aws_service.gen.g.dart';

@JsonSerializable()
class AwsService extends Equatable {
  final String name;
  final String description;

  const AwsService({required this.name, required this.description});

  @override
  List<Object?> get props => [name, description];

  factory AwsService.fromJson(Map<String, dynamic> json) =>
      _$AwsServiceFromJson(json);

  Map<String, dynamic> toJson() => _$AwsServiceToJson(this);
}
