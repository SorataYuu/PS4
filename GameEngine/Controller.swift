//
//  Controller.swift
//  GameEngine
//
//  Created by Jeremy Jee on 3/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import UIKit

/**
 Controller used to interface with the View and the Model, 
 as well as perform logic functions
 
 Variables:
 - bubbleGrid: The Active BubbleGrid
 - projectile: Model of the Projectile
 - viewController: Reference to the ViewController
 - physics: Reference to the Physics Engine
 */
class Controller {
    private var bubbleGrid: BubbleGrid
    private (set) var projectile = Bubble(bubbleType: .empty)
    
    private var viewController: ViewController
    private var physics: Physics!
    
    //Default Initializer
    /// Parameters:
    ///  - viewController: Reference to the ViewController
    init(_ viewController: ViewController, bubbleSize: CGFloat, viewHeight: CGFloat) {
        self.viewController = viewController
        
        let noOfRows = Int(ceil(viewHeight / bubbleSize))
        
        bubbleGrid = BubbleGrid(noOfRows: noOfRows)
        
        createNewProjectile()
    }
    
    //Set Up the Physics Engine
    /// Parameters:
    ///  - bubbleSize: Size of a Bubble
    ///  - bubblePositions: Dictionary containing CGPoints of the corresponding bubbles
    ///  - screenWidth: Width of the Screen
    ///  - screenHeight: Height of the Screen
    func setupPhysics(bubbleSize: CGFloat, bubblePositions: [Int: [CGPoint]],
                      screenWidth: CGFloat,screenHeight: CGFloat) {
        physics = Physics(bubbleGrid: bubbleGrid, bubbleSize: bubbleSize,
                          bubblePositions: bubblePositions,
                          screenWidth: screenWidth, screenHeight: screenHeight)
    }
    
    //Create a New Projectile
    private func createNewProjectile() {
        projectile = generateRandomBubble()
        viewController.createProjectile(projectile: projectile)
    }
    
    //Set the Bubble Type and Update the Colour on the View
    /// Parameters:
    ///  - path: Bubble to be Changed
    ///  - bubbleType: Type to be Changed to
    private func setBubbleTypeAndUpdateColor(at path: IndexPath, toType bubbleType: BubbleType) {
        bubbleGrid.setBubbleType(at: path, toType: bubbleType)
        viewController.updateBubbleColor(at: path)
    }
    
    //Get Bubble Type at Index Path
    /// Parameters:
    ///  - path: Bubble to whose type to get
    /// Returns:
    ///  - BubbleType of the Bubble
    func getBubbleType(at indexPath: IndexPath) -> BubbleType? {
        return bubbleGrid.bubbleType(at: indexPath)
    }
    
    //Get Image Name at Index Path
    /// Parameters:
    ///  - path: Bubble to whose image name to get
    /// Returns:
    ///  - String of the Image Name of the Bubble
    func getBubbleImageName(at indexPath: IndexPath) -> String? {
        return bubbleGrid.bubbleImageName(at: indexPath)
    }
    
    //Get Number of Rows
    /// Returns:
    ///  - Int of the Number of Rows in the Grid
    func getNoOfRows() -> Int {
        return bubbleGrid.rows
    }
    
    //Get Number of Items at a Row
    /// Parameters:
    ///  - row: Row whose No of Items to Get
    /// Returns:
    ///  - Int of the No of Items at that row
    func getNoOfItems(at row: Int) -> Int {
        return bubbleGrid.noOfItems(at: row)
    }
    
    //Calls the Physics Engine to calculate the Path of the Projectile
    /// Parameters:
    ///  - origin: The Original Position of the Projectile
    ///  - tapped: The Point where the User Tapped
    /// Returns:
    ///  - CGPath of the Path the Projectile should take
    ///  - CGFloat of the total distance travelled by the Path
    ///  - IndexPath of the final Index where the Projectile ends
    func calculateProjectilePath(origin: CGPoint, tapped: CGPoint) -> (CGPath, CGFloat, IndexPath?) {
        return physics.calculateProjectilePath(origin: origin, tapped: tapped)
    }
    
    //Called when the Shooting Animation of the Projectile Finishes
    /// Parameters:
    ///  - path: The Bubble Slot that the Projectile ends in
    func shootFinished(destination path: IndexPath) {
        setBubbleTypeAndUpdateColor(at: path, toType: projectile.bubbleType)
        
        viewController.projectile.removeFromSuperview()
        
        let isRemovingBubbles = removeConnectedBubblesOfSameType(at: path)
        
        if !isRemovingBubbles {
            viewController.enableInteraction(isEnabled: true)
        }
        
        createNewProjectile()
    }
    
    //Called when the Shrink Animation of the Destroyed Bubble Finishes
    /// Parameters:
    ///  - path: The Bubble that shrunk
    func shrinkFinished(at path: IndexPath) {
        viewController.updateBubbleColor(at: path)
    }
    
    //Called when the Drop Animation of the Unconnected Bubble Finishes
    /// Parameters:
    ///  - path: The Bubble that shrunk
    func dropFinished(at path: IndexPath) {
        setBubbleTypeAndUpdateColor(at: path, toType: .empty)
        viewController.enableInteraction(isEnabled: true)
    }
    
    //Remove Connected Bubbles that are the same type
    /// Parameters:
    ///  - path: The Bubble to be checked
    /// Returns:
    ///  - Bool of whether Unconnected Bubbles were being dropped
    private func removeConnectedBubblesOfSameType(at path: IndexPath) -> Bool {
        let connectedBubbles = getConnectedBubblesOfSameType(at: path)
        
        //Only Remove when there are 3 or more
        if connectedBubbles.count >= 3 {
            for bubblePath in connectedBubbles {
                bubbleGrid.setBubbleType(at: bubblePath, toType: .empty)
            }
            
            //Call the Shrinking Bubble Animation
            viewController.shrinkBubbles(at: connectedBubbles)
            
            let bubblesToDrop = getUnconnectedBubbles()
            viewController.dropUnconnected(at: bubblesToDrop)
            
            return !bubblesToDrop.isEmpty
        }
        
        return false
    }
    
    //Get a List of Connected Bubbles that are of the Same Type
    /// Parameters:
    ///  - path: The Bubble to be checked against
    private func getConnectedBubblesOfSameType(at path: IndexPath) -> [IndexPath] {
        var connectedBubbles = [IndexPath]()
        var visitedQueue = Queue<IndexPath>()
        visitedQueue.enqueue(path)
        
        while !visitedQueue.isEmpty {
            let bubblePath = try! visitedQueue.dequeue()
            let connected = surroundingBubblesOfSameType(at: bubblePath)
            
            for path in connected {
                if !connectedBubbles.contains(path) {
                    connectedBubbles.append(path)
                    visitedQueue.enqueue(path)
                }
            }
        }
        
        return connectedBubbles
    }
    
    //Get a List of Surrounding Bubbles that are of the same type
    /// Parameters:
    ///  - path: The Bubble to be checked against
    /// Returns:
    ///  - [IndexPath] of surrounding Bubbles that have the same type
    private func surroundingBubblesOfSameType(at path: IndexPath) -> [IndexPath] {
        var surroundingBubbles = [IndexPath]()
        let surroundingIndexes = SurroundingIndexes(at: path)
        
        if let type = bubbleGrid.bubbleType(at: path) {
            //Check Row Above
            addIfSameType(ofType: type,
                          at: surroundingIndexes.topLeftIndex,
                          surroundingBubbles: &surroundingBubbles)
            addIfSameType(ofType: type,
                          at: surroundingIndexes.topRightIndex,
                          surroundingBubbles: &surroundingBubbles)
            
            //Check Current Row
            addIfSameType(ofType: type,
                          at: surroundingIndexes.leftIndex,
                          surroundingBubbles: &surroundingBubbles)
            addIfSameType(ofType: type,
                          at: surroundingIndexes.rightIndex,
                          surroundingBubbles: &surroundingBubbles)
            
            //Check Bottom Row
            addIfSameType(ofType: type,
                          at: surroundingIndexes.bottomLeftIndex,
                          surroundingBubbles: &surroundingBubbles)
            addIfSameType(ofType: type,
                          at: surroundingIndexes.bottomRightIndex,
                          surroundingBubbles: &surroundingBubbles)
        }
        
        return surroundingBubbles
    }
    
    //Add the bubble into the surrounding Bubbles List if it is the same type
    /// Parameters:
    ///  - ofType: The Bubble Type that it needs to be
    ///  - path: The Bubble to be checked
    ///  - surroundingBubbles (inout): The list of surrounding Bubbles of the same type
    private func addIfSameType(ofType: BubbleType, at path: IndexPath,
                               surroundingBubbles: inout [IndexPath]) {
        if let type = bubbleGrid.bubbleType(at: path) {
            if type == ofType {
                surroundingBubbles.append(path)
            }
        }
    }
    
    //Get a List of Unconnected Bubbles to the Top of the Screen
    /// Returns:
    ///  - [IndexPath] of Unconnected Bubbles
    private func getUnconnectedBubbles() -> [IndexPath] {
        let connectedBubbles = getConnectedBubbles()
        
        var unconnectedBubbles = [IndexPath]()
        
        for rowNo in 0..<bubbleGrid.rows {
            for bubbleNo in 0..<bubbleGrid.noOfItems(at: rowNo) {
                let path = IndexPath(item: bubbleNo, section: rowNo)
                
                guard let connectedRow = connectedBubbles[path.section],
                    let type = bubbleGrid.bubbleType(at: path) else {
                        continue
                }
                
                if !connectedRow[path.item] && type != .empty {
                    bubbleGrid.setBubbleType(at: path, toType: .empty)
                    unconnectedBubbles.append(path)
                }
            }
        }
        
        return unconnectedBubbles
    }
    
    //Get a List of Bubbles that are Connected to the Top of the Screen
    /// Returns:
    ///  - Dictionary<Int, [Bool]> of a Matrix of whether Bubbles are connected or not
    private func getConnectedBubbles() -> [Int: [Bool]] {
        let connectedMatrix = initializeConnectedMatrix()
        var connectedBubbles = connectedMatrix.0
        var queue = connectedMatrix.1
        
        while !queue.isEmpty {
            let path = try! queue.dequeue()
            checkSurroudingBubblesIfEmpty(at: path, connectedBubbles: &connectedBubbles)
        }

        return connectedBubbles
    }
    
    //Initialize the Connected Matrix with "false" values by default
    //Initialize the first row of the Matrix with "true" if they are not empty
    /// Returns:
    ///  - Dictionary<Int, [Bool]> of a Matrix of whether Bubbles are connected or not
    ///  - Queue of Nodes that are Connected to Parse through
    private func initializeConnectedMatrix() -> ([Int: [Bool]], Queue<IndexPath>) {
        var connectedBubbles = [Int: [Bool]]()
        var queue = Queue<IndexPath>()
        
        for rowNo in 0..<bubbleGrid.rows {
            connectedBubbles[rowNo] = [Bool]()
            
            for bubbleNo in 0..<bubbleGrid.noOfItems(at: rowNo) {
                let path = IndexPath(item: bubbleNo, section: rowNo)
                let bubbleType = bubbleGrid.bubbleType(at: path)
                
                if rowNo == 0 && bubbleType != .empty {
                    queue.enqueue(path)
                    connectedBubbles[rowNo]!.append(true)
                } else {
                    connectedBubbles[rowNo]!.append(false)
                }
            }
        }
        
        return (connectedBubbles, queue)
    }
    
    //Check if Bubbles that are Surrounding it are Empty or Not
    /// Parameters:
    ///  - path: Path whose surrounding Bubbles have to be checked
    ///  - connectedBubbles (inout): Matrix of Connected Bubbles
    private func checkSurroudingBubblesIfEmpty(at path: IndexPath,
                                               connectedBubbles: inout [Int:[Bool]]) {
        let surroundingIndexes = SurroundingIndexes(at: path)
        
        //Check Row Above
        checkBubbleIfEmpty(at: surroundingIndexes.topLeftIndex,
                         connectedBubbles: &connectedBubbles)
        checkBubbleIfEmpty(at: surroundingIndexes.topRightIndex,
                         connectedBubbles: &connectedBubbles)
        //Check Same Row
        checkBubbleIfEmpty(at: surroundingIndexes.leftIndex,
                         connectedBubbles: &connectedBubbles)
        checkBubbleIfEmpty(at: surroundingIndexes.rightIndex,
                         connectedBubbles: &connectedBubbles)
        //Check Row Below
        checkBubbleIfEmpty(at: surroundingIndexes.bottomLeftIndex,
                         connectedBubbles: &connectedBubbles)
        checkBubbleIfEmpty(at: surroundingIndexes.bottomRightIndex,
                         connectedBubbles: &connectedBubbles)
    }
    
    //Check if the Bubble is empty then update the Matrix
    /// Parameters:
    ///  - path: Check if the Bubble at the Position is Empty
    ///  - connectedBubbles (inout): Matrix of Connected Bubbles
    private func checkBubbleIfEmpty(at path: IndexPath,
                                    connectedBubbles: inout [Int: [Bool]]) {
        guard let connectedRow = connectedBubbles[path.section],
            let type = bubbleGrid.bubbleType(at: path) else {
            return
        }
        
        if connectedRow[path.item] == true {
            return
        }
        
        if type != .empty {
            connectedBubbles[path.section]![path.item] = true
            checkSurroudingBubblesIfEmpty(at: path, connectedBubbles: &connectedBubbles)
        }
    }
    
    //Generate a Random Bubble
    /// Returns:
    ///  - Bubble that was randomly generated
    private func generateRandomBubble() -> Bubble {
        let randomNumber = Int(arc4random_uniform(UInt32(Constants.noOfBubbleTypes)))
        let bubbleType = BubbleType(rawValue: randomNumber)
        
        return Bubble(bubbleType: bubbleType!)
    }
}
