//
//  ViewController.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 2/8/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var systemTest: UIButton!
    @IBOutlet weak var connectionLabel: UILabel!
    
    @IBOutlet weak var batteryLabel: UILabel!
    
    
    @IBOutlet weak var firmwareLabel: UILabel!
    
    // variables
    let temp1 = Int.random(in: 1...10)
    let temp2 = Int.random(in: 1...10)
    let temp3 = Int.random(in: 1...10)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("Home page loaded")
        
    }
    
  
    
    
    
    @IBAction func SavePressed(_ sender: UIButton) {
        let temp = sender.currentTitle
        
        if temp == "System Test" {
            
            
            //Call your function
            
            
            
            // run your function
            
            //udpate the labels
            connectionLabel.text = String(temp1)
            batteryLabel.text    = String(temp2)
            firmwareLabel.text   = String(temp3)
            
            // change the title
            systemTest.setTitle("Continue", for: .normal)
        }
        
        else {
            print("going to next page")
            systemTest.setTitle("System Test", for: .normal)
            // perform the segue from Home page to User type 
        }
        
    }
    
    

}

