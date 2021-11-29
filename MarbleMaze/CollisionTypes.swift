//
//  CollisionTypes.swift
//  MarbleMaze
//
//  Created by Nick Sagan on 28.11.2021.
//

import Foundation

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case tEntrance = 32
    case tExit = 64
}
