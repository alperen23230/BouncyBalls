//
//  GameScene.swift
//  BounceBalls
//
//  Created by Alperen Ünal on 18.03.2019.
//  Copyright © 2019 Alperen Ünal. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var balls = ["ballRed", "ballYellow", "ballPurple", "ballGreen", "ballGrey", "ballCyan", "ballBlue"]
    var scoreLabel: SKLabelNode!
    var score = 0{
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var ballLimit = 5
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        physicsWorld.contactDelegate = self
    
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
    
        var j = 0
        for _ in 0..<5 {
            makeBouncer(at: CGPoint(x: j, y: 0))
            j += 256
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
    
        if objects.contains(editLabel){
            editingMode.toggle()
        }
        else{
            if editingMode {
                // create a box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.name = "box"
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                
                addChild(box)
            } else {
                if ballLimit == 0 || ballLimit < 0{
                    ballLimit = 5
                }
                else{
                    let ballColor = balls.randomElement()
                    // create a ball
                    let ball = SKSpriteNode(imageNamed: ballColor!)
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2.0)
                    ball.physicsBody?.restitution = 0.4
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    let pos = CGPoint(x: 0, y: 100)
                    ball.position = location + pos
                    
                    ball.name = "ball"
                    addChild(ball)
                    ballLimit -= 1
                }
                
            }
        }
    }
    
    func makeBouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        addChild(slotBase)
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode){
        if object.name == "good"{
            destroy(ball: ball)
            score += 1
            ballLimit += 1
        } else if object.name == "bad"{
            destroy(ball: ball)
            score -= 1
        } else if object.name == "box"{
            destroyBox(box: object)
        }
    }
    
    func destroy(ball: SKNode){
        
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles"){
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func destroyBox(box: SKNode){
        box.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }

    
}
