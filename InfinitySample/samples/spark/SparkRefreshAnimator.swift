//
//  SparkRefreshAnimator.swift
//  InfinitySample
//
//  Created by Danis on 16/1/2.
//  Copyright © 2016年 danis. All rights reserved.
//

import UIKit
import Infinity

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init(hex: Int) {
        self.init(hex:hex, alpha:1.0)
    }
    
    static func sparkColorWithIndex(index: Int) -> UIColor {
        switch index % 8 {
        case 0:
            return UIColor(hex: 0xf9b60f)
        case 1:
            return UIColor(hex: 0xf78a44)
        case 2:
            return UIColor(hex: 0xf05e4d)
        case 3:
            return UIColor(hex: 0xf75078)
        case 4:
            return UIColor(hex: 0xc973e4)
        case 5:
            return UIColor(hex: 0x1bbef1)
        case 6:
            return UIColor(hex: 0x5593f0)
        case 7:
            return UIColor(hex: 0x00cf98)
        default:
            return UIColor.clearColor()
        }
    }
}

class SparkRefreshAnimator: UIView, CustomPullToRefreshAnimator {
    
    private var circles = [CAShapeLayer]()
    var animating = false
    
    private var positions = [CGPoint]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let ovalDiameter = min(frame.width,frame.height) / 8
        let ovalPath = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: ovalDiameter, height: ovalDiameter))
        
        let count = 8
        for index in 0..<count {
            let circleLayer = CAShapeLayer()
            circleLayer.path = ovalPath.CGPath
            circleLayer.fillColor = UIColor.sparkColorWithIndex(index).CGColor
            circleLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            self.circles.append(circleLayer)
            self.layer.addSublayer(circleLayer)
            
            let angle = CGFloat(M_PI * 2) / CGFloat(count) * CGFloat(index)
            
            let radius = min(frame.width, frame.height) * 0.4
            let position = CGPoint(x: bounds.midX + sin(angle) * radius, y: bounds.midY - cos(angle) * radius)
            circleLayer.position = position
            
            positions.append(position)
        }
        alpha = 0
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window != nil && animating {
            startAnimating()
        }
    }

    func animateState(state: PullToRefreshState) {
        switch state {
        case .None:
            alpha = 0
            stopAnimating()
        case .Loading:
            startAnimating()
        case .Releasing(let progress):
            alpha = 1.0
            updateForProgress(progress)
        }
    }
    func updateForProgress(progress: CGFloat) {
        let number = progress * CGFloat(circles.count)
        
        for index in 0..<8 {
            let circleLayer = circles[index]
            if CGFloat(index) < number {
                circleLayer.hidden = false
            }else {
                circleLayer.hidden = true
            }
        }
    }
    func startAnimating() {
        animating = true
        for index in 0..<8 {
            applyAnimationForIndex(index)
        }
    }
    private let CircleAnimationKey = "CircleAnimationKey"
    private func applyAnimationForIndex(index: Int) {
        let moveAnimation = CAKeyframeAnimation(keyPath: "position")
        let moveV1 = NSValue(CGPoint: positions[index])
        let moveV2 = NSValue(CGPoint: CGPoint(x: bounds.midX, y: bounds.midY))
        let moveV3 = NSValue(CGPoint: positions[index])
        moveAnimation.values = [moveV1,moveV2,moveV3]
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        let scaleV1 = NSValue(CATransform3D: CATransform3DIdentity)
        let scaleV2 = NSValue(CATransform3D: CATransform3DMakeScale(0.1, 0.1, 1.0))
        let scaleV3 = NSValue(CATransform3D: CATransform3DIdentity)
        scaleAnimation.values = [scaleV1,scaleV2,scaleV3]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [moveAnimation,scaleAnimation]
        animationGroup.duration = 1.0
        animationGroup.repeatCount = 1000
        animationGroup.beginTime = CACurrentMediaTime() + Double(index) * animationGroup.duration / 8 / 2
        animationGroup.timingFunction = CAMediaTimingFunction(controlPoints: 1, 0.27, 0, 0.75)
        
        let circleLayer = circles[index]
        circleLayer.hidden = false
        circleLayer.addAnimation(animationGroup, forKey: CircleAnimationKey)
        
    }
    func stopAnimating() {
        for circleLayer in circles {
            circleLayer.removeAnimationForKey(CircleAnimationKey)
            circleLayer.transform = CATransform3DIdentity
            circleLayer.hidden = true
        }
        animating = false
    }
}
