import React, { useState } from 'react';
import { Input, Button, List } from 'antd';
import { Ollama } from 'ollama/browser';

interface Message {
    text: string;
    sender: 'user' | 'bot';
}

interface ChatRoomProps {
    onSpeak: (speaking: boolean) => void;
    onExpression: (expression: string) => void;
    onText: (text: string) => void;
    onCharIndex: (index: number) => void;
    onPhonemes: (phonemes: Array<{text: string, charIndex: number, visemes: string[]}>) => void;
}

const ChatRoom: React.FC<ChatRoomProps> = ({ onSpeak, onExpression, onText, onCharIndex, onPhonemes }) => {
    const [messages, setMessages] = useState<Message[]>([]);
    const [input, setInput] = useState('');
    const ollama = new Ollama({ host: 'http://localhost:11434' });

    const sendMessage = async (text: string) => {
        setMessages(prev => [...prev, { text, sender: 'user' }]);
        
        try {
            // 顯示 thinking... 訊息
            setMessages(prev => [...prev, { text: 'thinking...', sender: 'bot' }]);
            
            // 讀取 prompt 文件
            const promptResponse = await fetch('/chat_req_prompt.md');
            const promptTemplate = await promptResponse.text();
            
            // 替換 {text} 佔位符
            const fullPrompt = promptTemplate.replace('{text}', text);
            
            // 呼叫 Ollama 一次
            const result = await ollama.generate({
                model: 'gpt-oss:20b-cloud',
                prompt: fullPrompt,
                stream: false
            });
            
        console.log('Ollama response:', result.response);
        
        // 解析 JSON 回應 - 處理可能的格式問題
        let data;
        try {
            // 嘗試直接解析
            data = JSON.parse(result.response);
        } catch (parseError) {
            console.warn('直接解析失敗，嘗試清理 JSON:', parseError);
            try {
                // 嘗試提取 JSON 部分
                const jsonMatch = result.response.match(/\{[\s\S]*\}/);
                if (jsonMatch) {
                    // 清理可能的格式問題
                    let jsonString = jsonMatch[0];
                    // 將單引號替換為雙引號（如果有的話）
                    jsonString = jsonString.replace(/'([^']*)'/g, '"$1"');
                    // 移除可能的尾隨逗號
                    jsonString = jsonString.replace(/,(\s*[}\]])/g, '$1');
                    
                    data = JSON.parse(jsonString);
                    console.log('成功解析清理後的 JSON');
                } else {
                    throw new Error('找不到有效的 JSON 結構');
                }
            } catch (cleanupError) {
                console.error('JSON 解析失敗:', cleanupError);
                // 使用預設值
                data = {
                    language: 'unknown',
                    emotion: 'neutral',
                    words_visemes: []
                };
            }
        }
        
        console.log('解析後的資料:', data);
        
        // 驗證 words_visemes 格式
        if (data.words_visemes && Array.isArray(data.words_visemes)) {
            console.log('words_visemes 驗證通過，長度:', data.words_visemes.length);
            data.words_visemes.forEach((unit: any, index: number) => {
                console.log(`單位 ${index}: "${unit.text}" charIndex: ${unit.charIndex}, visemes: [${unit.visemes.join(', ')}]`);
            });
        } else {
            console.warn('words_visemes 格式無效:', data.words_visemes);
        }
        
        // 設定 Avatar
        onExpression(data.emotion || 'neutral');
        console.log('設置表情:', data.emotion || 'neutral');
        onPhonemes(data.words_visemes || []);            // 移除 thinking... 並顯示分析結果
            setMessages(prev => {
                const filtered = prev.filter(msg => msg.text !== 'thinking...');
                return [...filtered, { 
                    text: `分析完成 - 語言: ${data.language}, 情緒: ${data.emotion}`, 
                    sender: 'bot' 
                }];
            });
            
            // TTS 播放用戶輸入文字
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.rate = 1.0;
            utterance.pitch = 1.2;
            utterance.onstart = () => {
                console.log('開始嘴型同步，phonemes:', data.words_visemes);
                onSpeak(true);
                onCharIndex(0);
            };
            utterance.onboundary = (event) => {
                if (event.name === 'word' || event.name === 'sentence') {
                    onCharIndex(event.charIndex);
                }
            };
            utterance.onend = () => {
                console.log('TTS 結束，重置表情到 neutral');
                onSpeak(false);
                onCharIndex(0);
                // 重置表情到 neutral
                onExpression('neutral');
                console.log('已呼叫 onExpression("neutral")');
            };
            window.speechSynthesis.speak(utterance);
            
        } catch (error) {
            console.error('Error:', error);
            // 錯誤處理
            setMessages(prev => {
                const filtered = prev.filter(msg => msg.text !== 'thinking...');
                return [...filtered, { text: '分析失敗', sender: 'bot' }];
            });
        }
        setInput('');
    };    const startVoiceInput = () => {
        const recognition = new (window as any).webkitSpeechRecognition();
        recognition.lang = 'zh-TW';
        recognition.continuous = false;
        recognition.interimResults = false;
        recognition.onresult = (event: any) => {
            const result = event.results[0][0];
            if (result.confidence > 0.7) {
                const transcript = result.transcript;
                sendMessage(transcript);
            } else {
                alert('語音辨識信心度不足，請重試');
            }
        };
        recognition.onerror = () => alert('語音辨識失敗');
        recognition.start();
    };

    return (
        <div style={{ height: '100%', display: 'flex', flexDirection: 'column', padding: '20px 0', border: '2px solid #ccc', borderRadius: '8px', backgroundColor: '#fafafa' }}>
            <List
                dataSource={messages}
                renderItem={(item) => (
                    <List.Item style={{ justifyContent: item.sender === 'user' ? 'flex-end' : 'flex-start' }}>
                        <div style={{
                            background: item.sender === 'user' ? '#007bff' : '#f0f0f0',
                            padding: 10,
                            borderRadius: 10,
                            color: item.sender === 'user' ? 'white' : 'black'
                        }}>
                            {item.text}
                        </div>
                    </List.Item>
                )}
                style={{ flex: 1, overflowY: 'auto' }}
            />
            <Input.Group compact style={{ marginTop: 10 }}>
                <Input
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    onPressEnter={() => sendMessage(input)}
                    placeholder="輸入訊息"
                    style={{ width: '70%' }}
                />
                <Button onClick={() => sendMessage(input)}>發送</Button>
                <Button onClick={startVoiceInput}>語音</Button>
            </Input.Group>
        </div>
    );
};

export default ChatRoom;