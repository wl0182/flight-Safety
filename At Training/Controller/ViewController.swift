//
//  ViewController.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 2/8/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var connectionLabel: UILabel!
    
    @IBOutlet weak var batteryLabel: UILabel!
    
    
    @IBOutlet weak var firmwareLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    
    
    @IBAction func SavePressed(_ sender: UIButton) {
        
        let temp1 = Int.random(in: 1...100)
        let temp2 = Int.random(in: 1...100)
        let temp3 = Int.random(in: 1...100)
        
        connectionLabel.text = String(temp1)
        batteryLabel.text = String(temp2)
        firmwareLabel.text = String(temp3)
    }
    
    

}

