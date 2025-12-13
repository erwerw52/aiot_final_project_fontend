import 'package:json_annotation/json_annotation.dart';

part 'generate_pcm_request.g.dart';

@JsonSerializable()
class GeneratePcmRequest {
  String text;
  String voice;

  GeneratePcmRequest({required this.text, required this.voice});

  factory GeneratePcmRequest.fromJson(Map<String, dynamic> json) =>
      _$GeneratePcmRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratePcmRequestToJson(this);
}
