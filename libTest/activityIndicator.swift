//
//  activityIndicator.swift
//  libTest
//
//  Created by abdul karim on 25/12/15.
//  Copyright © 2015 dhlabs. All rights reserved.
//

import UIKit

let dhRingStorkeAnimationKey = "IDLoading.stroke"
let dhRingRotationAnimationKey = "IDLoading.rotation"
let dhCompletionAnimationDuration: NSTimeInterval = 0.3
let dhHidesWhenCompletedDelay: NSTimeInterval = 0.5

public typealias Block = () -> Void


public class activityIndicator: UIView {
    public enum ProgressStatus: Int {
        case Unknown, Loading, Progress, Completion
    }
    
    @IBInspectable public var lineWidth: CGFloat = 2.0 {
        didSet {
            progressLayer.lineWidth = lineWidth
            shapeLayer.lineWidth = lineWidth
            
            setProgressLayerPath()
        }
    }
    
    @IBInspectable public var strokeColor: UIColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0){
        didSet{
            progressLayer.strokeColor = strokeColor.CGColor
            shapeLayer.strokeColor = strokeColor.CGColor
            progressLabel.textColor = strokeColor
        }
    }
    
    @IBInspectable public var fontSize: Float = 30 {
        didSet{
            progressLabel.font = UIFont.systemFontOfSize(CGFloat(fontSize))
        }
    }
    
    public var hidesWhenCompleted: Bool = false
    public var hideAfterTime: NSTimeInterval = dhHidesWhenCompletedDelay
    public private(set) var status: ProgressStatus = .Unknown
    
    private var _progress: Float = 0.0
    public var progress: Float {
        get {
            return _progress
        }
        set(newProgress) {
            //Avoid calling excessively
            if (newProgress - _progress >= 0.01 || newProgress >= 100.0) {
                _progress = min(max(0, newProgress), 1)
                progressLayer.strokeEnd = CGFloat(_progress)
                
                if status == .Loading {
                    progressLayer.removeAllAnimations()
                } else if(status == .Completion) {
                    shapeLayer.strokeStart = 0
                    shapeLayer.strokeEnd = 0
                    shapeLayer.removeAllAnimations()
                }
                
                status = .Progress
                
                progressLabel.hidden = false
                let progressInt: Int = Int(_progress * 100)
                progressLabel.text = "\(progressInt)"
            }
        }
    }
    
    private let progressLayer: CAShapeLayer! = CAShapeLayer()
    private let shapeLayer: CAShapeLayer! = CAShapeLayer()
    private let progressLabel: UILabel! = UILabel()
    
    private var completionBlock: Block?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        let square = min(width, height)
        
        let bounds = CGRectMake(0, 0, square, square)
        
        progressLayer.frame = CGRectMake(0, 0, width, height)
        setProgressLayerPath()
        
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        
        let labelSquare = sqrt(2) / 2.0 * square
        progressLabel.bounds = CGRectMake(0, 0, labelSquare, labelSquare)
        progressLabel.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
    }
    
    //MARK: - Public
    public func startLoading() {
        if status == .Loading {
            return
        }
        
        status = .Loading
        
        progressLabel.hidden = true
        progressLabel.text = "0"
        _progress = 0
        
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.removeAllAnimations()
        
        self.hidden = false
        progressLayer.strokeEnd = 0.0
        progressLayer.removeAllAnimations()
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 4.0
        animation.fromValue = 0.0
        animation.toValue = 2 * M_PI
        animation.repeatCount = Float.infinity
        progressLayer.addAnimation(animation, forKey: dhRingRotationAnimationKey)
        
        let totalDuration = 1.0
        let firstDuration = 2.0 * totalDuration / 3.0
        let secondDuration = totalDuration / 3.0
        
        let headAnimation = CABasicAnimation(keyPath: "strokeStart")
        headAnimation.duration = firstDuration
        headAnimation.fromValue = 0.0
        headAnimation.toValue = 0.25
        
        let tailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        tailAnimation.duration = firstDuration
        tailAnimation.fromValue = 0.0
        tailAnimation.toValue = 1.0
        
        let endHeadAnimation = CABasicAnimation(keyPath: "strokeStart")
        endHeadAnimation.beginTime = firstDuration
        endHeadAnimation.duration = secondDuration
        endHeadAnimation.fromValue = 0.25
        endHeadAnimation.toValue = 1.0
        
        let endTailAnimation = CABasicAnimation(keyPath: "strokeEnd")
        endTailAnimation.beginTime = firstDuration
        endTailAnimation.duration = secondDuration
        endTailAnimation.fromValue = 1.0
        endTailAnimation.toValue = 1.0
        
        let animations = CAAnimationGroup()
        animations.duration = firstDuration + secondDuration
        animations.repeatCount = Float.infinity
        animations.animations = [headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]
        progressLayer.addAnimation(animations, forKey: dhRingRotationAnimationKey)
    }
    
    public func completeLoading(success: Bool, completion: Block? = nil) {
        if status == .Completion {
            return
        }
        
        completionBlock = completion
        
        progressLabel.hidden = true
        progressLayer.strokeEnd = 1.0
        progressLayer.removeAllAnimations()
        
        if success {
            setStrokeSuccessShapePath()
        } else {
            setStrokeFailureShapePath()
        }
        
        var strokeStart :CGFloat = 0.25
        var strokeEnd :CGFloat = 0.8
        var phase1Duration = 0.7 * dhCompletionAnimationDuration
        var phase2Duration = 0.3 * dhCompletionAnimationDuration
        var phase3Duration = 0.0
        
        if !success {
            let square = min(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))
            let point = errorJoinPoint()
            let increase = 1.0/3 * square - point.x
            let sum = 2.0/3 * square
            strokeStart = increase / (sum + increase)
            strokeEnd = (increase + sum/2) / (sum + increase)
            
            phase1Duration = 0.5 * dhCompletionAnimationDuration
            phase2Duration = 0.2 * dhCompletionAnimationDuration
            phase3Duration = 0.3 * dhCompletionAnimationDuration
        }
        
        shapeLayer.strokeEnd = 1.0
        shapeLayer.strokeStart = strokeStart
        let timeFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let headStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        headStartAnimation.fromValue = 0.0
        headStartAnimation.toValue = 0.0
        headStartAnimation.duration = phase1Duration
        headStartAnimation.timingFunction = timeFunction
        
        let headEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        headEndAnimation.fromValue = 0.0
        headEndAnimation.toValue = strokeEnd
        headEndAnimation.duration = phase1Duration
        headEndAnimation.timingFunction = timeFunction
        
        let tailStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        tailStartAnimation.fromValue = 0.0
        tailStartAnimation.toValue = strokeStart
        tailStartAnimation.beginTime = phase1Duration
        tailStartAnimation.duration = phase2Duration
        tailStartAnimation.timingFunction = timeFunction
        
        let tailEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        tailEndAnimation.fromValue = strokeEnd
        tailEndAnimation.toValue = success ? 1.0 : strokeEnd
        tailEndAnimation.beginTime = phase1Duration
        tailEndAnimation.duration = phase2Duration
        tailEndAnimation.timingFunction = timeFunction
        
        let extraAnimation = CABasicAnimation(keyPath: "strokeEnd")
        extraAnimation.fromValue = strokeEnd
        extraAnimation.toValue = 1.0
        extraAnimation.beginTime = phase1Duration + phase2Duration
        extraAnimation.duration = phase3Duration
        extraAnimation.timingFunction = timeFunction
        
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [headEndAnimation, headStartAnimation, tailStartAnimation, tailEndAnimation]
        if !success {
            groupAnimation.animations?.append(extraAnimation)
        }
        groupAnimation.duration = phase1Duration + phase2Duration + phase3Duration
        groupAnimation.delegate = self
        shapeLayer.addAnimation(groupAnimation, forKey: nil)
    }
    
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if hidesWhenCompleted {
            NSTimer.scheduledTimerWithTimeInterval(dhHidesWhenCompletedDelay, target: self, selector: "hiddenLoadingView", userInfo: nil, repeats: false)
        } else {
            status = .Completion
            if completionBlock != nil {
                completionBlock!()
            }
        }
    }
    
    //MARK: - Private
    private func initialize() {
        //progressLabel
        progressLabel.font = UIFont.systemFontOfSize(CGFloat(fontSize))
        progressLabel.textColor = strokeColor
        progressLabel.textAlignment = .Center
        progressLabel.adjustsFontSizeToFitWidth = true
        progressLabel.hidden = true
        self.addSubview(progressLabel)
        
        //progressLayer
        progressLayer.strokeColor = strokeColor.CGColor
        progressLayer.fillColor = nil
        progressLayer.lineWidth = lineWidth
        self.layer.addSublayer(progressLayer)
        
        //shapeLayer
        shapeLayer.strokeColor = strokeColor.CGColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 0.0
        self.layer.addSublayer(shapeLayer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"resetAnimations", name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    private func setProgressLayerPath() {
        let center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))
        let radius = (min(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) - progressLayer.lineWidth) / 2
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(0.0), endAngle: CGFloat(2 * M_PI), clockwise: true)
        progressLayer.path = path.CGPath
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
    }
    
    private func setStrokeSuccessShapePath() {
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        let square = min(width, height)
        let b = square/2
        let oneTenth = square/10
        let xOffset = oneTenth
        let yOffset = 1.5 * oneTenth
        let ySpace = 3.2 * oneTenth
        let point = correctJoinPoint()
        
        //y1 = x1 + xOffset + yOffset
        //y2 = -x2 + 2b - xOffset + yOffset
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, point.x, point.y)
        CGPathAddLineToPoint(path, nil, b - xOffset, b + yOffset)
        CGPathAddLineToPoint(path, nil, 2 * b - xOffset + yOffset - ySpace, ySpace)
        
        shapeLayer.path = path
        shapeLayer.cornerRadius = square/2
        shapeLayer.masksToBounds = true
        shapeLayer.strokeStart = 0.0
        shapeLayer.strokeEnd = 0.0
    }
    
    private func setStrokeFailureShapePath() {
        let width = CGRectGetWidth(self.bounds)
        let height = CGRectGetHeight(self.bounds)
        let square = min(width, height)
        let b = square/2
        let space = square/3
        let point = errorJoinPoint()
        
        //y1 = x1
        //y2 = -x2 + 2b
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, point.x, point.y)
        CGPathAddLineToPoint(path, nil, 2 * b - space, 2 * b - space)
        CGPathMoveToPoint(path, nil, 2 * b - space, space)
        CGPathAddLineToPoint(path, nil, space, 2 * b - space)
        
        shapeLayer.path = path
        shapeLayer.cornerRadius = square/2
        shapeLayer.masksToBounds = true
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0.0
    }
    
    private func correctJoinPoint() -> CGPoint {
        let r = min(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2
        let m = r/2
        let k = lineWidth/2
        
        let a: CGFloat = 2.0
        let b = -4 * r + 2 * m
        let c = (r - m) * (r - m) + 2 * r * k - k * k
        let x = (-b - sqrt(b * b - 4 * a * c))/(2 * a)
        let y = x + m
        
        return CGPointMake(x, y)
    }
    
    private func errorJoinPoint() -> CGPoint {
        let r = min(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2
        let k = lineWidth/2
        
        let a: CGFloat = 2.0
        let b = -4 * r
        let c = r * r + 2 * r * k - k * k
        let x = (-b - sqrt(b * b - 4 * a * c))/(2 * a)
        
        return CGPointMake(x, x)
    }
    
    @objc private func resetAnimations() {
        if status == .Loading {
            status = .Unknown
            progressLayer.removeAnimationForKey(dhRingRotationAnimationKey)
            progressLayer.removeAnimationForKey(dhRingStorkeAnimationKey)
            
            startLoading()
        }
    }
    
    @objc private func hiddenLoadingView() {
        status = .Completion
        self.hidden = true
        
        if completionBlock != nil {
            completionBlock!()
        }
    }
}



