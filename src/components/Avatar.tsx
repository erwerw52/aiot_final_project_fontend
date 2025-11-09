import React, { useEffect, useRef, useState } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { VRM, VRMLoaderPlugin } from '@pixiv/three-vrm';
import * as THREE from 'three';
import { GLTFLoader, GLTF } from 'three/examples/jsm/loaders/GLTFLoader.js';

interface AvatarProps {
  isSpeaking: boolean;
  expression: string;
  currentText: string;
  charIndex: number;
  phonemes: Array<{text: string, charIndex: number, visemes: string[]}>;
}

const AvatarModel: React.FC<{ isSpeaking: boolean; expression: string; currentText: string; charIndex: number; phonemes: Array<{text: string, charIndex: number, visemes: string[]}> }> = ({ isSpeaking, expression, currentText, charIndex, phonemes }) => {
  const [vrm, setVrm] = useState<VRM | null>(null);
  const [availableExpressions, setAvailableExpressions] = useState<string[]>([]);
  const mixerRef = useRef<THREE.AnimationMixer | null>(null);
  const phonemesRef = useRef<Array<{text: string, charIndex: number, visemes: string[]}>>([]);
  const lastVisemeIndexRef = useRef<number>(-1);

  useEffect(() => {
    const loader = new GLTFLoader();
    // 重新啟用 VRM 插件
    loader.register((parser: any) => new VRMLoaderPlugin(parser));
    loader.load(
      '/taipu.vrm',
      (gltf: GLTF) => {
        const vrmModel = gltf.userData.vrm as VRM;
        if (vrmModel) {
          setVrm(vrmModel);
          vrmModel.scene.position.x = 0;
          vrmModel.scene.position.y = -1.1;
          vrmModel.scene.position.z = 0;
          mixerRef.current = new THREE.AnimationMixer(vrmModel.scene);

          // Log available expressions
          if (vrmModel.expressionManager) {
            const expressions = vrmModel.expressionManager.expressions.map(exp => exp.expressionName);
            setAvailableExpressions(expressions);
            console.log('VRM 載入完成，可用表情:', expressions);
          }
        } else {
          // 使用 GLTF 場景作為備用
          gltf.scene.position.y = -1.1;
          setVrm({ scene: gltf.scene } as any);
        }
      },
      (progress: any) => {},
      (error: any) => console.error('VRM 載入錯誤:', error)
    );
  }, []);

  useFrame((state, delta) => {
    if (mixerRef.current) {
      mixerRef.current.update(delta);
    }
    
    if (!vrm) return;

    // 關鍵: 必須更新 VRM 才能讓表情生效
    vrm.update(delta);

    // 重新設置手臂姿勢，因為 VRM update 可能會重置
    const leftUpperArm = vrm.humanoid?.getRawBoneNode('leftUpperArm');
    const rightUpperArm = vrm.humanoid?.getRawBoneNode('rightUpperArm');

    if (leftUpperArm) {
      leftUpperArm.rotation.z = THREE.MathUtils.degToRad(70);
      leftUpperArm.rotation.x = THREE.MathUtils.degToRad(10);
    }
    if (rightUpperArm) {
      rightUpperArm.rotation.z = THREE.MathUtils.degToRad(-70);
      rightUpperArm.rotation.x = THREE.MathUtils.degToRad(10);
    }

    // 嘴型動畫邏輯 - 根據 phonemes 資料驅動
    if (isSpeaking && vrm.expressionManager && phonemes.length > 0) {
      // 找到當前 charIndex 對應的 phoneme 單位
      const currentUnit = phonemes.find((unit, index) => {
        const nextUnit = phonemes[index + 1];
        return charIndex >= unit.charIndex && (!nextUnit || charIndex < nextUnit.charIndex);
      });

      if (currentUnit && currentUnit.visemes.length > 0) {
        // 計算單位內的進度
        const nextUnit = phonemes.find((unit, index) => {
          const currentIdx = phonemes.findIndex(u => u.text === currentUnit.text);
          return index === currentIdx + 1;
        });
        
        const unitDuration = nextUnit ? nextUnit.charIndex - currentUnit.charIndex : currentUnit.text.length;
        const progressInUnit = Math.min((charIndex - currentUnit.charIndex) / unitDuration, 1.0);
        
        // 根據進度選擇 viseme
        const visemeIndex = Math.floor(progressInUnit * currentUnit.visemes.length);
        const clampedIndex = Math.min(visemeIndex, currentUnit.visemes.length - 1);
        const currentViseme = currentUnit.visemes[clampedIndex];

        // 記錄切換
        if (clampedIndex !== lastVisemeIndexRef.current) {
          lastVisemeIndexRef.current = clampedIndex;
          console.log(`根據 charIndex 切換嘴型: ${currentViseme} (charIndex: ${charIndex}, progress: ${(progressInUnit * 100).toFixed(1)}%, text: "${currentUnit.text}")`);
        }

        // 使用正弦波產生自然的嘴型開合動畫
        const baseIntensity = Math.sin(state.clock.elapsedTime * 12) * 0.35 + 0.65;

        // 重置所有嘴型
        ['aa', 'ih', 'ou', 'ee', 'oh'].forEach(v => {
          if (availableExpressions.includes(v)) {
            vrm.expressionManager!.setValue(v, 0);
          }
        });

        // 設定當前嘴型
        if (availableExpressions.includes(currentViseme)) {
          vrm.expressionManager.setValue(currentViseme, baseIntensity);
        } else if (availableExpressions.includes('aa')) {
          // 備用嘴型
          vrm.expressionManager.setValue('aa', baseIntensity * 0.7);
        }
      } else {
        // 沒有有效的 visemes，重置嘴型
        ['aa', 'ih', 'ou', 'ee', 'oh'].forEach(v => {
          if (availableExpressions.includes(v)) {
            vrm.expressionManager!.setValue(v, 0);
          }
        });
        lastVisemeIndexRef.current = -1;
      }
    } else if (vrm.expressionManager) {
      // 不在說話或沒有 phonemes 資料，重置嘴型
      ['aa', 'ih', 'ou', 'ee', 'oh'].forEach(v => {
        if (availableExpressions.includes(v)) {
          vrm.expressionManager!.setValue(v, 0);
        }
      });
      lastVisemeIndexRef.current = -1;
    }
  });

  // 根據 props 傳入的 expression 設定表情
  useEffect(() => {
    console.log('Avatar useEffect triggered, expression:', expression, 'vrm:', !!vrm);
    
    if (!vrm || !vrm.expressionManager) {
      return;
    }

    // 重置所有情緒表情（不重置嘴型）
    const emotionExpressions = ['happy', 'sad', 'angry', 'relaxed', 'surprised'];
    emotionExpressions.forEach(exp => {
      if (availableExpressions.includes(exp)) {
        vrm.expressionManager!.setValue(exp, 0);
        console.log(`重置表情: ${exp}`);
      }
    });

    if (!expression || expression === 'neutral') {
      console.log('表情是 neutral 或未定義，返回');
      return;
    }

    // 設置從 props 傳入的表情
    if (availableExpressions.includes(expression)) {
      vrm.expressionManager.setValue(expression, 1);
      console.log(`設置表情: ${expression} = 1`);
    }
  }, [vrm, expression, availableExpressions]);

  return vrm ? <primitive object={vrm.scene} rotation={[0, Math.PI, 0]} /> : null;
};

const Avatar: React.FC<AvatarProps> = ({ isSpeaking, expression, currentText, charIndex, phonemes }) => {
  return (
    <Canvas style={{ height: '100%', width: '100%' }} camera={{ position: [0, 0, 1.9], fov: 68 }}>
      <ambientLight intensity={0.5} />
      <directionalLight position={[1, 1, 1]} />
      <AvatarModel isSpeaking={isSpeaking} expression={expression} currentText={currentText} charIndex={charIndex} phonemes={phonemes} />
    </Canvas>
  );
};

export default Avatar;