//
//  PitchVC.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 4/19/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

class PitchVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {


    @IBOutlet weak var picker: UIPickerView!
   
    let pickerData = [[-15,-20,-25,-30],[15,20,25,30]]

   
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self

        // Do any additional setup after loading the view.
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let temp = pickerData[component][row]
        return String(temp)
    }
    
    
    
    

  

}
