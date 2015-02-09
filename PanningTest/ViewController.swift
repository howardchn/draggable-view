//
//  ViewController.swift
//  PanningTest
//
//  Created by AP Thinkgeo on 2/6/15.
//  Copyright (c) 2015 AP Thinkgeo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var tile : UIView = UIView()
    var labelView = UITextView()
    var displayLink : CADisplayLink?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tile.frame = CGRect(x: 0, y: 0, width: 256, height: 256)
        tile.backgroundColor = UIColor.redColor()
        view.addSubview(tile)
        
        var panGesture = UIPanGestureRecognizer(target: self, action: Selector("panHandler:"))
        view.addGestureRecognizer(panGesture)
        
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: Selector("pinchHandler:"))
        view.addGestureRecognizer(pinchGesture)
        
        labelView.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 44)
        labelView.backgroundColor = UIColor.clearColor()
        view.addSubview(labelView)
    }

    func panHandler (p: UIPanGestureRecognizer!) {
        var translation = p.translationInView(view)
        if (p.state == UIGestureRecognizerState.Began) {
            
            self.tile.layer.removeAllAnimations()
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
            var offsetX = inertia.x * 0.2
            var offsetY = inertia.y * 0.2
            var newLeft = tile.frame.minX + offsetX
            var newTop = tile.frame.minY + offsetY
            
            startWatching()
            UIView.animateWithDuration(1, delay: 0, options:UIViewAnimationOptions.CurveEaseOut, animations: {_ in
                self.tile.frame = CGRect(x: newLeft, y: newTop, width: self.tile.frame.width, height: self.tile.frame.height)
                }, completion: {_ in self.stopWatching() })
            
        }
    }
    
    func pinchHandler (p: UIPinchGestureRecognizer!) {
    
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


