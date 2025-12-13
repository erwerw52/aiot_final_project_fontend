// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TtsRequest _$TtsRequestFromJson(Map<String, dynamic> json) =>
    TtsRequest(text: json['text'] as String, voice: json['voice'] as String?);

Map<String, dynamic> _$TtsRequestToJson(TtsRequest instance) =>
    <String, dynamic>{'text': instance.text, 'voice': instance.voice};
