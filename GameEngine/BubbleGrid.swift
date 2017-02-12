//
//  BubbleGrid.swift
//  LevelDesigner
//
//  Created by Jeremy Jee on 26/1/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

/**
 BubbleGrid, a Model contains data about the state of the Game Grid
 
 Variables
 - bubbleGrid: Dictionary that acts as a Grid with Keys as the Row Index 
    and the Values being a List of Bubbles
 */
class BubbleGrid: NSObject, NSCoding {
    private var bubbleGrid: [Int: [Bubble]]
    
    //Default Initialization creates a BubbleGrid of Empty bubbles 
    //with the default rows and columns
    override init() {
        bubbleGrid = [Int: [Bubble]]()
        
        for row in 0...Constants.defaultNoOfRows {
            bubbleGrid[row] = [Bubble]()
            
            for _ in 1...Constants.oddRowBubbleCount {
                bubbleGrid[row]!.append(Bubble(bubbleType: BubbleType.empty))
            }
            
            if row % 2 == 0 {
                bubbleGrid[row]!.append(Bubble(bubbleType: BubbleType.empty))
            }
        }
    }
    
    init(bubbleGrid: BubbleGrid) {
        self.bubbleGrid = bubbleGrid.bubbleGrid
    }
    
    //Dynamic Variable with the number of rows
    /// Returns: 
    ///  - Int of Number of Rows in the Bubble Grid
    var rows: Int {
        return bubbleGrid.keys.count
    }
    
    //Queries Number of items at the Row
    /// Returns:
    ///  - Int of Number of Items in the Row
    func noOfItems(at row: Int) -> Int {
        if let bubbleRow = bubbleGrid[row] {
            return bubbleRow.count
        }
        
        return 0
    }
    
    //Retrieve a bubbleType of a bubble within a BubbleGrid
    /// Parameter:
    ///  - indexPath: Location of the Bubble
    /// Returns:
    ///  - BubbleType Enum of the Bubble exists
    func bubbleType(at indexPath: IndexPath) -> BubbleType? {
        if let bubbleRow = bubbleGrid[indexPath.section] {
            guard indexPath.item >= 0 && indexPath.item < bubbleRow.count else {
                return nil
            }
            
            return bubbleRow[indexPath.item].bubbleType
        }
        
        return nil
    }
    
    //Retrieve the imageName of a Bubble within a BubbleGrid
    /// Parameter:
    ///  - indexPath: Location of the Bubble
    /// Returns:
    ///  - String with the imageName if the Bubble exists
    func bubbleImageName(at indexPath: IndexPath) -> String? {
        if let bubbleRow = bubbleGrid[indexPath.section] {
            guard indexPath.item >= 0 && indexPath.item < bubbleRow.count else {
                return nil
            }
            
            return bubbleRow[indexPath.item].imageName
        }
        
        return nil
    }
    //Set the bubbleType of a Bubble within a BubbleGrid
    /// Parameter:
    ///  - indexPath: Location of the Bubble
    ///  - bubbleType: The new BubbleType
    func setBubbleType(at indexPath: IndexPath, toType bubbleType: BubbleType) {
        if let bubbleRow = bubbleGrid[indexPath.section] {
            guard indexPath.item >= 0 && indexPath.item < bubbleRow.count else {
                return
            }
            
            bubbleGrid[indexPath.section]![indexPath.item].bubbleType = bubbleType
        }
    }
    
    //Helper method for serialization
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.bubbleGrid, forKey: "bubbleGrid")
    }
    
    //Helper method for deserialization
    required init(coder aDecoder: NSCoder) {
        if let bubbleGrid = aDecoder.decodeObject(forKey: "bubbleGrid") as? [Int: [Bubble]] {
            self.bubbleGrid = bubbleGrid
        } else {
            self.bubbleGrid = [Int: [Bubble]]()
        }
    }
}
