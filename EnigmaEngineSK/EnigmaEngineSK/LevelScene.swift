//
//  LevelScene.swift
//  EnigmaEngineSK
//
//  Created by Matt Stone on 10/14/16.
//  Copyright © 2016 Matt Stone. All rights reserved.
//
// USAGE: Place create a new joystick object, and add the joystick update method to the scene update.s
//
//
//


import UIKit
import SpriteKit
import GameplayKit

class LevelScene: SKScene {
    
    let cameraNode:SKCameraNode
    let player:SKSpriteNode
    let rightJS:EEJoyStick
    let leftJS:EEJoyStick
    let scaledFrameSize:CGSize
    let backgroundSprite: SKSpriteNode
    var baseX: CGFloat {
        get{ return scaledFrameSize.width / 2 }
    }
    var baseY: CGFloat{
        get{  return scaledFrameSize.height / 2}
    }
    

    
    init(_ frameSize: CGSize){
        
        //Declaration matters - at least when using classes that contain multiple nodess
        cameraNode = SKCameraNode()
        backgroundSprite = SKSpriteNode(imageNamed: "Grass2.png")
        rightJS = EEJoyStick()
        leftJS = EEJoyStick()
        player = SKSpriteNode(imageNamed: "GenericActorSprite.png")

        
        //swap size before calling super
        let swapSize = CGSize(width: frameSize.height, height: frameSize.width)
        scaledFrameSize = LevelScene.createLargeFrameSize(startSize: swapSize, increaseFactor: 1)
        
        super.init(size: scaledFrameSize)
        
        //Background
        self.backgroundColor = SKColor.gray
        addChild(backgroundSprite)
        
        //Camera Placement
        cameraNode.position = CGPoint(x: baseX/2, y: baseY/2)
        addChild(cameraNode)
        
        //Joy Sticks
        rightJS.position = CGPoint(x: frame.size.width * 0.25 + baseX, y: frame.size.height * 0.1 + baseY)
        addChild(rightJS)
        
        leftJS.position = CGPoint(x: frame.size.width * 0.75 + baseX, y: frame.size.height * 0.1 + baseY)
        addChild(leftJS)
        
        //Actors
        player.position = CGPoint(x: baseX/2, y: baseY/2)
        addChild(player)
        


        
        
        
    }
    
    //MARK: touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //test by moving player to click, which should move camera
        let ftouch = touches.first!
        let ftloc = ftouch.location(in: self)
        
        //convert view coordinates to scene coordinates
        // ???
        
        //use converted points
        let touchPt:CGPoint = CGPoint(x: ftloc.x, y: ftloc.y)
        player.run(SKAction.move(to: touchPt, duration: 2), withKey: "moving player")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLoc = touch.location(in: self)
            //let touchID = touch
            
            //do checking of position in window (left or right js?)
            
            //move this inside the for loop
            leftJS.moveStick(joyStickLocation: leftJS.position, touchLocation: touchLoc)
        }
    }
    
    
    //MAKR: CODERS
    
    required init?(coder aDecoder: NSCoder) {
        cameraNode = aDecoder.decodeObject(forKey: "cameraNode") as! SKCameraNode
        scaledFrameSize = aDecoder.decodeObject(forKey: "scaledFrameSize") as! CGSize
        rightJS = aDecoder.decodeObject(forKey: "rightJS") as! EEJoyStick
        leftJS = aDecoder.decodeObject(forKey: "leftJS") as! EEJoyStick
        backgroundSprite = aDecoder.decodeObject(forKey: "backgroundSprite") as! SKSpriteNode
        player = aDecoder.decodeObject(forKey: "player") as! SKSpriteNode

        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(cameraNode, forKey: "cameraNode")
        aCoder.encode(scaledFrameSize, forKey: "scaledFrameSize")
        aCoder.encode(rightJS, forKey: "rightJS")
        aCoder.encode(leftJS, forKey: "leftJS")
        aCoder.encode(backgroundSprite, forKey: "backgroundSprite")
        aCoder.encode(player, forKey: "player")
    }
    
    override func didMove(to view:SKView){
        self.camera = cameraNode
    }
    
    //returns the size, multiplied by a factor.
    static func createLargeFrameSize(startSize size:CGSize, increaseFactor factor:Int) -> CGSize {
        var factorMut = CGFloat(factor)
        
        //while size overflows, return the size
        while (size.height * factorMut) > CGFloat.greatestFiniteMagnitude
            || (size.width * factorMut) > CGFloat.greatestFiniteMagnitude {
                factorMut /= 2
        }
        
        let newSize = CGSize(width: size.width * factorMut, height: size.height * factorMut)
        
        return newSize
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        //Camera Updated To Player Position
        cameraNode.position = player.position
        let offsetX = frame.size.width * 0.35
        let offsetY = frame.size.height * 0.30
        
        rightJS.position = CGPoint(x: player.position.x - offsetX ,y: player.position.y - offsetY)
        leftJS.position = CGPoint(x: player.position.x + offsetX ,y: player.position.y - offsetY)

    }
    
}
