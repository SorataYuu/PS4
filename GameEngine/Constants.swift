//
//  Constants.swift
//  LevelDesigner
//
//  Created by Jeremy Jee on 31/1/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation
import UIKit

/**
 Constants File containing Global Level Settings and Enums
 */

//Set of Global Constants for the Game Settings
let reuseIdentifier = "bubbleCell"
let oddRowBubbleCount = 11
let evenRowBubbleCount = 12
let bottomOffsetForRows = CGFloat(-0.26)
let cellRadiusOffset = CGFloat(-0.001)
let defaultNoOfRows = 9
let frameInterval = 1
let speedPerPixel = CGFloat(1000)
let plistFileName = "Levels.plist"
let noOfBubbleTypes = 4

//Enum of the different BubbleTypes with the imageName as raw value
enum BubbleType: Int {
    case blue = 0
    
    case red = 1
    
    case green = 2
    
    case orange = 3
    
    case empty = 4
}

//Enum of the different states of the Palette with the Palette Tag as raw value
enum PaletteState: Int {
    case none = 0
    
    case blue = 1
    
    case red = 2
    
    case green = 3
    
    case orange = 4
    
    case erase = 5
}

//Enum of the different buttons on the Palette with the Button Tag as raw value
enum PaletteButton: Int {
    case start = 1
    
    case save = 2
    
    case delete = 3
    
    case load = 4
    
    case reset = 5
}

enum CollisionType {
    case wall
    
    case top
    
    case bubble
    
    case none
}
