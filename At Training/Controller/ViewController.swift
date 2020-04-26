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
    var temp1 : String = ""
    var temp2 : Int = 0
    var temp3 : Float = 0

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
     
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Hello it's me again the home page")
    }
    
  
    
    
    
    @IBAction func SavePressed(_ sender: UIButton) {
        
    }
    
    func updateUI()  {
          //udpate the labels
                  connectionLabel.text = String(temp1)
                  batteryLabel.text    = "\(temp2)% "
                  firmwareLabel.text   = String(temp3)
    }
    
    

}

