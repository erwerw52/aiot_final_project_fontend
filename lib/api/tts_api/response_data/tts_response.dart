import 'package:json_annotation/json_annotation.dart';

part 'tts_response.g.dart';

@JsonSerializable()
class TtsResponse {
  final String audioData;
  final List<TimeLineDto> timeLines;
  final String originalText;
  final String url;

  TtsResponse({
    required this.audioData,
    required this.timeLines,
    required this.originalText,
    required this.url,
  });

  factory TtsResponse.fromJson(Map<String, dynamic> json) =>
      _$TtsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TtsResponseToJson(this);
}

@JsonSerializable()
class TimeLineDto {
  final String text;
  final double start;
  final double end;

  TimeLineDto({required this.text, required this.start, required this.end});

  factory TimeLineDto.fromJson(Map<String, dynamic> json) =>
      _$TimeLineDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TimeLineDtoToJson(this);
}
