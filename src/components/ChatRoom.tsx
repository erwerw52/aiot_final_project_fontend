import React, { useState } from 'react';
import { Input, Button, List } from 'antd';

interface Message {
    text: string;
    sender: 'user' | 'bot';
}

interface ChatRoomProps {
    onSpeak: (speaking: boolean) => void;
    onExpression: (expression: string) => void;
    onText: (text: string) => void;
    onCharIndex: (index: number) => void;
}

const ChatRoom: React.FC<ChatRoomProps> = ({ onSpeak, onExpression, onText, onCharIndex }) => {
    const [messages, setMessages] = useState<Message[]>([]);
    const [input, setInput] = useState('');

    const sendMessage = async (text: string) => {
        setMessages(prev => [...prev, { text, sender: 'user' }]);
        // 簡化邏輯，移除 Ollama 和嘴型同步
        setMessages(prev => [...prev, { text: '收到訊息', sender: 'bot' }]);
        setInput('');
    }; const startVoiceInput = () => {
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
        <div style={{ height: '100%', display: 'flex', flexDirection: 'column', padding: '20px 0', border: '2px solid #ccc', borderRadius: '8px', backgroundColor: '#fafafa', paddingLeft: 30, paddingRight: 30 }}>
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
            
            <div style={{ display: 'flex', flexDirection: 'column'}}>
                <Input
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    placeholder="輸入訊息"
                    style={{ width: '100%', padding: '0 30px', height: 50, resize: 'none', fontSize: 16 }}
                />
                <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 10 }}>
                    <Button onClick={startVoiceInput} style={{ marginRight: 10 }}>語音</Button>
                    <Button onClick={() => sendMessage(input)}>發送</Button>
                </div>
            </div>
        </div>
    );
};

export default ChatRoom;