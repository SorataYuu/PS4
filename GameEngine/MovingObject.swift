//
//  MovingObject.swift
//  GameEngine
//
//  Created by Jeremy Jee on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import UIKit

class MovingObject<T> {
    private (set) var object: T
    var vector: Vector
    var position: CGPoint
    
    init(object: T, vector: Vector, position: CGPoint) {
        self.object = object
        self.vector = vector
        self.position = position
    }
}
