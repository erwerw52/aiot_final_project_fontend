import React, { useEffect, useRef, useState } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader';
import { VRM, VRMLoaderPlugin } from '@pixiv/three-vrm';
import * as THREE from 'three';

interface AvatarProps {
  isSpeaking: boolean;
}

const AvatarModel: React.FC<{ isSpeaking: boolean }> = ({ isSpeaking }) => {
  const [vrm, setVrm] = useState<VRM | null>(null);
  const mixerRef = useRef<THREE.AnimationMixer | null>(null);

  useEffect(() => {
    const loader = new GLTFLoader();
    loader.register((parser) => new VRMLoaderPlugin(parser));
    loader.load(
      '/taipu.vrm',
      (gltf) => {
        const vrmModel = gltf.userData.vrm as VRM;
        setVrm(vrmModel);
        vrmModel.scene.position.x = 0;
        vrmModel.scene.position.y = -1.1;
        vrmModel.scene.position.z = 0;
        mixerRef.current = new THREE.AnimationMixer(vrmModel.scene);

        // 透過字串取得手臂骨骼節點，設置自然下垂姿勢
        const leftUpperArm = vrmModel.humanoid?.getBoneNode('leftUpperArm');
        const rightUpperArm = vrmModel.humanoid?.getBoneNode('rightUpperArm');

        if (leftUpperArm) {
          // z 軸旋轉讓手臂向下，x 軸微調前後角度
          leftUpperArm.rotation.z = THREE.MathUtils.degToRad(70);  // 向下 70 度
          leftUpperArm.rotation.x = THREE.MathUtils.degToRad(10);  // 稍微向前
        }
        if (rightUpperArm) {
          rightUpperArm.rotation.z = THREE.MathUtils.degToRad(-70); // 向下 70 度
          rightUpperArm.rotation.x = THREE.MathUtils.degToRad(10);  // 稍微向前
        }

      },
      (progress: any) => console.log('載入進度:', progress),
      (error: any) => console.error('VRM 載入錯誤:', error)
    );
  }, []);

  useFrame((state, delta) => {
    if (mixerRef.current) {
      mixerRef.current.update(delta);
    }
    if (vrm) {
      if (isSpeaking) {
        const mouthOpen = Math.sin(state.clock.elapsedTime * 10) * 0.5 + 0.5;
        if (vrm.expressionManager) {
          vrm.expressionManager.setValue('aa', mouthOpen);
        }
      } else {
        if (vrm.expressionManager) {
          vrm.expressionManager.setValue('aa', 0);
        }
      }
    }
  });

  return vrm ? <primitive object={vrm.scene} rotation={[0, Math.PI, 0]} /> : null;
};

const Avatar: React.FC<AvatarProps> = ({ isSpeaking }) => {
  return (
    <Canvas style={{ height: '100%', width: '100%' }} camera={{ position: [0, 0, 1.9], fov: 68 }}>
      <ambientLight intensity={0.5} />
      <directionalLight position={[1, 1, 1]} />
      <AvatarModel isSpeaking={isSpeaking} />
    </Canvas>
  );
};

export default Avatar;