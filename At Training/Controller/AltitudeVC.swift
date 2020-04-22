//
//  AltitudeVC.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 4/19/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

class AltitudeVC: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
  
    
    let pickerData  = [250,500,750,1000,1500,2000,2500,3000]
    
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
        lab.text = String( pickerData[row] )
        lab.textAlignment = .center
        
        let value = pickerData[row]
        
        
        return lab
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let temp = pickerData[row]
        db.set(temp, forKey: K.altitudeSS)
    }
    

     



}


// A Deinit Class --- Inherit from UILabel
class MyLabel : UILabel {
    deinit {
      
    }
}
 




