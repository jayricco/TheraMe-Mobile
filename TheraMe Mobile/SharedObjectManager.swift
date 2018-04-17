//
//  SharedObjectManager.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/8/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class SharedObjectManager {
    class var shared: SharedObjectManager {
        struct Static {
            static let instance: SharedObjectManager = SharedObjectManager()
        }
        return Static.instance
    }
    var assignments: [Assignment]?
    var auth_key: String?
    var thumbnails: [String: UIImage]?
    var principalUser: User?
    var currentAssignment: Assignment?
    var playerAssignMap: [AVPlayerItem: Assignment]?
    var fin_unfin_count: (Int, Int) = (0, 0)
    var mainURL: String = "https://159.203.76.153:443" 
    init() {
        assignments = nil
        auth_key = nil
        thumbnails = nil
        principalUser = nil
        currentAssignment = nil
        playerAssignMap = nil
    }
    
    func reset() {
        self.assignments = nil
        self.auth_key = nil
        self.thumbnails = nil
        self.principalUser = nil
        self.currentAssignment = nil
        self.playerAssignMap = [:]
        self.fin_unfin_count = (0, 0)
    }
    
}


