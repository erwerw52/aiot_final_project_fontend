// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TtsRequest _$TtsRequestFromJson(Map<String, dynamic> json) => TtsRequest(
  text: json['text'] as String,
  voice: $enumDecode(_$VoiceTypeEnumMap, json['voice']),
);

Map<String, dynamic> _$TtsRequestToJson(TtsRequest instance) =>
    <String, dynamic>{
      'text': instance.text,
      'voice': _$VoiceTypeEnumMap[instance.voice]!,
    };

const _$VoiceTypeEnumMap = {VoiceType.female: 0, VoiceType.male: 1};
