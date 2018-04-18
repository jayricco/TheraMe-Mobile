//
//  FadeInAnimator.swift
//  TheraMe Mobile
//
//  Created by Jay Ricco on 4/16/18.
//  Copyright © 2018 TheraMe. All rights reserved.
//

import Foundation
import UIKit

public class FadeInAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var transitionDuration: TimeInterval = 0.5
    var startingAlpha: CGFloat = 0.0
    
    public convenience init(transitionDuration: TimeInterval, startingAlpha: CGFloat) {
        self.init()
        self.transitionDuration = transitionDuration
        self.startingAlpha = startingAlpha
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        
        toView.alpha = startingAlpha
        fromView.alpha = 0.8
        containerView.addSubview(toView)
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toView.alpha = 1.0
            fromView.alpha = 0.0
        }) {(_) in
            fromView.alpha = 1.0
            self.doclose(transitionContext: transitionContext)
        }
    }
    private func doclose(transitionContext: UIViewControllerContextTransitioning ) {
        transitionContext.completeTransition(true)
    }
}
