import 'package:json_annotation/json_annotation.dart';

part 'tts_request.g.dart';

@JsonSerializable()
class TtsRequest {
  String text;
  String? voice;

  TtsRequest({required this.text, this.voice});

  factory TtsRequest.fromJson(Map<String, dynamic> json) =>
      _$TtsRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$TtsRequestToJson(this);
    json.removeWhere((key, value) => value == null);
    return json;
  }
}