//
//  SurroundingIndexes.swift
//  GameEngine
//
//  Created by Jeremy Jee on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import Foundation

/**
 SurroundingIndexes, Struct to easily access Indexes of the Surrounding Bubbles
 
 Variables:
 - index: IndexPath of a Bubble
 */
struct SurroundingIndexes {
    private (set) var index: IndexPath
    
    //Default Initialization to save the IndexPath
    init(at indexPath: IndexPath) {
        self.index = indexPath
    }
    
    //Retrieve the Top Left Index based on whether the bubble was in an odd or even row
    var topLeftIndex: IndexPath {
        if index.section % 2 == 0 {
            return IndexPath(item: index.item - 1, section: index.section - 1)
        } else {
            return IndexPath(item: index.item, section: index.section - 1)
        }
    }
    
    //Retrieve the Top Right Index based on whether the bubble was in an odd or even row
    var topRightIndex: IndexPath {
        if index.section % 2 == 0 {
            return IndexPath(item: index.item, section: index.section - 1)
        } else {
            return IndexPath(item: index.item + 1, section: index.section - 1)
        }
    }
    
    //Retrieve Left Bubble
    var leftIndex: IndexPath {
        return IndexPath(item: index.item - 1, section: index.section)
    }
    
    //Retrieve Right Bubble
    var rightIndex: IndexPath {
        return IndexPath(item: index.item + 1, section: index.section)
    }
    
    //Retrieve the Bottom Left Index based on whether the bubble was in an odd or even row
    var bottomLeftIndex: IndexPath {
        if index.section % 2 == 0 {
            return IndexPath(item: index.item - 1, section: index.section + 1)
        } else {
            return IndexPath(item: index.item, section: index.section + 1)
        }
    }
    
    //Retrieve the Bottom Right Index based on whether the bubble was in an odd or even row
    var bottomRightIndex: IndexPath {
        if index.section % 2 == 0 {
            return IndexPath(item: index.item, section: index.section + 1)
        } else {
            return IndexPath(item: index.item + 1, section: index.section + 1)
        }
    }
}
