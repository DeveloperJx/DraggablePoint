//
//  ViewController.swift
//  DraggablePoint
//
//  Created by Jx on 15/11/29.
//  Copyright © 2015年 Jx. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DraggablePointDelegate, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var tabelView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - DraggablePointDelegate
    
    func didRemoveFromSuperView(DraggablePointBeenRemoved: NSObject) {
        print("remove \(((DraggablePointBeenRemoved as! DraggablePoint).titleLabel?.text)!)")
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let tableViewCell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell1")!
            let draggablePoint = DraggablePoint(frame: CGRect(x: 10.0, y: 10.0, width: 30.0, height: 30.0))
            draggablePoint.delegate = self
            draggablePoint.addDraggablePoint(self, viewBeenAdded: tableViewCell, frame: CGRect(x: 10.0, y: 10.0, width: 15.0, height: 30.0), num: 999, maximum: 99, labelFont: UIFont(name: "Heiti SC", size: 12)!, labelColor: UIColor.whiteColor(), pointColor: UIColor.redColor())
            return tableViewCell
        }else{
            let tableViewCell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell2")!
            let draggablePoint = DraggablePoint(frame: CGRect(x: 10.0, y: 10.0, width: 15.0, height: 20.0))
            draggablePoint.delegate = self
            draggablePoint.addDraggablePoint(self, viewBeenAdded: tableViewCell, frame: CGRect(x: 10.0, y: 10.0, width: 15.0, height: 30.0), num: 888, maximum: -1, labelFont: UIFont(name: "Heiti SC", size: 10)!, labelColor: UIColor.whiteColor(), pointColor: UIColor.redColor())
            return tableViewCell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell1", forIndexPath: indexPath)
            cell.frame = CGRectMake(0, 0, 80, 160)
            let draggablePoint = DraggablePoint(frame: CGRect(x: 10.0, y: 10.0, width: 50.0, height: 50.0))
            draggablePoint.delegate = self
            draggablePoint.addDraggablePoint(self, viewBeenAdded: cell, frame: CGRect(x: 10.0, y: 10.0, width: 15.0, height: 30.0), num: 9, maximum: -1, labelFont: UIFont(name: "Heiti SC", size: 15)!, labelColor: UIColor.whiteColor(), pointColor: UIColor.redColor())
            return cell
        }else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionViewCell2", forIndexPath: indexPath)
            cell.frame = CGRectMake(80, 0, 160, 80)
            let draggablePoint = DraggablePoint(frame: CGRect(x: 20.0, y: 20.0, width: 50.0, height: 50.0))
            draggablePoint.delegate = self
            draggablePoint.addDraggablePoint(self, viewBeenAdded: cell, frame: CGRect(x: 10.0, y: 10.0, width: 15.0, height: 30.0), num: 123, maximum: -1, labelFont: UIFont(name: "Heiti SC", size: 15)!, labelColor: UIColor.purpleColor(), pointColor: UIColor.greenColor())
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
}

