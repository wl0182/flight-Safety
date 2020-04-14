//
//  Manual_ViewController.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 2/22/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

class Manual_ViewController: UIViewController {

    // variables
    let valueReceived = 25
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func InitiatePressed(_ sender: UIButton) {
        
        print(db.integer(forKey: "Min_Pitch"))
        print(valueReceived)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
