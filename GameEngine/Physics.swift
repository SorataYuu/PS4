//
//  PhysicsEngine.swift
//  GameEngine
//
//  Created by Jeremy Jee on 3/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import Foundation
import UIKit

class Physics {
    
    private (set) var bubbleSize: CGFloat!
    private (set) var screenWidth: CGFloat!
    private (set) var screenHeight: CGFloat!
    private (set) var bubblePositions: Dictionary<Int, [CGPoint]>!
    private (set) var bubbleGrid: BubbleGrid
    
    init(bubbleGrid: BubbleGrid){
        self.bubbleGrid = bubbleGrid
    }
    
    func setVisualVariables(bubbleSize: CGFloat, bubblePositions: Dictionary<Int, [CGPoint]>, screenWidth: CGFloat, screenHeight: CGFloat) {
        self.bubbleSize = bubbleSize
        self.bubblePositions = bubblePositions
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
    }
    
    private func createCollisionRectangle(centerPos: CGPoint) -> CGRect {
        var newOrigin = CGPoint()
        newOrigin.x = centerPos.x - (bubbleSize / 2)
        newOrigin.y = centerPos.y - (bubbleSize / 2)
        
        let newSize = CGSize(width: bubbleSize, height: bubbleSize)
        
        return CGRect(origin: newOrigin, size: newSize)
    }
    
    func calculateBubblePath(origin: CGPoint, tapped: CGPoint) -> (CGPath, CGFloat, IndexPath) {
        let path = CGMutablePath()
        
        var points = [CGPoint]()
        points.append(origin)
        
        var current = origin
        var xyRatio = calculateXYRatio(pointA: current, pointB: tapped)
        
        var closestBubble = IndexPath()
        
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
    
    func calculateTotalDistance(points: [CGPoint], origin: CGPoint) -> CGFloat {
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
    
    func calculateNextPoint(origin: CGPoint, xyRatio: CGFloat) -> (CGPoint, CollisionType) {
        var nextPoint = origin
        nextPoint.x += xyRatio
        nextPoint.y -= 1
        
        var colType = CollisionType.none
        
        while true {
            colType = checkPointValidity(point: nextPoint)
            
            if colType == .none {
                nextPoint.x += xyRatio
                nextPoint.y -= 1
            } else {
                break
            }
        }
        
        return (nextPoint, colType)
    }
    
    func checkPointValidity(point: CGPoint) -> CollisionType {
        let collidedWithWall = checkCollidedWithWall(point: point)
        let collidedWithTop = checkCollidedWithTop(point: point)
        let collidedWithBubble = checkCollidedWithBubble(point: point)
        var colType = CollisionType.none
        
        if collidedWithWall == true {
            colType = .wall
        } else if collidedWithTop == true {
            colType = .top
        } else if collidedWithBubble == true {
            colType = .bubble
        }
        
        return colType
    }
    
    func checkCollidedWithWall(point: CGPoint) -> Bool {
        let leftWallX = bubbleSize/2
        let rightWallX = screenWidth - bubbleSize/2
        
        if point.x <= leftWallX || point.x >= rightWallX {
            return true
        }
        
        return false
    }
    
    func checkCollidedWithTop(point: CGPoint) -> Bool {
        let topY = bubbleSize/2
        
        if point.y <= topY {
            return true
        }
        
        return false
    }
    
    func checkCollidedWithBubble(point: CGPoint) -> Bool {
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
    
    func getClosestEmptyBubblePos(point: CGPoint) -> IndexPath {
        var indexPath = IndexPath()
        
        for rowNo in 0..<bubblePositions.keys.count {
            for bubbleNo in 0..<bubblePositions[rowNo]!.count {
                indexPath = IndexPath(item: bubbleNo, section: rowNo)
                
                guard let bubblePos = getPos(at: indexPath) else {
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
    
    func getClosestSurroundingBubble(at indexPath: IndexPath, point: CGPoint) -> IndexPath {
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
    
    private func shorterDistance(from point: CGPoint, to index: IndexPath, closestDistance: inout CGFloat, closestIndex: inout IndexPath) {
        if let pos = getPos(at: index) {
            let distance = distanceBetweenPoints(pointA: point, pointB: pos)
            if distance < closestDistance {
                closestDistance = distance
                closestIndex = index
            }
        }
    }
    
    private func getPos(at indexPath: IndexPath) -> CGPoint? {
        if let rowNo = bubblePositions[indexPath.section] {
            return rowNo[indexPath.item]
        }
        
        return nil
    }
    
    private func getCenterPos(originAt: CGPoint) -> CGPoint{
        var center = CGPoint()
        center.x = originAt.x + (bubbleSize/2)
        center.y = originAt.y + (bubbleSize/2)
        
        return center
    }
    
    private func calculateXYRatio(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        let directionOffsetX = pointB.x - pointA.x
        let directionOffsetY = abs(pointB.y - pointA.y)
        
        return directionOffsetX / directionOffsetY
    }

    
    //Pythagoras aSquared + bSquared = cSquared
    private func distanceBetweenPoints(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
        let aSquared =  (pointA.x - pointB.x) * (pointA.x - pointB.x)
        let bSquared =  (pointA.y - pointB.y) * (pointA.y - pointB.y)
        
        return abs(sqrt(aSquared + bSquared))
    }
}
