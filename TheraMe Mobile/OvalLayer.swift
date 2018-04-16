//
//  OvalLayer.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/16/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation
import UIKit

class OvalLayer: CAShapeLayer {
    
    let animationDuration: CFTimeInterval = 0.3
    
    override init() {
        super.init()
        fillColor = Colors.red.cgColor
        path = ovalPathSmall.cgPath
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var ovalPathSmall: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: 50.0, y: 50.0, width: 0.0, height: 0.0))
    }
    
    var ovalPathLarge: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: 2.5, y: 17.5, width: 95.0, height: 95.0))
    }
    
    var ovalPathSquishVertical: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: 2.5, y: 20.0, width: 95.0, height: 90.0))
    }
    
    var ovalPathSquishHorizontal: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(x: 5.0, y: 20.0, width: 90.0, height: 90.0))
    }
    
    func expand() {
        let expandAnimation: CABasicAnimation = CABasicAnimation(keyPath: "path")
        expandAnimation.fromValue = ovalPathSmall.cgPath
        expandAnimation.toValue = ovalPathLarge.cgPath
        expandAnimation.duration = animationDuration
        expandAnimation.fillMode = kCAFillModeForwards
        expandAnimation.isRemovedOnCompletion = false
        add(expandAnimation, forKey: nil)
    }
    
    func wobble() {
        let wobble1: CASpringAnimation = CASpringAnimation(keyPath: "path")
        wobble1.mass = 10
        wobble1.fromValue = ovalPathLarge.cgPath
        wobble1.toValue = ovalPathSquishVertical.cgPath
        wobble1.beginTime = 0.0
        wobble1.duration = animationDuration
        
        let wobble2: CASpringAnimation = CASpringAnimation(keyPath: "path")
        wobble2.mass = 20
        wobble2.fromValue = ovalPathSquishVertical.cgPath
        wobble2.toValue = ovalPathSquishHorizontal.cgPath
        wobble2.beginTime = wobble1.beginTime + wobble1.duration
        wobble2.duration = animationDuration
        
        let wobble3: CASpringAnimation = CASpringAnimation(keyPath: "path")

        wobble3.fromValue = ovalPathSquishHorizontal.cgPath
        wobble3.toValue = ovalPathSquishVertical.cgPath
        wobble3.beginTime = wobble2.beginTime + wobble2.duration
        wobble3.duration = animationDuration
        
        let wobble4: CASpringAnimation = CASpringAnimation(keyPath: "path")
        wobble4.fromValue = ovalPathSquishVertical.cgPath
        wobble4.toValue = ovalPathLarge.cgPath
        wobble4.beginTime = wobble3.beginTime + wobble3.duration
        wobble4.duration = animationDuration
        
        let wobbleGroup: CAAnimationGroup = CAAnimationGroup()
        wobbleGroup.animations = [wobble1, wobble2, wobble3, wobble4]
        wobbleGroup.duration = wobble4.beginTime + wobble4.duration
        wobbleGroup.repeatCount = 2
        add(wobbleGroup, forKey: nil)
    }
    
    func contract() {
        
    }
}
