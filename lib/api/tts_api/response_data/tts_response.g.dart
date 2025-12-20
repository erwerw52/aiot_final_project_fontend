// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TtsResponse _$TtsResponseFromJson(Map<String, dynamic> json) => TtsResponse(
  audioData: json['audioData'] as String,
  timeLines: (json['timeLines'] as List<dynamic>)
      .map((e) => TimeLineDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  originalText: json['originalText'] as String,
  url: json['url'] as String,
);

Map<String, dynamic> _$TtsResponseToJson(TtsResponse instance) =>
    <String, dynamic>{
      'audioData': instance.audioData,
      'timeLines': instance.timeLines,
      'originalText': instance.originalText,
      'url': instance.url,
    };

TimeLineDto _$TimeLineDtoFromJson(Map<String, dynamic> json) => TimeLineDto(
  text: json['text'] as String,
  start: (json['start'] as num).toDouble(),
  end: (json['end'] as num).toDouble(),
);

Map<String, dynamic> _$TimeLineDtoToJson(TimeLineDto instance) =>
    <String, dynamic>{
      'text': instance.text,
      'start': instance.start,
      'end': instance.end,
    };
