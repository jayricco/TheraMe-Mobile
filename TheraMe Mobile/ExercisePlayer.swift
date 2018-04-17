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
        
        let button = UIButton(type: .roundedRect)
        
        let buttonLabel = button.titleLabel!
        buttonLabel.font.withSize(21.0)
        buttonLabel.text = ""
        cov.contentMode = .center
        cov.addSubview(button)
        cov.updateConstraintsIfNeeded()
    }
    
}
