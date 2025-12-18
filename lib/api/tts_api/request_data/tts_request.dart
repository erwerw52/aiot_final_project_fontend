import 'package:json_annotation/json_annotation.dart';

part 'tts_request.g.dart';

@JsonSerializable()
class TtsRequest {
  String text;
  VoiceType voice;

  TtsRequest({required this.text, required this.voice});

  factory TtsRequest.fromJson(Map<String, dynamic> json) =>
      _$TtsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TtsRequestToJson(this);
}

enum VoiceType {
  @JsonValue(0)
  female(0),
  @JsonValue(1)
  male(1);

  final int value;
  
  const VoiceType(this.value);
}
