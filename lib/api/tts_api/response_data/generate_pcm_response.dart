import 'package:json_annotation/json_annotation.dart';

part 'generate_pcm_response.g.dart';

@JsonSerializable()
class GeneratePcmResponse {
  String id;
  String status;

  GeneratePcmResponse({required this.id, required this.status});

  factory GeneratePcmResponse.fromJson(Map<String, dynamic> json) =>
      _$GeneratePcmResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratePcmResponseToJson(this);
}
