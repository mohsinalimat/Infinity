//
//  SnakeInfiniteAnimator.swift
//  InfiniteSample
//
//  Created by Danis on 15/12/26.
//  Copyright © 2015年 danis. All rights reserved.
//

import UIKit
import Infinity

extension UIColor {
    static var SnakeBlue: UIColor {
        return UIColor(red: 76/255.0, green: 143/255.0, blue: 1.0, alpha: 1.0)
    }
}

class SnakeInfiniteAnimator: UIView, CustomInfiniteScrollAnimator {
    
    var color: UIColor? {
        didSet {
            snakeLayer.strokeColor = color?.CGColor
        }
    }
    var animating = false
    
    private var snakeLayer = CAShapeLayer()
    private var snakeLengthByCycle:CGFloat = 0 // 占的周期数
    private var cycleCount = 1000
    
    private var pathLength:CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let ovalDiametor = frame.width / 4
        let lineHeight = frame.height - ovalDiametor
        
        snakeLengthByCycle = 2 - (ovalDiametor/2 * CGFloat(M_PI)) / ((lineHeight + ovalDiametor/2 * CGFloat(M_PI)) * 2)
        pathLength = ovalDiametor * 2 * CGFloat(cycleCount)
        
        let snakePath = UIBezierPath()
        snakePath.moveToPoint(CGPoint(x: 0, y: frame.height - ovalDiametor/2))
        for index in 0...cycleCount {
            let cycleStartX = CGFloat(index) * ovalDiametor * 2
            snakePath.addLineToPoint(CGPoint(x: cycleStartX, y: ovalDiametor / 2))
            snakePath.addArcWithCenter(CGPoint(x: cycleStartX + ovalDiametor / 2, y: ovalDiametor / 2), radius: ovalDiametor / 2, startAngle: CGFloat(M_PI), endAngle: 0, clockwise: true)
            snakePath.addLineToPoint(CGPoint(x: cycleStartX + ovalDiametor, y: frame.height - ovalDiametor / 2))
            snakePath.addArcWithCenter(CGPoint(x: cycleStartX + ovalDiametor / 2 * 3, y: frame.height - ovalDiametor/2), radius: ovalDiametor/2, startAngle: CGFloat(M_PI), endAngle: 0, clockwise: false)
        }
        snakeLayer.path = snakePath.CGPath
        snakeLayer.fillColor = nil
        snakeLayer.strokeColor = UIColor.SnakeBlue.CGColor
        snakeLayer.strokeStart = 0
        snakeLayer.strokeEnd = snakeLengthByCycle / CGFloat(cycleCount)
        snakeLayer.lineWidth = 3
        snakeLayer.lineCap = kCALineCapRound
        
        snakeLayer.frame = self.bounds
        self.layer.addSublayer(snakeLayer)
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
    
    func animateState(state: InfiniteScrollState) {
        switch state {
        case .None:
            stopAnimating()
        case .Loading:
            startAnimating()
        }
    }
    
    private let AnimationGroupKey = "SnakePathAnimations"
    func startAnimating() {
        animating = true
        snakeLayer.hidden = false
        
        snakeLayer.strokeStart = 0
        snakeLayer.strokeEnd = snakeLengthByCycle / CGFloat(cycleCount)
        
        let strokeStartAnim = CABasicAnimation(keyPath: "strokeStart")
        let strokeEndAnim = CABasicAnimation(keyPath: "strokeEnd")
        let moveAnim = CABasicAnimation(keyPath: "position")
        
        strokeStartAnim.toValue = 1 - snakeLengthByCycle/CGFloat(cycleCount)
        strokeEndAnim.toValue = 1
        moveAnim.toValue = NSValue(CGPoint: CGPoint(x: snakeLayer.position.x - pathLength, y: snakeLayer.position.y))
        

        let animGroup = CAAnimationGroup()
        animGroup.animations = [strokeStartAnim,strokeEndAnim,moveAnim]
        animGroup.duration = Double(cycleCount) * 0.6
        
        snakeLayer.addAnimation(animGroup, forKey: AnimationGroupKey)
        
    }
    func stopAnimating() {
        animating = false
        snakeLayer.hidden = true
        
        snakeLayer.removeAnimationForKey(AnimationGroupKey)
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
