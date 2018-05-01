import Foundation
import SpriteKit

class FarmNode: SKNode {
  static let startingHealth = 10
  let farm = SKSpriteNode(imageNamed: "farm")
  var health = startingHealth {
    didSet {
      farm.colorBlendFactor = 1.0 - CGFloat(self.health) / CGFloat(FarmNode.startingHealth)
      if health == 0 {
        run(SKAction.fadeOut(withDuration: 1.0))
      }
    }
  }
  var dead:Bool {
    return health <= 0
  }
  var size:CGSize {
    get {
      return CGSize(width: farm.size.width, height: farm.size.height * 0.6)
    }
  }
  
  override init() {
    super.init()
    farm.setScale(0.5)
    farm.color = UIColor.red
    addChild(farm)
  }
  
  func takeAHit() {
    health -= 1
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
