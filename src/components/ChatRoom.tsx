import React, { useState } from 'react';
import { Input, Button, List } from 'antd';

interface Message {
    text: string;
    sender: 'user' | 'bot';
}

interface ChatRoomProps {
    onSpeak: (speaking: boolean) => void;
}

const ChatRoom: React.FC<ChatRoomProps> = ({ onSpeak }) => {
    const [messages, setMessages] = useState<Message[]>([]);
    const [input, setInput] = useState('');

    const sendMessage = async (text: string) => {
        setMessages(prev => [...prev, { text, sender: 'user' }]);
        try {
            // Mock n8n response
            console.log('訊息已發送:', text);
            // Simulate bot response after 2 seconds
            setTimeout(async () => {
                const botResponse = `你說了: ${text}，這是模擬回應。`;
                setMessages(prev => [...prev, { text: botResponse, sender: 'bot' }]);
                // Play TTS
                const utterance = new SpeechSynthesisUtterance(botResponse);
                // utterance.lang = 'ja-JP';
                utterance.rate = 1.0;
                utterance.pitch = 1.2;
                utterance.onstart = () => onSpeak(true);
                utterance.onend = () => onSpeak(false);
                window.speechSynthesis.speak(utterance);
            }, 2000);
        } catch (error) {
            console.error('模擬錯誤:', error);
        }
        setInput('');
    };

    const startVoiceInput = () => {
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