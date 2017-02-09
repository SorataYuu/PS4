//
//  PhysicsEngine.swift
//  GameEngine
//
//  Created by Jeremy Jee on 3/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import UIKit

/**
 Physics, used for Path Calculation and Collision Detection
 
 Variables:
 - bubbleSize: Size of a Bubble
 - screenWidth: Width of the Screen
 - screenHeight: Height of the Screen
 - bubblePositions: Dictionary containing CGPoints of the corresponding bubbles
 - bubbleGrid: Reference to the active BubbleGrid in Controller
 */
class Physics {
    
    private (set) var bubbleSize: CGFloat!
    private (set) var screenWidth: CGFloat!
    private (set) var screenHeight: CGFloat!
    private (set) var bubblePositions: Dictionary<Int, [CGPoint]>!
    private (set) var bubbleGrid: BubbleGrid
    
    //Default Initializer
    /// Parameters:
    ///  - bubbleGrid: Reference to the active BubbleGrid in Controller
    ///  - bubbleSize: Size of a Bubble
    ///  - bubblePositions: Dictionary containing CGPoints of the corresponding bubbles
    ///  - screenWidth: Width of the Screen
    ///  - screenHeight: Height of the Screen
    init(bubbleGrid: BubbleGrid, bubbleSize: CGFloat, bubblePositions: Dictionary<Int, [CGPoint]>, screenWidth: CGFloat, screenHeight: CGFloat) {
        self.bubbleGrid = bubbleGrid
        self.bubbleSize = bubbleSize
        self.bubblePositions = bubblePositions
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
    }
    
    //Calculate the Path of the Projectile
    /// Parameters:
    ///  - origin: The Original Position of the Projectile
    ///  - tapped: The Point where the User Tapped
    /// Returns:
    ///  - CGPath of the Path the Projectile should take
    ///  - CGFloat of the total distance travelled by the Path
    ///  - IndexPath of the final Index where the Projectile ends
    func calculateProjectilePath(origin: CGPoint, tapped: CGPoint) -> (CGPath, CGFloat, IndexPath) {
        let path = CGMutablePath()
        
        var points = [CGPoint]()
        points.append(origin)
        
        var current = origin
        var xyRatio = calculateXYRatio(pointA: current, pointB: tapped)
        
        var closestBubble = IndexPath()
        
        //Calculate the next point along the CGPath
        //If it's a Wall continue finding the next point
        //Until a Bubble or Top Collision
        //Then Find the Closest Bubble Slot and snap to it
        while true {
            let nextPoint = calculateNextPoint(origin: current, xyRatio: xyRatio)
            points.append(nextPoint.0)
            
            if nextPoint.1 == .wall {
                current = nextPoint.0
                xyRatio = -xyRatio
            } else {
                closestBubble = getClosestEmptyBubblePos(point: nextPoint.0)
                points.append(bubblePositions[closestBubble.section]![closestBubble.item])
                break
            }
        }
        
        path.addLines(between: points)
        
        let totalDistance = calculateTotalDistance(points: points, origin: origin)
        
        return (path, totalDistance, closestBubble)
    }
    
    //Calculate the Next Point along the CGPath
    /// Parameters:
    ///  - origin: The Original Position of the Projectile
    ///  - xyRatio: The amount X changes for each unit of Y
    /// Returns:
    ///  - CGPoint of the next Point
    ///  - CollisionType of what kind of Collision it is (Wall, Top, Bubble)
    private func calculateNextPoint(origin: CGPoint, xyRatio: CGFloat) -> (CGPoint, CollisionType) {
        var nextPoint = origin
        nextPoint.x += xyRatio
        nextPoint.y -= 1
        
        var colType = CollisionType.none
        
        //Continue moving up by 1 unit in Y if the point is not a collision
        while true {
            colType = checkPointValidity(point: nextPoint)
            
            guard colType == .none else {
                break
            }
            
            nextPoint.x += xyRatio
            nextPoint.y -= 1
        }
        
        return (nextPoint, colType)
    }
    
    //Calculate the Distance of the CGPath
    /// Parameters:
    ///  - points: The Points along a CGPath
    ///  - origin: The Point where the CGPath Starts
    /// Returns:
    ///  - CGFloat of the total distance travelled by the Path
    private func calculateTotalDistance(points: [CGPoint], origin: CGPoint) -> CGFloat {
        var totalDistance = CGFloat(0)
        var previousPoint = origin
        
        for point in points {
            if point != origin {
                totalDistance += distanceBetweenPoints(pointA: previousPoint, pointB: point)
                previousPoint = point
            }
        }
        
        return totalDistance
    }
    
    //Check if a Point is Valid or it Collides
    /// Parameters:
    ///  - point: The Point to be checked
    /// Returns:
    ///  - CollisionType the type of Collision for the Point
    private func checkPointValidity(point: CGPoint) -> CollisionType {
        let collidedWithWall = checkCollidedWithWall(point: point)
        let collidedWithTop = checkCollidedWithTop(point: point)
        let collidedWithBubble = checkCollidedWithBubble(point: point)
        
        var colType = CollisionType.none
        
        if collidedWithWall {
            colType = .wall
        } else if collidedWithTop {
            colType = .top
        } else if collidedWithBubble {
            colType = .bubble
        }
        
        return colType
    }
    
    //Check if a Point Collides with the Wall
    /// Parameters:
    ///  - point: The Point to be checked
    /// Returns:
    ///  - Bool of whether the point collides with the Wall
    private func checkCollidedWithWall(point: CGPoint) -> Bool {
        let leftWallX = bubbleSize/2
        let rightWallX = screenWidth - bubbleSize/2
        
        if point.x <= leftWallX || point.x >= rightWallX {
            return true
        }
        
        return false
    }
    
    //Check if a Point Collides with the Top
    /// Parameters:
    ///  - point: The Point to be checked
    /// Returns:
    ///  - Bool of whether the point collides with the Top
    private func checkCollidedWithTop(point: CGPoint) -> Bool {
        let topY = bubbleSize/2
        
        if point.y <= topY {
            return true
        }
        
        return false
    }
    
    //Check if a Point Collides with a Bubble
    /// Parameters:
    ///  - point: The Point to be checked
    /// Returns:
    ///  - Bool of whether the point collides with a Bubble
    private func checkCollidedWithBubble(point: CGPoint) -> Bool {
        for rowNo in 0..<bubblePositions.keys.count {
            for bubbleNo in 0..<bubblePositions[rowNo]!.count {
                let bubblePos = bubblePositions[rowNo]![bubbleNo]
                let distance = distanceBetweenPoints(pointA: point, pointB: bubblePos)
                
                let indexPath = IndexPath(item: bubbleNo, section: rowNo)
                let bubbleType = bubbleGrid.bubbleType(at: indexPath)
                
                if distance <= bubbleSize && bubbleType != .empty {
                    return true
                }
            }
        }
        
        return false
    }
    
    //Get the Closest Empty Bubble Slot
    /// Parameters:
    ///  - point: The Point that needs to be closest to
    /// Returns:
    ///  - IndexPath of the Empty Bubble Slot
    private func getClosestEmptyBubblePos(point: CGPoint) -> IndexPath {
        var indexPath = IndexPath()
        
        for rowNo in 0..<bubblePositions.keys.count {
            for bubbleNo in 0..<bubblePositions[rowNo]!.count {
                indexPath = IndexPath(item: bubbleNo, section: rowNo)
                
                guard let bubblePos = getPoint(at: indexPath) else {
                    continue
                }
                
                let distance = distanceBetweenPoints(pointA: point, pointB: bubblePos)
                
                let bubbleType = bubbleGrid.bubbleType(at: indexPath)
                
                if distance <= bubbleSize && bubbleType == .empty {
                    return indexPath
                } else if distance <= bubbleSize {
                    return getClosestSurroundingBubble(at: indexPath, point: point)
                }
            }
        }
        
        assert(false)
        return indexPath
    }
    
    //Get the Closest of the Surrounding Bubbles
    /// Parameters:
    ///  - indexPath: The Bubble to be checked
    ///  - point: The Point to be checked against
    /// Returns:
    ///  - IndexPath of the Closest Bubble Slot
    private func getClosestSurroundingBubble(at indexPath: IndexPath, point: CGPoint) -> IndexPath {
        var closestDistance = CGFloat.greatestFiniteMagnitude
        var closestIndex = IndexPath()
        let si = SurroundingIndexes(at: indexPath)
        
        shorterDistance(from: point, to: si.topLeftIndex,
                        closestDistance: &closestDistance, closestIndex: &closestIndex)
        shorterDistance(from: point, to: si.topRightIndex,
                        closestDistance: &closestDistance, closestIndex: &closestIndex)
        shorterDistance(from: point, to: si.leftIndex,
                        closestDistance: &closestDistance, closestIndex: &closestIndex)
        shorterDistance(from: point, to: si.rightIndex,
                        closestDistance: &closestDistance, closestIndex: &closestIndex)
        shorterDistance(from: point, to: si.bottomLeftIndex,
                        closestDistance: &closestDistance, closestIndex: &closestIndex)
        shorterDistance(from: point, to: si.bottomRightIndex,
                        closestDistance: &closestDistance, closestIndex: &closestIndex)
        
        return closestIndex
    }
    
    //Check if the Bubble is closer than the closest bubble
    /// Parameters:
    ///  - point: The Point to be checked against
    ///  - indexPath: The Bubble to be checked
    ///  - closestDistance (inout): The current closest distance to the point
    ///  - closestIndex (inout): The current closest Bubble to the point
    private func shorterDistance(from point: CGPoint, to indexPath: IndexPath, closestDistance: inout CGFloat, closestIndex: inout IndexPath) {
        guard let pos = getPoint(at: indexPath), let type = bubbleGrid.bubbleType(at: indexPath) else {
            return
        }
        
        let distance = distanceBetweenPoints(pointA: point, pointB: pos)
        
        if distance < closestDistance && type == .empty {
            closestDistance = distance
            closestIndex = indexPath
        }
    }
    
    //Get the Point of a Bubble
    /// Parameters:
    ///  - indexPath: The Bubble to be retrieved
    /// Returns:
    ///  - CGPoint of the bubble's position
    private func getPoint(at indexPath: IndexPath) -> CGPoint? {
        guard let row = bubblePositions[indexPath.section],
            indexPath.item >= 0 && indexPath.item < row.count else {
            return nil
        }
        
        return row[indexPath.item]
    }
    
    //Get the Center Position of a Bubble from its Origin Point
    /// Parameters:
    ///  - originAt: The Origin Position of the Bubble
    /// Returns:
    ///  - CGPoint of the Bubble's Center Position
    private func getCenterPos(originAt: CGPoint) -> CGPoint {
        var center = CGPoint()
        center.x = originAt.x + (bubbleSize/2)
        center.y = originAt.y + (bubbleSize/2)
        
        return center
    }
    
    //Get the XYRatio that is the amount X changes with a unit of Y
    /// Parameters:
    ///  - pointA: Origin Point
    ///  - pointB: Destination Point
    /// Returns:
    ///  - CGFloat of the XYRatio
    private func calculateXYRatio(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        let directionOffsetX = pointB.x - pointA.x
        let directionOffsetY = abs(pointB.y - pointA.y)
        
        return directionOffsetX / directionOffsetY
    }

    //Get the Distance between two points using
    //Pythagoras aSquared + bSquared = cSquared
    /// Parameters:
    ///  - pointA: Origin Point
    ///  - pointB: Destination Point
    /// Returns:
    ///  - CGFloat of the Distance between two points
    private func distanceBetweenPoints(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        let aSquared =  (pointA.x - pointB.x) * (pointA.x - pointB.x)
        let bSquared =  (pointA.y - pointB.y) * (pointA.y - pointB.y)
        
        return sqrt(aSquared + bSquared)
    }
}
