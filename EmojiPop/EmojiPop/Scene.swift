//
//  Scene.swift
//  EmojiPop
//
//  Created by Enes on 8/5/24.
//

import SpriteKit
import ARKit

public enum GameState {
    case Init
    case TapToStart
    case Playing
    case GameOver
}

class Scene: SKScene {
    var gameState = GameState.Init
    var anchor: ARAnchor?
    var emojis = "😀✅🙇‍♂️🚨🔥🩵"
    var spawnTime : TimeInterval = 0
    var score : Int = 0
    var lives : Int = 10
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        startGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
        
        switch gameState {
        case .Init:
            break
        case .TapToStart:
            playGame()
            addAnchor()
            break
        case .Playing:
            //checkTouches(touches)
            break
        case .GameOver:
            startGame()
            break
        }
    }
    
    // HUD메시지
    func updateHUD(_ message: String) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }

        let viewController = sceneView.delegate as! ViewController
        viewController.hudLabel.text = message
    }
    
    public func startGame() {
        gameState = .TapToStart
        updateHUD("- TAP TO START -")
    }
    
    public func playGame() {
        gameState = .Playing
        score = 0
        lives = 10
    }
    
    public func stopGame() {
        gameState = .GameOver
        updateHUD("GAME OVER! SCORE: " + String(score))
        removeAnchor()
    }
    
    func addAnchor() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        // 카메라가 포함된 AR 세션에서 현재 활성 프레임을 가져옴
        if let currentFrame = sceneView.session.currentFrame {
            // 카메라 뷰에서 50cm 앞에 위치한 새 트랜스폼을 계산
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5
            let transform = simd_mul(
                currentFrame.camera.transform,
                translation
            )
            // 새 트랜스폼 정보로 AR 앵커를 생성한 후 AR 세션에 추가
            anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor!)
        }
    }
    
    func removeAnchor() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        if anchor != nil {
            sceneView.session.remove(anchor: anchor!)
        }
    }
    
}
