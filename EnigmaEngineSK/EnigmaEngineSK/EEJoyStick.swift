//
//  EEJoyStick.swift
//  EnigmaEngineSK
//
//  Created by Matt Stone on 10/14/16.
//  Copyright © 2016 Matt Stone. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class EEJoyStick: SKNode {
    //joystick maximum displacement is to put center at rim; this factor is to reduce how much joystick can move
    private static let joystickMovementLimitingFactor = CGFloat(0.5) //multiplied by maximum joystick movement
    private static let DEFAULT_POINT = CGPoint(x: 0, y: 0)
    private static let maximumNanosecondDelay:UInt64 = 5_000_000
    
    
    private var base : SKSpriteNode
    private var joyStick : SKSpriteNode
    private var lastLocation:CGPoint?
    private var timeLastUpdated = DispatchTime.now()
    private var lastTouch:UITouch? = nil
    
    
    override init(){
        //init variables so super.init() may be called
        base = SKSpriteNode(imageNamed: "ThrottleBaseAlpha.png")
        joyStick = SKSpriteNode(imageNamed: "ThrottleAlpha.png")
        super.init()
        
        //set up the base
        base.zPosition = CGFloat(1.0)  //makes sure that base in rendered in background
        addChild(base)
        
        //set up the joy stick
        joyStick.zPosition = CGFloat(1.5)
        addChild(joyStick)
        
    }
    
    /*
     Method that moves the joy stick. It returns the angle the joystick is pushed and relative amount the joy stick is pushed.
     the return is in teh format [angle, movementAchieved/TotalMovement]
     @param jsLoc - the location of the joyStick
     @param tchLoc - the location of the current moved touch
     @return [0] = angle in radians of the joystick
     @return [1] = fraction representing joySticks' displacement / maximum displacement possible
    */
    func moveStick(joyStickLocation jsLoc:CGPoint, touchLocation tchLoc:CGPoint, touch: UITouch) -> [CGFloat] {
        //Find the angle from the point zero and update (vector represents where joystick will be placed)
        var vector = CGVector(dx: tchLoc.x - jsLoc.x, dy: tchLoc.y - jsLoc.y)
        
        //update time last moved
        timeLastUpdated = DispatchTime.now()
        
        //update touch (used in joystick time out)
        lastTouch = touch
        
        //Get the angle that the throttle is pointig
        var angle = atan(vector.dy / vector.dx)
        
        //Check if throttle is going to move out of the base + also get fractional push value
        let vectorAndStrengthAndAngleTriple = getVectorAndStrengthFractionAndAngle(currentVector: vector, calculatedAngle: angle)
        
        //The correct movement vector is at position 0 in the tuple
        vector = vectorAndStrengthAndAngleTriple.0
        
        //the correct strength value is at position 1 in the tuple
        let strengthFactor = vectorAndStrengthAndAngleTriple.1
        
        //the corrected angle for x < 0 is in spot 2
        angle = vectorAndStrengthAndAngleTriple.2
                
        //Update the throttle stick
        joyStick.position = CGPoint(x: vector.dx, y: vector.dy)
        
        return [angle, strengthFactor]
    }
    
    func getVectorAndStrengthFractionAndAngle(currentVector vector:CGVector, calculatedAngle angle:CGFloat) -> (CGVector, CGFloat, CGFloat) {
        //Shadow angle with a new variable
        var angle = angle
        
        //get size of the current throttle base
        let size = base.size
        
        //joy stick may not be pefect square, so get the smaller of width/height
        var maxDist = size.width < size.height ? (size.width / 2) : (size.height / 2)
        
        //apply joystick movement limitation factor
        maxDist *= EEJoyStick.joystickMovementLimitingFactor

        
        //need to return a smaller vector, joystick is going to leave base if either component is passed maxDist
        if maxDist < abs(vector.dx) || maxDist < abs(vector.dy){
            //Use maxDistance in pythagorean's therom to find out appropriate x and y values
            var newX = maxDist * cos(angle)
            var newY = maxDist * sin(angle)
            
            //sign correct for quadrans where x < 0
            if vector.dx < 0 {
                // fixing sign
                newX *= -1
                newY *= -1

                //fix angle by adding/subtracting pi/2 
                //NOTE: angle must be calculated here since newX/newY depend on angle before transformation
                if angle < 0 { //positive angle
                    angle = CGFloat.pi  + angle
                } else { //negative angle
                    angle = -CGFloat.pi + angle
                }
            }
            
            //return the new vector, and a maximum strength value of 1
            return (CGVector(dx: newX, dy: newY), CGFloat(1.0), angle)
        } else {
            //current vector is okay :)
            
            //fix current angle
            if vector.dx < 0 {
                //fix angle by adding/subtracting pi/2
                if angle > 0 { //positive angle
                    angle = CGFloat.pi  + angle
                } else { //negative angle
                    angle = -CGFloat.pi + angle
                }
            }
            
            //calculate actual movement strength fractional value (actual distance / max distance)
            let movementStrengthFractionalValue = sqrt(pow(vector.dx, 2) + pow(vector.dy, 2)) / maxDist;
            return (vector, movementStrengthFractionalValue, angle)
        }
        
    }
    
    //update the last point touched for updating joystick calculations
    func newPoint(newTouchPnt newPoint:CGPoint){
        lastLocation = newPoint;
    }
    
    func joystickUpdateMethod(){
        validateLastPointShouldBeActive()
        
    }
    
    func validateLastPointShouldBeActive(){
        //get interval in nanoseconds
        let timeNow = DispatchTime.now().uptimeNanoseconds
        let interval = timeNow - timeLastUpdated.uptimeNanoseconds
    
        //check if the joystick hasn't been touched for longer than the tolerated amount of time
        if interval > EEJoyStick.maximumNanosecondDelay && lastTouch == nil{
            lastLocation = nil
            joyStick.position = EEJoyStick.DEFAULT_POINT
            //joyStick.run(SKAction.move(to: EEJoyStick.DEFAULT_POINT, duration: 0.02))
        }
    }

    func joyStickActive() -> Bool {
        if !joyStick.position.equalTo(CGPoint(x: 0, y: 0)){
            return true
        }
        return false
    }
    
    func signalTouchEnded(touch:UITouch){
        if(lastTouch == touch){
            lastTouch = nil
        }
    }
    
    //MARK: encoder related methods
    required init?(coder aDecoder: NSCoder) {
        base = aDecoder.decodeObject(forKey: "base") as! SKSpriteNode
        joyStick = aDecoder.decodeObject(forKey: "joyStick") as! SKSpriteNode
        super.init(coder: aDecoder)
    }
    
    override func encode(with aCoder: NSCoder){
        aCoder.encode(base, forKey: "base")
        aCoder.encode(joyStick, forKey: "joyStick")
    }
    
    
    
}
