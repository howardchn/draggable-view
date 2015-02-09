//
//  ViewController.swift
//  PanningTest
//
//  Created by AP Thinkgeo on 2/6/15.
//  Copyright (c) 2015 AP Thinkgeo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    var tile : UIView = MyTile()
    var labelView = UITextView()
    var displayLink : CADisplayLink?
    let animationDuration: Double = 0.6
    let animationOffsetRatio: CGFloat = 0.15

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tile.frame = CGRect(x: 10, y: 10, width: 256, height: 256)
        tile.backgroundColor = UIColor.clearColor()
        view.addSubview(tile)
        
        var panGesture = UIPanGestureRecognizer(target: self, action: Selector("panHandler:"))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: Selector("pinchHandler:"))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        var rotationGesture = UIRotationGestureRecognizer(target: self, action: Selector("rotationHandler:"))
        rotationGesture.delegate = self
        view.addGestureRecognizer(rotationGesture)
        
        labelView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 44)
        labelView.backgroundColor = UIColor.clearColor()
        view.addSubview(labelView)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func rotationHandler (r: UIRotationGestureRecognizer!) {
        if r.state == UIGestureRecognizerState.Changed {
            view.transform = CGAffineTransformMakeRotation(r.rotation)
        }
    }

    func panHandler (p: UIPanGestureRecognizer!) {
        var translation = p.translationInView(view)
        if (p.state == UIGestureRecognizerState.Began) {
            tile.frame = tile.layer.presentationLayer().frame
            tile.layer.removeAllAnimations()
            self.stopWatching()
        }
        else if (p.state == UIGestureRecognizerState.Changed) {
            var offsetX = translation.x
            var offsetY = translation.y
            
            var newLeft = tile.frame.minX + offsetX
            var newTop = tile.frame.minY + offsetY
            
            self.tile.frame = CGRect(x: newLeft, y: newTop, width: self.tile.frame.width, height: self.tile.frame.height)
            labelView.text = "x: \(newLeft); y: \(newTop)"
            p.setTranslation(CGPoint.zeroPoint, inView: view)
        }
        else if (p.state == UIGestureRecognizerState.Ended) {
            var inertia = p.velocityInView(view)
            var offsetX = inertia.x * animationOffsetRatio
            var offsetY = inertia.y * animationOffsetRatio
            var newLeft = tile.frame.minX + offsetX
            var newTop = tile.frame.minY + offsetY
            
            startWatching()
            
            UIView.animateWithDuration(animationDuration, delay: 0, options:UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: {_ in
                self.tile.frame = CGRect(x: newLeft, y: newTop, width: self.tile.frame.width, height: self.tile.frame.height)
                }, completion: {_ in self.stopWatching() })
        }
    }
    
    func pinchHandler (p: UIPinchGestureRecognizer!) {
        
        if p.state == UIGestureRecognizerState.Changed {
            var touchAnchor = p.anchorInView(view)
            scaleView(tile, scale: p.scale, anchor: touchAnchor)
            p.scale = 1
        }
        else if p.state == UIGestureRecognizerState.Ended {
            var touchAnchor = p.anchorInView(view)
            UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.AllowUserInteraction, animations: {_ in
                self.scaleView(self.tile, scale: 1 + p.velocity * self.animationOffsetRatio, anchor: touchAnchor)
            }, completion: {_ in self.stopWatching() })
        }
    }
    
    func scaleView(targetView: UIView, scale: CGFloat, anchor: CGPoint) {
        var touchX = anchor.x
        var touchY = anchor.y
        
        var left = targetView.frame.minX
        var top = targetView.frame.minY
        var right = targetView.frame.maxX
        var bottom = targetView.frame.maxY
        
        var leftToPinchAnchor = touchX - left
        var rightToPinchAnchor = right - touchX
        var topToPinchAnchor = touchY - top
        var bottomToPinchAnchor = bottom - touchY
        
        var newLeft = touchX - leftToPinchAnchor * scale
        var newRight = touchX + rightToPinchAnchor * scale
        var newTop = touchY - topToPinchAnchor * scale
        var newBottom = touchY + bottomToPinchAnchor * scale
        
        targetView.frame = CGRect(x: newLeft, y: newTop, width: newRight - newLeft, height: newBottom - newTop)
    }
    
    func frameUpdated (d: CADisplayLink!) {
        var layer: AnyObject! = tile.layer.presentationLayer();
        var newLeft = layer.frame.minX
        var newTop = layer.frame.minY
        labelView.text = "x: \(newLeft); y: \(newTop)"
    }
    
    func stopWatching () {
        if (displayLink != nil) {
            displayLink!.invalidate()
            displayLink = nil
        }
    }
    
    func startWatching() {
        if (displayLink == nil) {
            displayLink = CADisplayLink(target: self, selector: Selector("frameUpdated:"))
            displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        }
    }
}

public class MyTile : UIView {
    private let cellCount : Float = 10
    
    override public func drawRect(rect: CGRect) {
        var cellSize = Float(rect.width) / cellCount
        var context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, 1)
        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
        
        for var row : Float = 0; row <= cellCount; row++ {
            var top = CGFloat(row * cellSize)
            var pointsH = [CGPoint(x: 0, y: top), CGPoint(x: rect.width, y: top)]
            CGContextAddLines(context, pointsH, UInt(pointsH.count))
            
            for var column : Float = 0; column <= cellCount; column++ {
                var left = CGFloat(column * cellSize)
                var pointsV = [CGPoint(x: left, y: 0), CGPoint(x: left, y: rect.height)];
                CGContextAddLines(context, pointsV, UInt(pointsV.count))
            }
        }
        
        CGContextDrawPath(context, kCGPathStroke)
    }
}

public extension UIPinchGestureRecognizer {
    func anchorInView(view : UIView) -> CGPoint {
        var touchNumber = self.numberOfTouches()
        var touchXSum: CGFloat = 0
        var touchYSum: CGFloat = 0
        for var i = 0; i < touchNumber; i++ {
            let touchXY = self.locationOfTouch(i, inView: view)
            touchXSum += touchXY.x
            touchYSum += touchXY.y
        }
        
        var touchX = touchXSum / CGFloat(touchNumber)
        var touchY = touchYSum / CGFloat(touchNumber)
        
        return CGPoint(x: touchX, y: touchY)
    }
}


