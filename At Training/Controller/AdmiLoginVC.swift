//
//  AdminLoginViewController.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 2/19/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

class AdminLoginViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var passwordIncorrectLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        if password.text == "qw12er" {
            self.performSegue(withIdentifier: "goToCalibration", sender: self)
        }
        else {
            self.passwordIncorrectLabel.text = "Incorrect PIN, please reenter the Admin code"
            
        }
        
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
