import React, { useState } from 'react';
import { Input, Button, List } from 'antd';
import { useTts } from '../hooks/useTts';

interface Message {
    text: string;
    sender: 'user' | 'bot';
}

interface ChatRoomProps {
    onSpeak: (speaking: boolean) => void;
    onTextUpdate?: (text: string) => void;
}

const ChatRoom: React.FC<ChatRoomProps> = ({ onSpeak, onTextUpdate }) => {
    const [messages, setMessages] = useState<Message[]>([]);
    const [input, setInput] = useState('');

    const handleTextUpdate = (updatedText: string) => {
        setMessages(prev => {
            const newMsgs = [...prev];
            if (newMsgs.length > 0 && newMsgs[newMsgs.length - 1].sender === 'bot') {
                newMsgs[newMsgs.length - 1].text = updatedText;
            }
            return newMsgs;
        });
    };

    const { speak } = useTts({ onSpeak, onTextUpdate: handleTextUpdate });

    const sendMessage = async (text: string) => {
        setMessages(prev => [...prev, { text, sender: 'user' }]);
        try {
            // Mock n8n response
            console.log('訊息已發送:', text);
            // Simulate bot response after 2 seconds
            setTimeout(async () => {
                const botResponse = text;
                setMessages(prev => [...prev, { text: '', sender: 'bot' }]);
                // Play TTS using useTts
                console.log('Calling speak with botResponse:', botResponse);
                speak(botResponse);
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