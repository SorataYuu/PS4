//
//  Bubble.swift
//  LevelDesigner
//
//  Created by Jeremy Jee on 24/1/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

/**
 Bubble, a Model contains the data about each individual bubble
 
 Variables
    - bubbleType: Type of Bubble
    - imageName: Name of the Image File for the Bubble
 */
@objc class Bubble: NSObject, NSCoding {
    var bubbleType: BubbleType
    
    override init(){
        bubbleType = .empty
    }
    
    init(bubbleType: BubbleType){
        self.bubbleType = bubbleType
    }
    
    //Dynamic Variable that returns the image name based on the BubbleType
    //Enum that contains the image name String as its raw value
    var imageName: String {
        switch bubbleType {
        case .blue:
            return "bubble-blue.png"
            
        case .red:
            return "bubble-red.png"
            
        case .green:
            return "bubble-green.png"
            
        case .orange:
            return "bubble-orange.png"
            
        case .empty:
            return "bubble-empty.png"
        }
    }
    
    //Helper method for serialization
    func encode(with aCoder: NSCoder) {
        aCoder.encode(bubbleType.rawValue, forKey: "bubble")
    }
    
    //Helper method for deserialization
    required init(coder aDecoder: NSCoder) {
        if let bubbleType = aDecoder.decodeObject(forKey: "bubble") as? BubbleType.RawValue {
            self.bubbleType = BubbleType(rawValue: bubbleType)!
        } else {
            self.bubbleType = BubbleType.empty
        }
    }
}
