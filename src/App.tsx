import React, { useState } from 'react';
import ChatRoom from './components/ChatRoom';
import Avatar from './components/Avatar';
import 'antd/dist/reset.css';
import './App.css';

const App: React.FC = () => {
    const [isSpeaking, setIsSpeaking] = useState(false);
    const [expression, setExpression] = useState('neutral');
    const [currentText, setCurrentText] = useState('');
    const [charIndex, setCharIndex] = useState(0);

    return (
        <div style={{ display: 'flex', height: '100vh' }}>
            <div style={{ flex: 2, paddingLeft: 10, paddingRight: 10 }}>
                <ChatRoom 
                    onSpeak={setIsSpeaking} 
                    onExpression={setExpression} 
                    onText={setCurrentText} 
                    onCharIndex={setCharIndex}
                />
            </div>
            <div style={{ flex: 1, display: 'flex', alignItems: 'flex-start', justifyContent: 'center', overflow: 'hidden' }}>
                <Avatar 
                    isSpeaking={isSpeaking} 
                    expression={expression} 
                    currentText={currentText} 
                    charIndex={charIndex}
                />
            </div>
        </div>
    );
};

export default App;