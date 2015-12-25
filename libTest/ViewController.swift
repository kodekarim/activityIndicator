//
//  ViewController.swift
//  libTest
//
//  Created by Rohan Pawar on 25/12/15.
//  Copyright © 2015 dhlabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tapCount = 0
 
    @IBOutlet weak var activityView: activityIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startAction(sender: AnyObject) {
        activityView.startLoading()
        
    }

    @IBAction func progressAction(sender: AnyObject) {
    }

    @IBAction func successAction(sender: AnyObject) {
         activityView.completeLoading(true)
    }

    @IBAction func unsucessAct(sender: AnyObject) {
        activityView.completeLoading(false)
    }
    @IBAction func changeColorAct(sender: AnyObject) {
         tapCount++
        
        if (tapCount == 1){
            activityView.strokeColor = UIColor.redColor()
        }
        else
            if (tapCount == 2) {
            activityView.strokeColor = UIColor.blackColor()
        }
        else
             if (tapCount == 3) {
                    activityView.strokeColor = UIColor.purpleColor()
        }
        
        
        
    
    }
    
}

