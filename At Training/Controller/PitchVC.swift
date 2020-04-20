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
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 75.0
        }
        
       
        
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
             let lab : UILabel
            
            if let label = view as? UILabel {
                lab = label
             
            } else {
                lab = MyLabel()
           
            }
            lab.font = UIFont(name: "Times New Roman", size: 35.0)
            lab.text = String( pickerData[component][row] )
            lab.textAlignment = .center
            
            let value = pickerData[component][row] 
            
            
            return lab
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let temp = pickerData[component][row]
            
            print("value = \(temp)")
        }
        
    
    
    
    

  

}
