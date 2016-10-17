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
    let rotationOffsetFactorForSpriteImage:CGFloat = -CGFloat.pi / 2
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
    let playerMaxMovementSpeed:CGFloat = CGFloat(2)
    var leftMovementData: [CGFloat]? = nil
    var rightMovementData: [CGFloat]? = nil
    
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
        
        //Joy Sticks (note joystick positions are changed in update method)
        rightJS.position = CGPoint(x: frame.size.width * 0.75 + baseX, y: frame.size.height * 0.1 + baseY)
        addChild(rightJS)
        
        leftJS.position = CGPoint(x: frame.size.width * 0.25 + baseX, y: frame.size.height * 0.1 + baseY)
        addChild(leftJS)
        
        //Actors
        player.position = CGPoint(x: baseX/2, y: baseY/2)
        player.zPosition = 0.1
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
        //let touchPt:CGPoint = CGPoint(x: ftloc.x, y: ftloc.y)
        //player.run(SKAction.move(to: touchPt, duration: 2), withKey: "moving player")
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLoc = touch.location(in: self)
            //let touchID = touch
            
            //get a displacement factor (this is used to convert coordinates to actual screen coordinates in position checks)
            var displace = cameraNode.position //should be in center of screen
            displace.x = displace.x - frame.size.width / 2
            displace.y = displace.y - frame.size.height / 2
            //print("touch x: \(displace.x) LB: \(frame.size.width * 0.33) RB: \(frame.size.width*0.66)")
            
            //CHECK TOUCHES POSITION IN SCREEN
            //if the y is less than 1/4 of the screen down
            if touchLoc.y < frame.size.height * 0.50 + displace.y{
                //if it is in the left 1/3 of screen
                if touchLoc.x <= frame.size.width * 0.33 + displace.x {
                    leftMovementData = leftJS.moveStick(joyStickLocation: leftJS.position, touchLocation: touchLoc)
                }
                //if it is in the right 1/3 of screen
                else if touchLoc.x >= frame.size.width * 0.66 + displace.x {
                    rightMovementData = rightJS.moveStick(joyStickLocation: rightJS.position, touchLocation: touchLoc)
                }
            }
        }
    }
    
    /*
     movement data should be a [CGFloat] of size 2.
     @param movData.0 = the angle of movement (obtained from arc tan - which means certain caveats)
     @param movData.1 = the strength of the movement.
    */
    func updatePlayerPosition(JoystickData movData: [CGFloat]){
        //shadow param movData with local var so that it can be mutated
        var movData = movData
        
        //return if improper parameter sent
        if movData.count < 2 {
            print("improper array sent to updatePlayerPosition, had less than 2 elements")
            return
        }
        
        //get current player's position (for displacement)
        let playerCurrentPosition = player.position
        
        //calculate the displacement based on the angle (assume speed is 1)
        var xChange = playerMaxMovementSpeed * cos(movData[0])
        var yChange = playerMaxMovementSpeed * sin(movData[0])

        //scale the movement based on the strength of pushed joystick
        xChange *= movData[1]
        yChange *= movData[1]
        

        //debug trance
        //print("x: \(xChange) y: \(yChange)")
        //print("updatePlayerPosition reporting angle \(movData[0])")

        
        //correct for quadrants where x < 0
        if movData[0] > (CGFloat.pi / 2) || movData[0] < -(CGFloat.pi / 2) {
           // yChange *= -1
        }
        
        //update the player's movement
        player.position = CGPoint(x: playerCurrentPosition.x + xChange, y: playerCurrentPosition.y + yChange)
    }
    
    /*
     joystick data should be a [CGFloat] of size 2.
     @param movData.0 = the angle of movement (obtained from arc tan - which means certain caveats)
     @param movData.1 = the strength of the movement.
     */
    func updatePlayerRotation(JoystickData joyData: [CGFloat]){
        player.zRotation = joyData[0] + rotationOffsetFactorForSpriteImage
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
    
    func clearJoyStickData(){
        if !rightJS.joyStickActive(){
            rightMovementData = nil
        }
        if !leftJS.joyStickActive(){
            leftMovementData = nil
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        //Handle Player Updating Based On Joystick Data
        if rightMovementData != nil && rightJS.joyStickActive(){
            updatePlayerRotation(JoystickData: rightMovementData!)
        }
        if leftMovementData != nil && leftJS.joyStickActive(){
            updatePlayerPosition(JoystickData: leftMovementData!)
        }
        clearJoyStickData()

        
        //Camera Updated To Player Position
        cameraNode.position = player.position
        let offsetX = frame.size.width * 0.35
        let offsetY = frame.size.height * 0.30
        
        rightJS.position = CGPoint(x: player.position.x + offsetX ,y: player.position.y - offsetY)
        leftJS.position = CGPoint(x: player.position.x - offsetX ,y: player.position.y - offsetY)
    }
    
}
