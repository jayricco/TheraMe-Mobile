//
//  HolderView.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/16/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation
import UIKit

protocol HolderViewDelegate: class {
    func animateLabel()
}

class HolderView: UIView {
    var parentFrame: CGRect = CGRect.zero
    weak var delegate: HolderViewDelegate?
    let ovalLayer = OvalLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = Colors.clear
        self.isOpaque = false
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addOval() {
        layer.addSublayer(ovalLayer)
        ovalLayer.expand()
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(wobbleOval), userInfo: nil, repeats: false)
    }
    
    @objc func wobbleOval() {
        ovalLayer.wobble()
    }
}
