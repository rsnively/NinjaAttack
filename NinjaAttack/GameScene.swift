/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SpriteKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

extension SKNode {
  func runAndRemove(_ action:SKAction) {
    run(SKAction.sequence([action, SKAction.removeFromParent()]))
  }
}

struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let monster   : UInt32 = 0b001      // 1
  static let projectile: UInt32 = 0b010      // 2
  static let farm      : UInt32 = 0b100      // 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  let player = SKSpriteNode(imageNamed: "player")
//  var health = 10
//  var healthBarSize:CGSize { return CGSize(width: CGFloat(self.health * 20), height: 10.0) }
//  lazy var healthBar = SKSpriteNode(color:UIColor.red, size:self.healthBarSize)

  override func didMove(to view: SKView) {
    backgroundColor = SKColor.lightGray
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self
    
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    addChild(player)
    giveBirthToMonsters()
    
    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)
    
    giveBirthToFarms()
    
//    healthBar.position = CGPoint(x: size.width * 0.5, y: size.height - healthBar.size.height)
//    addChild(healthBar)
  }
  
  func addMonster() {
    let monster = MonsterNode(imageNamed: "monster")
    monster.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: monster.size.width * 0.5, height: monster.size.height * 0.8)) // 1
    monster.physicsBody?.isDynamic = true // 2
    monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile | PhysicsCategory.farm
    monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
    
    let x = size.width + monster.size.width/2
    let y = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
    monster.position = CGPoint(x: x, y: y)
    addChild(monster)
    
    let speed = random(min: CGFloat(2.0), max: CGFloat(10.0))
    let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: y),
                                   duration: TimeInterval(speed))
    monster.runAndRemove(actionMove)
//    monster.runAndRemove(SKAction.sequence([actionMove, SKAction.run({ self.loseHealth(amount:1) })]))
  }
  
  func giveBirthToMonsters() {
    addMonster()
    let duration = TimeInterval(random(min: 0.5, max: 2.0))
    run(SKAction.sequence([SKAction.wait(forDuration: duration), SKAction.run(giveBirthToMonsters)]))
  }
  
  func giveBirthToFarms() {
    for i in 1...5 {
      let farm = FarmNode()
      farm.position = CGPoint(x: 0, y: CGFloat(i) * farm.size.height)
      
      farm.physicsBody = SKPhysicsBody(rectangleOf: farm.size)
      farm.physicsBody?.isDynamic = true
      farm.physicsBody?.categoryBitMask = PhysicsCategory.farm
      farm.physicsBody?.contactTestBitMask = PhysicsCategory.monster
      farm.physicsBody?.collisionBitMask = PhysicsCategory.none
      
      addChild(farm)
    }
  }
  
//  func loseHealth(amount:Int) {
//    health -= amount
//    if health <= 0 {
//      let logan:Int? = nil
//      print(logan!)
//    }
//    healthBar.size = healthBarSize
//  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    let touchLocation = touch.location(in: self)
    
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position + CGPoint(x: player.size.width * 0.3, y: player.size.height * 0.1)
    
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.isDynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
    projectile.physicsBody?.usesPreciseCollisionDetection = true
    
    let projectileVector = touchLocation - projectile.position
    if projectileVector.x < 0 { return }
    run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
    addChild(projectile)
    let direction = projectileVector.normalized()
    let shootAmount = direction * (self.size.width + self.size.height)
    let realDest = shootAmount + projectile.position
    
    let actionMove = SKAction.move(to: realDest, duration: 2.0)
    projectile.runAndRemove(actionMove)
  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
    projectile.removeFromParent()
    monster.removeFromParent()
  }
  
  func monsterDidCollideWithFarm(monster:SKSpriteNode, farm:FarmNode) {
    farm.takeAHit()
    monster.physicsBody = nil
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    let monsterFirst = contact.bodyA.categoryBitMask & PhysicsCategory.monster != 0
    let monsterBody = monsterFirst ? contact.bodyA : contact.bodyB
    let otherBody = monsterFirst ? contact.bodyB : contact.bodyA

    if let monster = monsterBody.node as? SKSpriteNode {
      if let farm = otherBody.node as? FarmNode {
        monsterDidCollideWithFarm(monster: monster, farm: farm)
      }
      else if let projectile = otherBody.node as? SKSpriteNode {
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
    }
  }
}
