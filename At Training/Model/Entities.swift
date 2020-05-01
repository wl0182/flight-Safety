//
//  Entities.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 4/15/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import Foundation
import RealmSwift



class Flags: Object {
    
    @objc dynamic var User_ID : String?
    @objc dynamic var Training_Type : String?
    @objc dynamic var Date_and_Time : String?
     
}


class User_Record: Object {
@objc dynamic var User_ID = ""
@objc dynamic var Training_Type = ""
@objc dynamic var  Start_Time = ""
@objc dynamic var End_Time = ""
@objc dynamic var Rate_of_Descent = 0
@objc dynamic var Altitude = 0
@objc dynamic var  Min_Roll : Float = 0
@objc dynamic var  Min_Pitch : Float = 0
@objc dynamic var  Max_Roll : Float = 0
@objc dynamic var  Max_Pitch : Float = 0

}

class Use_Record : Object {
    @objc dynamic var User_ID = ""
    @objc dynamic var Aircraft_Type = ""
    @objc dynamic var Tail_Number = ""
    @objc dynamic var Training_Type = ""
    @objc dynamic var  Start_Time = ""
    @objc dynamic var End_Time = ""
    @objc dynamic var Rate_of_Descent = 0
    @objc dynamic var Altitude = 0
    @objc dynamic var  Min_Roll : Float = 0
    @objc dynamic var  Min_Pitch : Float = 0
    @objc dynamic var  Max_Roll : Float = 0
    @objc dynamic var  Max_Pitch : Float = 0
}

