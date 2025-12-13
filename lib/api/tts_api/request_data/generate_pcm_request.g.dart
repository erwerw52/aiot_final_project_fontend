// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_pcm_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratePcmRequest _$GeneratePcmRequestFromJson(Map<String, dynamic> json) =>
    GeneratePcmRequest(
      text: json['text'] as String,
      voice: json['voice'] as String,
    );

Map<String, dynamic> _$GeneratePcmRequestToJson(GeneratePcmRequest instance) =>
    <String, dynamic>{'text': instance.text, 'voice': instance.voice};
