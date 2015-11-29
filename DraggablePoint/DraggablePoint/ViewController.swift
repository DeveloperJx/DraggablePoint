//
//  ViewController.swift
//  DraggablePoint
//
//  Created by Jx on 15/11/29.
//  Copyright © 2015年 Jx. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DraggablePointDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let temp = DraggablePoint(frame: CGRect(x: 100.0, y: 100.0, width: 50.0, height: 50.0))
        temp.delegate = self
        
        temp.addDraggablePoint(self, frame: CGRect(x: 100.0, y: 100.0, width: 30.0, height: 45.0), num: 1234567890, labelFont: UIFont(name: "Heiti SC", size: 15)!,labelColor: UIColor.blueColor(), pointColor: UIColor.yellowColor())
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didRemoveFromFatherView(DraggablePointBeenRemoved: NSObject) {
        print("remove \(((DraggablePointBeenRemoved as! DraggablePoint).titleLabel?.text)!)")
    }


}

