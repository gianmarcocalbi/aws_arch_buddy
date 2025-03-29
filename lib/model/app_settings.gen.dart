import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_settings.gen.g.dart';

@JsonSerializable()
class AppSettings extends Equatable {
  final int serviceVersion;

  const AppSettings({
    required this.serviceVersion,
  });

  const AppSettings.initial() : serviceVersion = 0;

  AppSettings copyWith({
    int? serviceVersion,
  }) {
    return AppSettings(
      serviceVersion: serviceVersion ?? this.serviceVersion,
    );
  }

  @override
  List<Object?> get props => [
        serviceVersion,
      ];

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);
}
