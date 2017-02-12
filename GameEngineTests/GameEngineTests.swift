//
//  GameEngineTests.swift
//  GameEngineTests
//
//  Created by Jeremy Jee on 12/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import XCTest
@testable import GameEngine

class GameEngineTests: XCTestCase {
    
    func testInit() {
        let bubbleGrid = BubbleGrid(noOfRows: 5)
        
        assert(bubbleGrid.rows == 5)
        assert(bubbleGrid.noOfItems(at: 0) == Constants.evenRowBubbleCount)
        assert(bubbleGrid.noOfItems(at: 1) == Constants.oddRowBubbleCount)
        
        let indexPath = IndexPath(item: 2, section: 2)
        assert(bubbleGrid.bubbleType(at: indexPath) == .empty)
    }
    
    func testGetSetBubbleType() {
        let bubbleGrid = BubbleGrid(noOfRows: 5)
        
        let indexPath = IndexPath(item: 2, section: 2)
        assert(bubbleGrid.bubbleType(at: indexPath) == .empty)
        
        bubbleGrid.setBubbleType(at: indexPath, toType: .blue)
        
        assert(bubbleGrid.bubbleType(at: indexPath) == .blue)
    }
    
    func testGetImageName() {
        let bubbleGrid = BubbleGrid(noOfRows: 5)
        
        let indexPath = IndexPath(item: 2, section: 2)
        
        assert(bubbleGrid.bubbleImageName(at: indexPath) == "bubble-empty.png")
        
        bubbleGrid.setBubbleType(at: indexPath, toType: .blue)
        
        assert(bubbleGrid.bubbleImageName(at: indexPath) == "bubble-blue.png")
        
        bubbleGrid.setBubbleType(at: indexPath, toType: .red)
        
        assert(bubbleGrid.bubbleImageName(at: indexPath) == "bubble-red.png")
        
        bubbleGrid.setBubbleType(at: indexPath, toType: .green)
        
        assert(bubbleGrid.bubbleImageName(at: indexPath) == "bubble-green.png")
        
        bubbleGrid.setBubbleType(at: indexPath, toType: .orange)
        
        assert(bubbleGrid.bubbleImageName(at: indexPath) == "bubble-orange.png")
        
    }
    
}
