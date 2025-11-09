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
}

const AvatarModel: React.FC<{ isSpeaking: boolean; expression: string; currentText: string; charIndex: number }> = ({ isSpeaking, expression, currentText, charIndex }) => {
  const [vrm, setVrm] = useState<VRM | null>(null);
  const [availableExpressions, setAvailableExpressions] = useState<string[]>([]);
  const mixerRef = useRef<THREE.AnimationMixer | null>(null);
  const initialChestY = useRef<number>(0);

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
          vrmModel.scene.position.y = -0.9;
          vrmModel.scene.position.z = 0;
          mixerRef.current = new THREE.AnimationMixer(vrmModel.scene);

          // 記錄胸部初始位置
          if (vrmModel.humanoid) {
            const chest = vrmModel.humanoid.getRawBoneNode('chest');
            if (chest) {
              initialChestY.current = chest.position.y;
            }
          }

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

    // 添加呼吸動畫：胸部以上輕微上下起伏
    const breathOffset = Math.sin(state.clock.getElapsedTime() * Math.PI / 2) * 0.005; // 每 4 秒一個週期，幅度 0.005
    const chest = vrm.humanoid?.getRawBoneNode('chest');
    if (chest) {
      chest.position.y = initialChestY.current + breathOffset;
    }

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

  // 添加眨眼功能，每 5 秒眨一次
  useEffect(() => {
    if (!vrm || !vrm.expressionManager || !availableExpressions.includes('blink')) return;

    const blinkInterval = setInterval(() => {
      if (vrm && vrm.expressionManager) {
        vrm.expressionManager.setValue('blink', 1);
        setTimeout(() => {
          if (vrm && vrm.expressionManager) {
            vrm.expressionManager.setValue('blink', 0);
          }
        }, 100); // 眨眼持續 200 毫秒
      }
    }, 5000);

    return () => clearInterval(blinkInterval);
  }, [vrm, availableExpressions]);

  return vrm ? <primitive object={vrm.scene} rotation={[0, Math.PI, 0]} /> : null;
};

const Avatar: React.FC<AvatarProps> = ({ isSpeaking, expression, currentText, charIndex }) => {
  return (
    <Canvas style={{ height: '100%', width: '100%' }} camera={{ position: [0, 0, 1.9], fov: 68 }}>
      <ambientLight intensity={0.5} />
      <directionalLight position={[1, 1, 1]} />
      <AvatarModel isSpeaking={isSpeaking} expression={expression} currentText={currentText} charIndex={charIndex} />
    </Canvas>
  );
};

export default Avatar;