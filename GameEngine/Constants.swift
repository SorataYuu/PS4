//
//  Constants.swift
//  LevelDesigner
//
//  Created by Jeremy Jee on 31/1/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//
import UIKit

//Set of Global Constants for the Game Settings
class Constants {
    static let reuseIdentifier = "bubbleCell"
    static let oddRowBubbleCount = 11
    static let evenRowBubbleCount = 12
    //Approximated Constant Calculated from Hexagonal Packing
    static let bottomOffsetForRows = CGFloat(-0.26)
    //Used to prevent rounding errors
    static let cellRadiusOffset = CGFloat(-0.001)
    //Set as default
    static let defaultNoOfRows = 20
    //Constant based on trials for an appropriate visual animation speed
    static let speedPerPixel = CGFloat(1000)
    static let speed = CGFloat(20)
    static let noOfBubbleTypes = 4
}
