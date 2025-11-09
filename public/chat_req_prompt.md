# chat_req_prompt.md

User input text: "{text}"

**Task:**
Analyze the provided user input text and extract the following information. Do NOT generate any new response text or conversation. Only analyze the given input. The text may be in any language (Chinese, English, Japanese, Spanish, etc.), so adapt your analysis accordingly.

1. **Language Detection**: Identify the primary language of the text (e.g., Chinese, English, Japanese, Spanish, etc.).
2. **Emotion Analysis**: Determine the dominant emotion expressed in the text from these options: happy, sad, angry, relaxed, surprised, neutral.
3. **Text Transcription**: Break down the text into individual words/units (including punctuation). For each word/unit, provide:
   - The exact text of the word/unit.
   - The starting character index in the original "{text}".
   - A sequence of simplified visemes representing the mouth shapes needed to pronounce it in the detected language.

**Important Notes:**
- Focus only on the input text analysis - do not create new content.
- Visemes should be based on phonetic mouth shapes, not durations.
- Adapt to the detected language: For Chinese, treat each character as a unit; for English, break into words or syllables; for Japanese, consider hiragana/katakana units.
- Punctuation, spaces, and silent sounds should use "neutral" viseme.
- Ensure visemes are phonetically appropriate for the language.

**Response Format:**
Respond strictly in JSON format with no additional text:
{
  "language": "Detected language (e.g., Chinese, English, Japanese)",
  "emotion": "one of: happy, sad, angry, relaxed, surprised, neutral",
  "words_visemes": [
    {
      "text": "word or unit",  // Exact text from input
      "charIndex": 0,          // Starting index in original text
      "visemes": ["aa", "ih"]  // Sequence of visemes for this unit
    },
    // ... more units covering the entire input text
  ]
}

**Viseme Rules (Simplified Mouth Shapes - Universal for All Languages):**
- **aa**: Large open mouth (e.g., 'ah' sound, ㄚ in Chinese, 'a' in English).
- **ih**: Narrow, horizontally stretched mouth (e.g., 'ee' or 'ih' sound, ㄧ in Chinese, 'i' in English).
- **ou**: Tightly rounded lips (e.g., 'oo' or 'u' sound, ㄨ in Chinese, 'oo' in English).
- **ee**: Medium open mouth, slightly stretched (e.g., 'eh' or 'e' sound, ㄜ in Chinese, 'e' in English).
- **oh**: Moderately rounded, open mouth (e.g., 'o' or 'aw' sound, ㄛ in Chinese, 'o' in English).
- **neutral**: For punctuation, pauses, silent sounds, or closed-mouth sounds (e.g., m, n, punctuation in any language).

**Examples:**

**Chinese Input "我很高興":**
{
  "language": "Chinese",
  "emotion": "happy",
  "words_visemes": [
    {"text": "我", "charIndex": 0, "visemes": ["ou"]},
    {"text": "很", "charIndex": 1, "visemes": ["ee"]},
    {"text": "高", "charIndex": 2, "visemes": ["ou"]},
    {"text": "興", "charIndex": 3, "visemes": ["ih"]}
  ]
}

**English Input "I am happy":**
{
  "language": "English",
  "emotion": "happy",
  "words_visemes": [
    {"text": "I", "charIndex": 0, "visemes": ["ih"]},
    {"text": " ", "charIndex": 1, "visemes": ["neutral"]},
    {"text": "am", "charIndex": 2, "visemes": ["aa", "ee"]},
    {"text": " ", "charIndex": 4, "visemes": ["neutral"]},
    {"text": "happy", "charIndex": 6, "visemes": ["ee", "ih"]}
  ]
}

**Japanese Input "こんにちは":**
{
  "language": "Japanese",
  "emotion": "neutral",
  "words_visemes": [
    {"text": "こ", "charIndex": 0, "visemes": ["oh"]},
    {"text": "ん", "charIndex": 1, "visemes": ["neutral"]},
    {"text": "に", "charIndex": 2, "visemes": ["ih"]},
    {"text": "ち", "charIndex": 3, "visemes": ["ih"]},
    {"text": "は", "charIndex": 4, "visemes": ["aa"]}
  ]
}

**Constraint:**
Only output valid JSON, nothing else. Ensure the words_visemes array covers the entire input text sequentially, adapting to the detected language's phonetic structure.