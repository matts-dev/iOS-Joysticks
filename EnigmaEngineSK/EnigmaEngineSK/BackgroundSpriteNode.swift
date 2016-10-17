//
//  BackgroundSpriteNode.swift
//  EnigmaEngineSK
//
//  Created by Matt Stone on 10/17/16.
//  Copyright © 2016 Matt Stone. All rights reserved.
//

import UIKit
import SpriteKit

class BackgroundSpriteNode: SKNode {
    
    var backgroundSprites:SKNode = SKNode()
    
    init(ImageName img:String, NumberOfTiles numTiles:Int){
        for i in (0..<numTiles) {
            for j in (0..<numTiles){
                let temp = SKSpriteNode(imageNamed: img)
                let size = temp.size
                temp.position = CGPoint(x: CGFloat(j)*size.width, y: CGFloat(i)*size.height)
                backgroundSprites.addChild(temp)
            }
        }
        super.init()
        addChild(backgroundSprites)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
    }
}
