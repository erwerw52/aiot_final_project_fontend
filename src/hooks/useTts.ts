import { useCallback } from 'react';
// @ts-ignore
import { franc } from 'franc';
import TtsQuestV3Voicevox from '../utils/TtsQuestV3Voicevox.js';

interface UseTtsProps {
    onSpeak: (speaking: boolean) => void;
    onCharIndex?: (index: number) => void;
    onTextUpdate?: (text: string) => void;
}

const detectLanguage = (text: string): string => {
    const lang = franc(text);
    console.log('Language detected:', text, '->', lang);
    return lang;
};

export const useTts = ({ onSpeak, onCharIndex, onTextUpdate }: UseTtsProps) => {

    const speakWithSpeechSynthesis = useCallback((text: string, lang?: string) => {
        console.log('speakWithSpeechSynthesis called with text:', text, 'lang:', lang);
        const utterance = new SpeechSynthesisUtterance(text);

        utterance.onboundary = (event) => {
            console.log('SpeechSynthesis onboundary:', event.name);
            if (event.name === 'word') {
                onSpeak(true);
                // 模擬說話時間，然後閉合
                setTimeout(() => onSpeak(false), 200);
                if (onTextUpdate) {
                    const updatedText = text.substring(0, event.charIndex + event.charLength);
                    onTextUpdate(updatedText);
                }
            }
            if (onCharIndex) {
                onCharIndex(event.charIndex);
            }
        };

        utterance.onstart = () => {
            console.log('SpeechSynthesis started');
            onSpeak(true);
        };

        utterance.onend = () => {
            console.log('SpeechSynthesis ended');
            onSpeak(false);
        };

        utterance.onerror = (event) => {
            console.error('SpeechSynthesis error:', event);
        };

        console.log('Calling window.speechSynthesis.speak');
        window.speechSynthesis.speak(utterance);
    }, [onSpeak, onCharIndex, onTextUpdate]);

    const speakWithVoicevoxApi = useCallback(async (text: string) => {
        console.log('speakWithVoicevoxApi called with text:', text);
        try {
            console.log('Using TtsQuestV3Voicevox...');
            const audio = new TtsQuestV3Voicevox(20, text, undefined); // speakerId=20, no API key

            audio.onloadedmetadata = () => {
                console.log('Audio loaded metadata');
                audio.onplay = () => {
                    console.log('Audio started playing');
                    onSpeak(true);
                    // 確保最後顯示完整文字
                    if (onTextUpdate) {
                        onTextUpdate(text);
                    }
                    audio.onended = () => {
                        console.log('Audio ended');
                        onSpeak(false);
                    };
                };
            };

            audio.onerror = (event) => {
                console.error('Audio error:', event);
                // 回退到 SpeechSynthesis
                speakWithSpeechSynthesis(text);
            };

            audio.oncanplay = () => {
                console.log('Audio can play');
                audio.play().catch(error => {
                    console.error('Play error:', error);
                    // 回退到 SpeechSynthesis
                    speakWithSpeechSynthesis(text);
                });
            };
        } catch (error) {
            console.error('TtsQuestV3Voicevox error:', error);
            // 回退到 SpeechSynthesis
            speakWithSpeechSynthesis(text);
        }
    }, [onSpeak, onTextUpdate, speakWithSpeechSynthesis]);

    const speak = useCallback((text: string) => {
        console.log('speak called with text:', text);
        const lang = detectLanguage(text);
        if (lang === 'jpn') {
            console.log('Using API for Japanese text');
            speakWithVoicevoxApi(text);
        } else {
            console.log('Using SpeechSynthesis for detected language:', lang);
            speakWithSpeechSynthesis(text);
        }
    }, [speakWithVoicevoxApi, speakWithSpeechSynthesis]);

    return { speak };
};