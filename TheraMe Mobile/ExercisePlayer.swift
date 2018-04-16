//
//  ExercisePlayer.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/16/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class ExercisePlayer: AVPlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let cov = self.contentOverlayView!
        
        let butt = UIButton(type: .roundedRect)
        
        let buttLabel = butt.titleLabel!
        buttLabel.font.withSize(21.0)
        buttLabel.text = "Fuck Grandma"
        cov.contentMode = .center
        cov.addSubview(butt)
        cov.updateConstraintsIfNeeded()
    }
    
}
