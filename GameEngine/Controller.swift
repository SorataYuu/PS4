//
//  Controller.swift
//  GameEngine
//
//  Created by Jeremy Jee on 3/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import Foundation
import UIKit

class Controller {
    private (set) var bubbleGrid = BubbleGrid()
    private (set) var projectile: Bubble
    
    private var vc: ViewController
    private var physics: Physics
    
    init(_ viewController: ViewController) {
        vc = viewController
        physics = Physics(bubbleGrid: bubbleGrid)
        projectile = Bubble(bubbleType: .empty)
    }
    
    func newProjectile(){
        projectile = generateRandomBubble()
    }
    
    func animationFinished(indexPath: IndexPath){
        setBubbleType(indexPath: indexPath, bubbleType: projectile.bubbleType)
        vc.projectile!.removeFromSuperview()
        let isRemovingBubbles = removeConnectedBubbles(indexPath: indexPath)
        
        newProjectile()
        vc.createProjectile()
        
        if !isRemovingBubbles {
            vc.enableInteraction(isEnabled: true)
        }
        
    }
    
    func setPhysicsVariables(bubbleSize: CGFloat, bubblePositions: Dictionary<Int, [CGPoint]>, screenWidth: CGFloat, screenHeight: CGFloat) {
        physics.setVisualVariables(bubbleSize: bubbleSize, bubblePositions: bubblePositions, screenWidth: screenWidth, screenHeight: screenHeight)
    }
    
    func setBubbleType(indexPath: IndexPath, bubbleType: BubbleType){
        bubbleGrid.setBubbleType(at: indexPath, bubbleType: bubbleType)
        vc.updateBubbleColor(indexPath: indexPath)
    }
    
    func calculateBubblePath(origin: CGPoint, tapped: CGPoint) -> (CGPath, CGFloat, IndexPath) {
        return physics.calculateBubblePath(origin: origin, tapped: tapped)
    }
    
    func generateRandomBubble() -> Bubble {
        let randomNumber = Int(arc4random_uniform(UInt32(noOfBubbleTypes)))
        let bubbleType = BubbleType(rawValue: randomNumber)
        
        return Bubble(bubbleType: bubbleType!)
    }
    
    func removeConnectedBubbles(indexPath: IndexPath) -> Bool{
        var connectedBubbles = [IndexPath]()
        var visitedQueue = Queue<IndexPath>()
        visitedQueue.enqueue(indexPath)
        
        while !visitedQueue.isEmpty {
            let bubblePath = try! visitedQueue.dequeue()
            let connected = connectedBubblesOfSameType(indexPath: bubblePath)
            
            for path in connected {
                if !connectedBubbles.contains(path) {
                    connectedBubbles.append(path)
                    visitedQueue.enqueue(path)
                }
            }
        }
        
        if connectedBubbles.count >= 3 {
            for path in connectedBubbles {
                setBubbleType(indexPath: path, bubbleType: .empty)
            }
            
            let bubblesToDrop = checkForUnconnectedBubbles()
            vc.dropUnconnected(indexPaths: bubblesToDrop)
            
            return bubblesToDrop.count > 0
        }
        
        return false
    }
    
    func dropCompletes(indexPath: IndexPath) {
        setBubbleType(indexPath: indexPath, bubbleType: .empty)
        vc.enableInteraction(isEnabled: true)
    }
    
    func connectedBubblesOfSameType(indexPath: IndexPath) -> [IndexPath]{
        var surroundingBubbles = [IndexPath]()
        let surroundingIndexes = SurroundingIndexes(at: indexPath)
        if let type = bubbleGrid.bubbleType(at: indexPath) {
            //Check Row Above
            addIfSameType(ofType: type,
                          indexPath: surroundingIndexes.topLeftIndex,
                          surroundingBubbles: &surroundingBubbles)
            addIfSameType(ofType: type,
                          indexPath: surroundingIndexes.topRightIndex,
                          surroundingBubbles: &surroundingBubbles)
            
            //Check Current Row
            addIfSameType(ofType: type,
                          indexPath: surroundingIndexes.leftIndex,
                          surroundingBubbles: &surroundingBubbles)
            addIfSameType(ofType: type,
                          indexPath: surroundingIndexes.rightIndex,
                          surroundingBubbles: &surroundingBubbles)
            
            //Check Bottom Row
            addIfSameType(ofType: type,
                          indexPath: surroundingIndexes.bottomLeftIndex,
                          surroundingBubbles: &surroundingBubbles)
            addIfSameType(ofType: type,
                          indexPath: surroundingIndexes.bottomRightIndex,
                          surroundingBubbles: &surroundingBubbles)
        }
        
        return surroundingBubbles
    }
    
    func addIfSameType(ofType: BubbleType, indexPath: IndexPath, surroundingBubbles: inout [IndexPath]) {
        if let type = bubbleGrid.bubbleType(at: indexPath) {
            if type == ofType {
                surroundingBubbles.append(indexPath)
            }
        }
    }
    
    func checkForUnconnectedBubbles() -> [IndexPath] {
        var connectedBubbles = Dictionary<Int,[Bool]>()
        var indexPath = IndexPath()
        var queue = Queue<IndexPath>()
        
        for rowNo in 0..<bubbleGrid.rows {
            connectedBubbles[rowNo] = [Bool]()
            for bubbleNo in 0..<bubbleGrid.noOfItems(at: rowNo) {
                indexPath = IndexPath(item: bubbleNo, section: rowNo)
                let bubbleType = bubbleGrid.bubbleType(at: indexPath)
                
                if rowNo == 0 {
                    connectedBubbles[rowNo]!.append(bubbleType != .empty)
                    
                    if bubbleType != .empty {
                        queue.enqueue(indexPath)
                    }
                } else {
                    connectedBubbles[rowNo]!.append(false)
                }
            }
        }
        
        while !queue.isEmpty {
            indexPath = try! queue.dequeue()
            checkConnectedBubbles(indexPath: indexPath, connectedBubbles: &connectedBubbles)
        }
        
        var indexes = [IndexPath]()
        
        for rowNo in 0..<bubbleGrid.rows {
            for bubbleNo in 0..<bubbleGrid.noOfItems(at: rowNo) {
                indexPath = IndexPath(item: bubbleNo, section: rowNo)
                let isConnected = connectedBubbles[indexPath.section]![indexPath.item]
                
                if let type = bubbleGrid.bubbleType(at: indexPath) {
                    if !isConnected && type != .empty {
                        bubbleGrid.setBubbleType(at: indexPath, bubbleType: .empty)
                        indexes.append(indexPath)
                    }
                }
            }
        }
        
        return indexes
    }
    
    func checkConnectedBubbles(indexPath: IndexPath, connectedBubbles: inout Dictionary<Int,[Bool]>) {
        let surroundingIndexes = SurroundingIndexes(at: indexPath)
        
        //Check Row Above
        checkIfConnected(indexPath: surroundingIndexes.topLeftIndex,
                         connectedBubbles: &connectedBubbles)
        checkIfConnected(indexPath: surroundingIndexes.topRightIndex,
                         connectedBubbles: &connectedBubbles)
        //Check Same Row
        checkIfConnected(indexPath: surroundingIndexes.leftIndex,
                         connectedBubbles: &connectedBubbles)
        checkIfConnected(indexPath: surroundingIndexes.rightIndex,
                         connectedBubbles: &connectedBubbles)
        //Check Row Below
        checkIfConnected(indexPath: surroundingIndexes.bottomLeftIndex,
                         connectedBubbles: &connectedBubbles)
        checkIfConnected(indexPath: surroundingIndexes.bottomRightIndex,
                         connectedBubbles: &connectedBubbles)
    }
    
    func checkIfConnected(indexPath: IndexPath, connectedBubbles: inout Dictionary<Int,[Bool]>) {
        guard indexPath.section > 0 && indexPath.section < connectedBubbles.keys.count else {
            return
        }
        
        guard indexPath.item > 0 && indexPath.item < connectedBubbles[indexPath.section]!.count else {
            return
        }
        
        let isConnected = connectedBubbles[indexPath.section]![indexPath.item]
        
        if isConnected {
            return
        }
        
        if let type = bubbleGrid.bubbleType(at: indexPath) {
            if type != .empty {
                connectedBubbles[indexPath.section]![indexPath.item] = true
                checkConnectedBubbles(indexPath: indexPath,connectedBubbles: &connectedBubbles)
            }
        }
    }
}
