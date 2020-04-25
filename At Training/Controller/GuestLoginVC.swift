//
//  GuestLoginVC.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 4/25/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

var guestID = ""

class GuestLoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userIdTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIdTF.delegate = self

        // Do any additional setup after loading the view.
    }
    
    //Textfields Delegates
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if userIdTF.text != ""  {
            return true
        }
        else{
            return false
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userIdTF.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guestID = userIdTF.text!
        
    }
    
    
    
    @IBAction func ContinuePressed(_ sender: UIButton) {
        // searchTextField.endEditing(true)
        userIdTF.endEditing(true)
        
    }
    
    


}
