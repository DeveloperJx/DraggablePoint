//
//  DraggablePoint.swift
//  DraggablePoint
//
//  Created by Jx on 15/11/9.
//  Copyright © 2015年 Jx. All rights reserved.
//

import UIKit

@objc public protocol DraggablePointDelegate : NSObjectProtocol{
    ///从父视图上删除时的委托方法
    ///
    /// :param: DraggablePointBeenRemoved 被删除的DraggablePoint
    optional func didRemoveFromSuperView(DraggablePointBeenRemoved:NSObject)
}

class DraggablePoint: UIButton, UIGestureRecognizerDelegate {
    
    ///点的颜色(默认红色)
    var mainColor = UIColor.redColor()
    ///拖拽时的视图
    var dragingPointImageView = UIImageView()
    ///拖拽时的标签
    var dragingPointUILable = UILabel()
    ///父视图控制器
    var superVC = ViewController()
    ///被添加到的视图
    var viewBA = UIView()
    ///是否拉断
    var broken = false
    ///拉扯中段图层
    var shapeLayer = CAShapeLayer()
    ///被拉断前原始圆的最小半径
    var minimumRadiusBeforeBroken:CGFloat = 8.0
    ///拉断后最大可恢复恢复距离(默认三倍半径)
    var resumableMaximumDistance:CGFloat = 1.0
    ///爆炸动画帧间隔时间（微秒）
    var frame_IntervalTime:UInt32 = 100000
    ///委托对象
    weak internal var delegate: DraggablePointDelegate?
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        dragingPointImageView.frame = frame
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("deviceOrientationDidChange"), name: "UIDeviceOrientationDidChangeNotification", object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CustomFunctions
    
    /// 向当前页面添加一个可拖拽的圆点
    ///
    /// :param: superViewController 父页面视图控制器(cell中添加圆点，请传入tableView所在页的controller)
    /// :param: viewBeenAdded 被添加到的页面
    /// :param: frame 圆点的位置和大小(请传入一个正方形区域，若传入长方形，将自动取最长边作正方形区域来绘制圆点)
    /// :param: num 圆点中的数字
    /// :param: maximum 圆点中的数字的最大值(传入非正数可让圆点显示整型范围内全部数字，传入正数则限制圆点显示最大值，超过后显示"(最大值)+")
    /// :param: labelFont 圆点中数字的文字格式
    /// :param: labelColor 圆点中数字的文字颜色(默认白色)
    /// :param: pointColor 点的颜色(默认红色)
    func addDraggablePoint(superViewController:ViewController, viewBeenAdded:UIView, frame:CGRect, num:Int, maximum:(Int), labelFont:UIFont, labelColor:UIColor?, pointColor:UIColor?){
        if frame.size.height == frame.size.width{
            resumableMaximumDistance = frame.size.height / 2 * 3
            self.frame = frame
        }else{
            if frame.size.height > frame.size.width{
                resumableMaximumDistance = frame.size.height / 2 * 3
                self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.height)
            }else{
                resumableMaximumDistance = frame.size.width / 2 * 3
                self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width)
            }
        }
        
        if pointColor != nil{
            mainColor = pointColor!
        }
        
        if maximum > 0{
            if num > maximum{
                self.setTitle("\(maximum)+", forState: UIControlState.Normal)
            }else{
                self.setTitle("\(num)", forState: UIControlState.Normal)
            }
        }else{
            self.setTitle("\(num)", forState: UIControlState.Normal)
        }
        
        self.setTitleColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Normal)
        self.setTitleColor(UIColor(white: 1.0, alpha: 1.0), forState: UIControlState.Highlighted)
        self.titleLabel?.font = labelFont
        
        superVC = superViewController
        shapeLayer.frame = superVC.view.bounds
        superVC.view.layer.addSublayer(shapeLayer)
        
        viewBA = viewBeenAdded
        viewBA.addSubview(self)
        
        self.setBackgroundImage(self.makeBackgroundImageWithColor(mainColor), forState: UIControlState.Normal)
        self.setBackgroundImage(self.makeBackgroundImageWithColor(mainColor), forState: UIControlState.Highlighted)
        dragingPointImageView = UIImageView(image: self.makeBackgroundImageWithColor(mainColor))
        shapeLayer.fillColor = mainColor.CGColor
        
        dragingPointUILable.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: self.bounds.height)
        dragingPointUILable.text = self.titleLabel?.text
        dragingPointUILable.font = labelFont
        dragingPointUILable.textColor = UIColor(white: 1.0, alpha: 1.0)
        dragingPointUILable.textAlignment = NSTextAlignment.Center
        
        if labelColor != nil{
            dragingPointUILable.textColor = labelColor
            self.setTitleColor(labelColor, forState: UIControlState.Normal)
            self.setTitleColor(labelColor, forState: UIControlState.Highlighted)
        }
    }
    
    func drawPath(radiusA:CGFloat, pointA:CGPoint, pointB:CGPoint){
        let radiusB:CGFloat = radiusA - 0.1 * self.distanceBetweenPoints(pointA, point2: pointB)
        if radiusB <= minimumRadiusBeforeBroken || broken{
            broken = true
            self.shapeLayer.fillColor = UIColor.clearColor().CGColor
            self.shapeLayer.hidden = true
        }
        let bezier = UIBezierPath()
        
        let pointC = CGPoint(x: (pointA.x + pointB.x) / 2, y: (pointA.y + pointB.y) / 2)

        //以下四点为两段圆弧起点与终点
        var pointD = CGPoint(x: 0, y: 0)
        var pointE = CGPoint(x: 0, y: 0)
        var pointF = CGPoint(x: 0, y: 0)
        var pointG = CGPoint(x: 0, y: 0)
        
        if pointA.x == pointB.x{
            pointD = CGPoint(x: pointA.x - radiusA, y: pointA.y)
            pointE = CGPoint(x: pointA.x + radiusA, y: pointA.y)
            pointF = CGPoint(x: pointB.x - radiusB, y: pointB.y)
            pointG = CGPoint(x: pointB.x + radiusB, y: pointB.y)
            if pointA.y > pointB.y{
                bezier.moveToPoint(pointF)
                bezier.addQuadCurveToPoint(pointD, controlPoint: pointC)
                bezier.addLineToPoint(pointE)
                bezier.addQuadCurveToPoint(pointG, controlPoint: pointC)
                bezier.closePath()
            }else{
                bezier.moveToPoint(pointD)
                bezier.addQuadCurveToPoint(pointF, controlPoint: pointC)
                bezier.addLineToPoint(pointG)
                bezier.addQuadCurveToPoint(pointE, controlPoint: pointC)
                bezier.closePath()
            }
        }else if pointA.y == pointB.y{
            pointD = CGPoint(x: pointA.x, y: pointA.y - radiusA)
            pointE = CGPoint(x: pointA.x, y: pointA.y + radiusA)
            pointF = CGPoint(x: pointB.x, y: pointB.y - radiusB)
            pointG = CGPoint(x: pointB.x, y: pointB.y + radiusB)
            if pointA.x > pointB.x{
                bezier.moveToPoint(pointG)
                bezier.addQuadCurveToPoint(pointE, controlPoint: pointC)
                bezier.addLineToPoint(pointD)
                bezier.addQuadCurveToPoint(pointF, controlPoint: pointC)
                bezier.closePath()
            }else{
                bezier.moveToPoint(pointD)
                bezier.addQuadCurveToPoint(pointF, controlPoint: pointC)
                bezier.addLineToPoint(pointG)
                bezier.addQuadCurveToPoint(pointE, controlPoint: pointC)
                bezier.closePath()
            }
        }else{
            let valueK = (pointB.x - pointA.x) / (pointA.y - pointB.y)
            let angle = atan(valueK)
            var y1 = CGFloat.init(sin(angle)) * radiusA + pointA.y
            var x1 = CGFloat.init(cos(angle)) * radiusA + pointA.x
            var y2 = CGFloat.init(sin(angle + CGFloat.init(M_PI))) * radiusA + pointA.y
            var x2 = CGFloat.init(cos(angle + CGFloat.init(M_PI))) * radiusA + pointA.x
            
            pointD = CGPoint(x: x1, y: y1)
            pointE = CGPoint(x: x2, y: y2)

            y1 = CGFloat.init(sin(angle)) * radiusB + pointB.y
            x1 = CGFloat.init(cos(angle)) * radiusB + pointB.x
            y2 = CGFloat.init(sin(angle + CGFloat.init(M_PI))) * radiusB + pointB.y
            x2 = CGFloat.init(cos(angle + CGFloat.init(M_PI))) * radiusB + pointB.x
            
            pointF = CGPoint(x: x1, y: y1)
            pointG = CGPoint(x: x2, y: y2)
            
            if pointD.x < pointE.x{
                if pointF.x < pointG.x{
                    bezier.moveToPoint(pointD)
                    bezier.addQuadCurveToPoint(pointF, controlPoint: pointC)
                    bezier.addLineToPoint(pointG)
                    bezier.addQuadCurveToPoint(pointE, controlPoint: pointC)
                    bezier.closePath()
                }else{
                    bezier.moveToPoint(pointD)
                    bezier.addQuadCurveToPoint(pointG, controlPoint: pointC)
                    bezier.addLineToPoint(pointF)
                    bezier.addQuadCurveToPoint(pointE, controlPoint: pointC)
                    bezier.closePath()
                }
            }else{
                if pointF.x < pointG.x{
                    bezier.moveToPoint(pointE)
                    bezier.addQuadCurveToPoint(pointF, controlPoint: pointC)
                    bezier.addLineToPoint(pointG)
                    bezier.addQuadCurveToPoint(pointD, controlPoint: pointC)
                    bezier.closePath()
                }else{
                    bezier.moveToPoint(pointE)
                    bezier.addQuadCurveToPoint(pointG, controlPoint: pointC)
                    bezier.addLineToPoint(pointF)
                    bezier.addQuadCurveToPoint(pointD, controlPoint: pointC)
                    bezier.closePath()
                }
            }
        }
        //在原来的位置添加圆
        if pointA.y > pointB.y {
            if pointA.x == pointB.x{
                bezier.appendPath(UIBezierPath(arcCenter: pointB, radius: radiusB, startAngle: 0.0, endAngle: CGFloat.init(2 * M_PI), clockwise: false))
            }else{
                bezier.appendPath(UIBezierPath(arcCenter: pointB, radius: radiusB, startAngle: 0.0, endAngle: CGFloat.init(2 * M_PI), clockwise: true))
            }
        }else if pointA.y < pointB.y {
            bezier.appendPath(UIBezierPath(arcCenter: pointB, radius: radiusB, startAngle: 0.0, endAngle: CGFloat.init(2 * M_PI), clockwise: false))
        }else{
            if pointA.x > pointB.x{
                bezier.appendPath(UIBezierPath(arcCenter: pointB, radius: radiusB, startAngle: 0.0, endAngle: CGFloat.init(2 * M_PI), clockwise: false))
            }else{
                bezier.appendPath(UIBezierPath(arcCenter: pointB, radius: radiusB, startAngle: 0.0, endAngle: CGFloat.init(2 * M_PI), clockwise: true))
            }
        }
        shapeLayer.path = bezier.CGPath
    }
    
    func distanceBetweenPoints(point1:CGPoint, point2:CGPoint) -> CGFloat{
        return sqrt(pow(fabs(point1.x - point2.x), 2.0) + pow(fabs(point1.y - point2.y), 2.0))
    }
    
    func makeBackgroundImageWithColor(color:UIColor) -> UIImage{
        var pointSize:CGSize
        if self.titleLabel?.text?.characters.count < 2{
            pointSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height)
        }else{
            pointSize = CGSizeMake(self.bounds.size.width + ((self.titleLabel?.font.pointSize)! / 6) * CGFloat.init((self.titleLabel?.text?.characters.count)! - 1), self.bounds.size.height)
            self.bounds = CGRectMake(0, 0, pointSize.width, pointSize.height)
        }
        UIGraphicsBeginImageContext(pointSize)
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, pointSize.width, pointSize.height))
        let originalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // 开始一个Image的上下文
        UIGraphicsBeginImageContextWithOptions(originalImage.size, false, 0.0)
        self.layer.cornerRadius = self.bounds.size.height / 2
        self.layer.masksToBounds = true
        // 绘制图片
        originalImage.drawInRect(CGRectMake(0, 0, pointSize.width, pointSize.height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    func deviceOrientationDidChange(){
        broken = false
        self.dragingPointImageView.removeFromSuperview()
        self.dragingPointUILable.removeFromSuperview()
        self.hidden = false
        self.shapeLayer.fillColor = UIColor.clearColor().CGColor
        self.shapeLayer.hidden = true
    }
    
    // MARK: - Animations
    
    func reboundedAnimation() {
        while !NSThread.currentThread().cancelled {
            if !broken {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.shapeLayer.hidden = false
                    self.shapeLayer.fillColor = self.mainColor.CGColor
                    self.drawPath(self.frame.size.height / 2, pointA: self.dragingPointImageView.center, pointB: UIView(frame: self.convertRect(self.bounds, toView: self.superVC.view)).center)
                })
            }
            usleep(16000)
        }
    }
    
    func explosionAnimation(touches:Set<UITouch>){
        let brokeAnimateView = UIImageView(frame: CGRectMake(0.0, 0.0, 90.6, 66.0))
        brokeAnimateView.center = (touches.first?.locationInView(superVC.view))!
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.superVC.view.addSubview(brokeAnimateView)
            brokeAnimateView.image = UIImage(named: "frame1")
        }
        usleep(frame_IntervalTime)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            brokeAnimateView.image = UIImage(named: "frame2")
        }
        usleep(frame_IntervalTime)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            brokeAnimateView.image = UIImage(named: "frame3")
        }
        usleep(frame_IntervalTime)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            brokeAnimateView.image = UIImage(named: "frame4")
        }
        usleep(frame_IntervalTime)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            brokeAnimateView.image = UIImage(named: "frame5")
        }
        usleep(frame_IntervalTime)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            brokeAnimateView.image = UIImage(named: "frame6")
        }
        usleep(frame_IntervalTime)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            brokeAnimateView.image = UIImage(named: "frame7")
        }
        usleep(frame_IntervalTime)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            brokeAnimateView.image = UIImage(named: "frame8")
            brokeAnimateView.removeFromSuperview()
        }
    }
    
    // MARK: - DraggablePointTouchEvents
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dragingPointImageView.frame = self.convertRect(self.bounds, toView: superVC.view)
        dragingPointImageView.layer.cornerRadius = self.layer.cornerRadius
        dragingPointImageView.layer.masksToBounds = true
        dragingPointImageView.addSubview(dragingPointUILable)
        superVC.view.addSubview(dragingPointImageView)
        self.hidden = true
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.shapeLayer.hidden = false
        self.shapeLayer.fillColor = self.mainColor.CGColor
        self.drawPath(self.frame.size.height / 2, pointA: (touches.first?.locationInView(superVC.view))!, pointB: UIView(frame: self.convertRect(self.bounds, toView: superVC.view)).center)
        dragingPointImageView.center = (touches.first?.locationInView(superVC.view))!
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if broken{
            if self.distanceBetweenPoints(UIView(frame: self.convertRect(self.bounds, toView: superVC.view)).center, point2: (touches.first?.locationInView(superVC.view))!) <= resumableMaximumDistance{
                let threadForFrame = NSThread(target: self, selector: Selector("reboundedAnimation"), object: nil)
                threadForFrame.start()
                self.shapeLayer.fillColor = UIColor.clearColor().CGColor
                self.shapeLayer.hidden = true
                UIView.animateWithDuration(0.05,
                    delay: 0.0,
                    options: UIViewAnimationOptions.CurveEaseIn,
                    animations: { () -> Void in
                    self.dragingPointImageView.center = UIView(frame: self.convertRect(self.bounds, toView: self.superVC.view)).center
                    }, completion: { (finished:Bool) -> Void in
                        self.dragingPointImageView.removeFromSuperview()
                        self.dragingPointUILable.removeFromSuperview()
                        self.hidden = false
                        self.broken = false
                        threadForFrame.cancel()
                })
            }else{
                NSThread.detachNewThreadSelector(Selector("explosionAnimation:"), toTarget: self, withObject: touches)
                self.dragingPointImageView.removeFromSuperview()
                self.dragingPointUILable.removeFromSuperview()
                self.removeFromSuperview()
                if delegate != nil {
                    if delegate?.respondsToSelector(Selector("didRemoveFromSuperView:")) == true {
                        delegate?.didRemoveFromSuperView!(self)
                    }
                }
            }
        }else{
            let threadForFrame = NSThread(target: self, selector: Selector("reboundedAnimation"), object: nil)
            threadForFrame.start()
            UIView.animateWithDuration(0.5,
                delay: 0.0,
                usingSpringWithDamping: 0.3,
                initialSpringVelocity: 30.0,
                options: UIViewAnimationOptions.CurveEaseIn,
                animations: { () -> Void in
                self.dragingPointImageView.center = UIView(frame: self.convertRect(self.bounds, toView: self.superVC.view)).center
                }){ (finished:Bool) -> Void in
                    self.hidden = false
                    self.shapeLayer.fillColor = UIColor.clearColor().CGColor
                    self.shapeLayer.hidden = true
                    threadForFrame.cancel()
            }
        }
    }
}