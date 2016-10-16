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
    static let joystickMovementLimitingFactor = CGFloat(0.5) //multiplied by maximum joystick movement
    
    var base : SKSpriteNode
    var joyStick : SKSpriteNode
    var lastLocation:CGPoint?
    var timeLastUpdated = DispatchTime.now()
    
    override init(){
        //init variables so super.init() may be called
        base = SKSpriteNode(imageNamed: "ThrottleBaseAlpha.png")
        joyStick = SKSpriteNode(imageNamed: "ThrottleAlpha.png")
        super.init()
        
        //set up the base
        addChild(base)
        
        //set up the joy stick
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
    func moveStick(joyStickLocation jsLoc:CGPoint, touchLocation tchLoc:CGPoint) -> [CGFloat] {
        //Find the angle from the point zero and update
        var vector = CGVector(dx: tchLoc.x - jsLoc.x, dy: tchLoc.y - jsLoc.y)
        
        //Get the angle that the throttle is pointig
        let angle = atan(vector.dy / vector.dx)
        
        //Check if throttle is going to move out of the base + also get fractional push value
        let vectorAndStrengthTuple = getVectorAndStrengthFraction(currentVector: vector, calculatedAngle: angle)
        
        //The correct movement vector is at position 0 in the tuple
        vector = vectorAndStrengthTuple.0
        
        //the correct strength value is at position 1 in the tuple
        let strengthFactor = vectorAndStrengthTuple.1
        
        //Update the throttle stick
        joyStick.position = CGPoint(x: vector.dx, y: vector.dy)
        
        return [angle, strengthFactor]
    }
    
    func getVectorAndStrengthFraction(currentVector vector:CGVector, calculatedAngle angle:CGFloat) -> (CGVector, CGFloat) {
        //get size of the current throttle base
        let size = base.size
        
        //joy stick may not be pefect square, so get the smaller of width/height
        var maxDist = size.width < size.height ? (size.width / 2) : (size.height / 2)
        
        //apply joystick limited factor
        maxDist *= EEJoyStick.joystickMovementLimitingFactor

        //need to return a smaller vector, joystick is going to leave base if either component is passed maxDist
        if maxDist < abs(vector.dx) || maxDist < abs(vector.dy){
            //Use maxDistance in pythagorean's therom to find out appropriate x and y values
            var newX = maxDist * cos(angle)
            var newY = maxDist * sin(angle)
            
            //sign correct for quadrans where x < 0
            if vector.dx < 0 {
                newX *= -1
                newY *= -1
            }
            
            //return the new vector, and a maximum strength value of 1
            return (CGVector(dx: newX, dy: newY), CGFloat(1.0))
        } else {
            //current vector is okay :)
            //calculate actual movement strength fractional value (actual distance / max distance)
            let movementStrengthFractionalValue = sqrt(pow(vector.dx, 2) + pow(vector.dy, 2)) / maxDist;
            return (vector, movementStrengthFractionalValue)
        }
        
    }
    
    //update the last point touched for updating joystick calculations
    func newPoint(newTouchPnt newPoint:CGPoint){
        lastLocation = newPoint;
    }
    
    func joystickUpdateMethod(){
        //remove last point touched if time limit is up
        if lastLocation != nil {
            //validateLastPointShouldBeActive()
        }
        
    }
    
    func validateLastPointShouldBeActive(){
        //get interval in nanoseconds
        let interval = timeLastUpdated.uptimeNanoseconds - DispatchTime.now().uptimeNanoseconds
        
        
        if interval * (1 / NSEC_PER_MSEC) > 500 {
            lastLocation = nil
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
