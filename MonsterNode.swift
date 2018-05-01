import Foundation
import SpriteKit

class MonsterNode: SKSpriteNode {
  var farm:FarmNode?
	var hasHitAFarm: Bool { return self.physicsBody == nil }
	let mySpeed = random(min: 250.0, max: 500.0)

  func pickYourFarmAndGoThere(farms:[FarmNode]) {
		if let farm = self.farm {
			if farms.contains(farm) { return }
		}
		guard farms.count > 0 && !self.hasHitAFarm else { return }

		if self.farm != nil {
			print("breakpoint!")
		}
		farm = farms[Int(arc4random_uniform(UInt32(farms.count - 1)))]
		
		self.removeAllActions()
		let destination = farm!.position
		let distance = (destination - self.position).length()
		let movementTime = TimeInterval(distance / self.mySpeed)
		let actionMove = SKAction.move(to: destination,
																	 duration: movementTime)
		self.runAndRemove(actionMove)
  }
}
