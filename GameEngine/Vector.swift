//
//  Vector.swift
//  GameEngine
//
//  Created by Jeremy Jee on 20/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import UIKit

struct Vector {
    var x = CGFloat(0)
    var y = CGFloat(0)
    
    static func emptyVector(vector: Vector) -> Bool {
        return (vector.x == 0) && (vector.y == 0)
    }
    
    static func reverseX(vector: Vector) -> Vector {
        return Vector(x: -vector.x, y: vector.y)
    }
    
    static func + (left: Vector, right: Vector) -> Vector {
        return Vector(x: left.x + right.x, y: left.y + right.y)
    }
    
    static prefix func - (vector: Vector) -> Vector {
        return Vector(x: -vector.x, y: -vector.y)
    }
    
    static func += (left: inout Vector, right: Vector) {
        left = left + right
    }
    
    static func == (left: Vector, right: Vector) -> Bool {
        return (left.x == right.x) && (left.y == right.y)
    }
    static func != (left: Vector, right: Vector) -> Bool {
        return !(left == right)
    }
}
