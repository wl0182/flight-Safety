
//
//  SafetySettings_ViewController.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 2/22/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

class SafetySettings_ViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    var minRoll: Int = 0
    var minPitch: Int = 0
    var maxRoll: Int = 0
    var maxPitch: Int = 0
    
    
    // Safety Settings data values
    let pickerData = [["-30,+30","-20,+20","-10,+10"],
                      ["-30,+30","-20,+20","-10,+10"],
                      ["-30,+30","-20,+20","-10,+10"],
                      ["-30,+30","-20,+20","-10,+10"]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        picker.delegate = self
        picker.dataSource = self
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        //        return String(pickerData[component][row])
        return pickerData[component][row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if row == 0 {
                minRoll = -30
                maxRoll = 30
            }
            
            if row == 1 {
                minRoll = -20
                maxRoll = 20
            }
            
            if row == 2 {
                minRoll = -10
                maxRoll = 10
            }
        }
        
        if component == 1 {
            if row == 0 {
                minPitch = -30
                maxPitch = 30
                
            }
            
            if row == 1 {
                minPitch = -20
                maxPitch = 20
                
            }
            
            if row == 2 {
                minPitch = -10
                maxPitch = 10
            }
        }
        
       
        
        
    }
    
   
    


}
