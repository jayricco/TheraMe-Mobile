//
//  LoginButton.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/16/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class LoginButton: UIButton, CAAnimationDelegate {
    public var didEndFinishAnimation: (() -> ())? = nil
    
    let springGoEase = CAMediaTimingFunction(controlPoints: 0.45, -0.36, 0.44, 0.92)
    let shrinkCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
    let expandCurve = CAMediaTimingFunction(controlPoints: 0.95, 0.02, 1, 0.05)
    let shrinkDuration: CFTimeInterval = 0.1
    
    lazy var spinner: Spinner! = {
        let s = Spinner(frame: self.frame)
        self.layer.addSublayer(s)
        return s
    }()
    
    var cachedTitle: String?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    func setup() {
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    
    public func startLoadingAnimation() {
        self.cachedTitle =
            self.title(for: .normal)
        self.setTitle("", for: .normal)
        self.shrink()
        Timer.schedule(repeatInterval: shrinkDuration - 0.25) {
            (timer) in
            self.spinner.animation()
        }
    }
    
    public func startFinishAnimation(delay: TimeInterval, completion: @escaping () -> Void) {
        Timer.schedule(delay) { (timer) in
            print(completion)
            
            self.didEndFinishAnimation = completion
            self.expand()
            self.spinner.stopAnimation()
        }
    }
    
    public func animate(duration: TimeInterval, completion: @escaping () -> Void) {
        startLoadingAnimation()
        startFinishAnimation(delay: duration, completion: completion)
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let animation = anim as! CABasicAnimation
        if animation.keyPath == "transform.scale" {
            didEndFinishAnimation?()
            Timer.schedule(1) { (timer) in
                self.returnToOriginalState()
            }
        }
    }
    func returnToOriginalState() {
        //self.layer.removeAllAnimations()
        //self.setTitle(self.cachedTitle, for: .normal)
    }
    func shrink() {
        let shrink = CABasicAnimation(keyPath: "bounds.size.width")
        shrink.fromValue = frame.width
        shrink.toValue = frame.height
        shrink.duration = shrinkDuration
        shrink.timingFunction = shrinkCurve
        shrink.fillMode = kCAFillModeForwards
        shrink.isRemovedOnCompletion = false
        layer.add(shrink, forKey: shrink.keyPath)
    }
    
    func expand() {
        let expand = CABasicAnimation(keyPath: "transform.scale")
        expand.fromValue = 1.0
        expand.toValue = 26.0
        expand.timingFunction = expandCurve
        expand.duration = 0.3
        expand.delegate = self
        expand.fillMode = kCAFillModeForwards
        expand.isRemovedOnCompletion = false
        layer.add(expand, forKey: expand.keyPath)
    }
}
