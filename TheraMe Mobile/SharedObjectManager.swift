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
    var queuePlayer: AVQueuePlayer?
    var principalUser: String?
    var currentAssignment: Assignment?
    init() {
        assignments = nil
        auth_key = nil
        thumbnails = nil
        queuePlayer = nil
        principalUser = nil
        currentAssignment = nil
    }
    
}


