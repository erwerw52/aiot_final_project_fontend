class TtsResponse {
  final List<int> audioData;
  final String contentType;

  TtsResponse({required this.audioData, required this.contentType});
}