//
//  RateOfDecentVC.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 4/19/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

class RateOfDecentVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
 let pickerData  = [-500,-1000,-1500,-2000,-2500,-3000]
    @IBOutlet weak var picker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self

        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         let temp = pickerData[row]
         return String(temp)
     }
     
    

   
}
