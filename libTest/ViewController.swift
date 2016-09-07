//
//  ViewController.swift
//  libTest
//
//  Created by abdul karim on 25/12/15.
//  Copyright © 2015 dhlabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tapCount = 0
    
    @IBOutlet weak var activityView: activityIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        activityView.lineWidth = 2
        self.startAction(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startAction(_ sender: AnyObject) {
        activityView.startLoading()
        
    }
    
    @IBAction func progressAction(_ sender: AnyObject) {
        let progress: Float = activityView.progress + 0.1043
        activityView.progress = progress
    }
    
    @IBAction func successAction(_ sender: AnyObject) {
        activityView.startLoading()
        activityView.completeLoading(success: true)
    }
    
    @IBAction func unsucessAct(_ sender: AnyObject) {
        activityView.startLoading()
        activityView.strokeColor = UIColor.red
        activityView.completeLoading(success: false)
    }
    @IBAction func changeColorAct(_ sender: AnyObject) {
        tapCount += 1
        
        if (tapCount == 1){
            activityView.strokeColor = UIColor.red        }
        else
            if (tapCount == 2) {
                activityView.strokeColor = UIColor.black
            }
            else
                if (tapCount == 3) {
                    tapCount = 0
                    activityView.strokeColor = UIColor.purple
                    
        }
        
        
        
        
    }
    
}

