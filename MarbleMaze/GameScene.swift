//
//  GameScene.swift
//  MarbleMaze
//
//  Created by Nick Sagan on 28.11.2021.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var motionManager: CMMotionManager!
    var scoreLabel: SKLabelNode!
    var isGameOver = false
    var level = 1
    var isTeleported = false

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        // Setup physics
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Setup maze and player position
        setupInterface()
        loadLevel()
        createPlayer(at: CGPoint(x: 96, y: 672))
        
        // activate Core Motion
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
    }
    
    func setupInterface() {
        // Set background image
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        // Add score
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
    }
    
    func createPlayer(at position: CGPoint) {
        player = SKSpriteNode(imageNamed: "player")
        player.position = position
        player.zPosition = 1
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5

        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
    }
    
    func loadLevel() {
        isTeleported = false
        guard let levelURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else {fatalError("Can't find level\(level).txt")}
        guard let levelString = try? String(contentsOf: levelURL) else {fatalError("Can't load level\(level).txt")}
print(levelString)
        var lines = levelString.components(separatedBy: "\n")
        // to remove last empty line
        for i in 0...lines.count-1 {
            if lines[i] == "" {
                lines.remove(at: i)
            }
        }
print(lines)
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)

                if letter == "x" {
                    createBlock(at: position)
                } else if letter == "v"  {
                    createVortex(at: position)
                } else if letter == "s"  {
                    createStar(at: position)
                } else if letter == "f"  {
                    createFinish(at: position)
                } else if letter == " " {
                    // this is an empty space – do nothing!
                } else if letter == "t" {
                    createTeleportEntrance(at: position)
                } else if letter == "e" {
                    createTeleportExit(at: position)
                } else {
                    fatalError("Unknown level letter: \(letter)")
                }
            }
        }
    }
    
    func createVortex(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        addChild(node)
    }
    
    func createBlock(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        addChild(node)
    }
    
    func createStar(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func createFinish(at position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func createTeleportEntrance(at position: CGPoint) {
        let node = SKSpriteNode(color: .systemBlue, size: CGSize(width: 50, height: 50))
        node.name = "teleportEntrance"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.tEntrance.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func createTeleportExit(at position: CGPoint) {
        let node = SKSpriteNode(color: .systemRed, size: CGSize(width: 50, height: 50))
        node.name = "teleportExit"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.tExit.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1

            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])

            player.run(sequence) { [weak self] in
                self?.createPlayer(at: CGPoint(x: 96, y: 672))
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            node.removeFromParent()
            score += 1
            level += 1
            
            for child in self.children {
                child.removeFromParent()
            }
            
            setupInterface()
            loadLevel()
            createPlayer(at: CGPoint(x: 96, y: 672))
        } else if node.name == "teleportEntrance" && !isTeleported {
            isTeleported = true
            player.removeFromParent()
            createPlayer(at: childNode(withName: "teleportExit")?.position ?? CGPoint(x: 96, y: 672))
        } else if node.name == "teleportExit" && !isTeleported {
            isTeleported = true
            player.removeFromParent()
            createPlayer(at: childNode(withName: "teleportEntrance")?.position ?? CGPoint(x: 96, y: 672))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // check if game is over or not
        guard isGameOver == false else { return }
        
        // this is to test on simulator
        // Not ready yet, maybe later
#if targetEnvironment(simulator)
//        if let currentTouch = lastTouchPosition {
//            let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
//            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
//        }
#else
        if let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
#endif
    }
    
    //MARK: - SKPhysicsContactDelegate
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
}
