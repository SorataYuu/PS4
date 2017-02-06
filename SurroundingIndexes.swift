//
//  SurroundingIndexes.swift
//  GameEngine
//
//  Created by Jeremy Jee on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0139963n. All rights reserved.
//

import Foundation

struct SurroundingIndexes {
    private (set) var index: IndexPath
    
    init(at indexPath: IndexPath) {
        self.index = indexPath
    }
    
    var topLeftIndex: IndexPath {
        if index.section % 2 == 0 {
            return IndexPath(item: index.item - 1, section: index.section - 1)
        } else {
            return IndexPath(item: index.item, section: index.section - 1)
        }
    }
    
    var topRightIndex: IndexPath {
        if index.section % 2 == 0 {
            return IndexPath(item: index.item, section: index.section - 1)
        } else {
            return IndexPath(item: index.item + 1, section: index.section - 1)
        }
    }
    
    var leftIndex: IndexPath {
        return IndexPath(item: index.item - 1, section: index.section)
    }
    
    var rightIndex: IndexPath {
        return IndexPath(item: index.item + 1, section: index.section)
    }
    
    var bottomLeftIndex: IndexPath {
        if index.section % 2 == 0 {
            return IndexPath(item: index.item - 1, section: index.section + 1)
        } else {
            return IndexPath(item: index.item, section: index.section + 1)
        }
    }
    
    var bottomRightIndex: IndexPath {
        if index.section % 2 == 0 {
            return IndexPath(item: index.item, section: index.section + 1)
        } else {
            return IndexPath(item: index.item + 1, section: index.section + 1)
        }
    }
}
