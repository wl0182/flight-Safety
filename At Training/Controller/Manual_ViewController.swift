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
    var valueReceived: Float = 40 //40 is arbitrarily set
    var valueReceivedasSigned: Int = 10 //10 is arbitrarily set
    var altitudeSafetyTrigger: Int = 0 //stays 0 until Altitude in SafetySettings is exceeded. Then if MSL altitude comes below SafetySetting Altitude, this trigger's value will allow us to send emg flip up signal to microcontroller
    //var abortOnFlipUp: Bool = false
    
    
    var temp3 : Float = 0
    var startReceiver: Int = 0;
    // var altitudeFSS = db.integer(forKey: K.altitudeSS)//this statement will be cut from here and used down inside while loop.
    
    func abortTraining(){
        let alert = UIAlertController(title: "safetyLimitExceeded", message: "Safety Limit Exceeded-Training Aborted", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default){
            (action) in
        }
        
        
        alert.addAction(action)
        present(alert, animated: true, completion:  nil) //Thread 7: Exception: "Modifications to the layout engine must not be performed from a background thread after it has been accessed from the main thread."
        //self.present(alert, animated: true, completion: nil)
        //let action = UIAlertAction(title: "ok",style: default, handler: nil)
        //let action = UIAlertAction(title: "Ok", style: default, handler: <#T##((UIAlertAction) -> Void)?##((UIAlertAction) -> Void)?##(UIAlertAction) -> Void#>)
        
        //abort training
        
        //set button title to initiate
        
    }
    
    // outlets
    
    @IBOutlet weak var visibilityLabel: UILabel!
    
    @IBOutlet weak var ceilingLabel: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }   //viewdidload()
    
    func visiblityToVoltage(v: Float) -> Float{
        let temp = v/0.25
        let voltage = 7.6 + temp*0.2
        return voltage
        
    }
    
    @IBAction func visibilitySlider(_ sender: UISlider) {
        let temp = sender.value
        let temp1 = temp*4
        let temp2 = roundf(temp1)
        temp3 = temp2/4
        
        let tempS = String(temp3)
        visibilityLabel.text = tempS
        db.set(temp3, forKey: K.ManualVisibility)
        
        
    }
    
    
    @IBAction func ceilingSlider(_ sender: UISlider) {
        let temp = sender.value
        let tempI = Int(temp) //use this tempI for both - storing in database AND comparisons in while loop below
        let tempS = String(Int(temp))
        ceilingLabel.text = tempS
        db.set(tempI, forKey: K.ManualCeiling)
        
    }
    
    var buttonTitle: String = ""
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        startReceiver = 0 //if startReceiver is any value other than 10, while loop for receiving AHRS data will not run
        altitudeSafetyTrigger = 0 //set the safety altitude trigger to zero when abort is pressed
        print("I stopped reading from the AHRS device")
        buttonTitle = "pressedBackButton"
        
    }
    
    
    //
    @IBAction func InitiatePressed(_ sender: UIButton) {
        
        let title = sender.currentTitle
        buttonTitle = (sender.currentTitle!)
        
        if title == "Initiate" {
            print("I am reading from The ILevel")
            startReceiver = 10 //while loop for receiving data from AHRS only runs as long as startReceiver stays 10. COMMENT THIS OUT FOR DISABLING THE RECEIVER WHILE LOOP
            readFIL()
            sender.setTitle("Abort", for: .normal)
            
        }
        else if title == "Abort" || buttonTitle == "pressedBackButton" {
            sender.setTitle("Initiate", for: .normal)//this should be placed at last line of scope end to stay consistent with if{} behavior
            
            startReceiver = 0 //if startReceiver is any value other than 10, while loop for receiving AHRS data will not run
            altitudeSafetyTrigger = 0 //set the safety altitude trigger to zero when abort is pressed
            print("I stopped reading from the Ilevel")
        }
        
        //sample voltage value receiver based on visibility value -------STARTS HERE
        let vo = visiblityToVoltage(v: temp3 )
        print("Voltage return is \(vo)")
        let volts = Int(vo*10)
        //a     let hexByte = String(volts, radix:16) //can use this to convert volt to hex byte of string type as well
        //a     print("voltage converted to hex string is: \(hexByte)") //printing of a procedure
        let hexByteUpperCase = String(format:"%02X", volts)  //b
        
        print("voltage converted to hex string UPPER CASE is: \(hexByteUpperCase)") //b
        //c       let hexByteInUInt = UInt8(hexByteUpperCase)
        //c        print("voltage converted to hex UInt8 UPPER CASE is: \(hexByteInUInt)")
        print("Visiblity = \(db.float(forKey: K.ManualVisibility))")
        var hexBytesArray: [String] = []
        hexBytesArray.append("00")
        hexBytesArray.append("00")
        hexBytesArray.append(hexByteUpperCase)
        print("The string array for hex bytes has:\(hexBytesArray[0])")
        var count = 0;
        for bytes in hexBytesArray {
            print("Byte \(count) is \(hexBytesArray[count]).\n")
            print("Byte \(count) is \(bytes).\n")
            //            let nonString = __uint8_t(bytes)// doesnt work for us
            //            print("Byte \(count) is \(String(describing: nonString)).\n") print nill whenever hex value is above 9. probably because A,B,C,D,E,F cannot be stored in variable/array of type UInt8
            count+=1
            
        }
        hexBytesArray.removeAll(keepingCapacity: true)
        count=0
        /*
         let n = 14
         var st = String(format:"%02X", n)
         st += " is the hexadecimal representation of \(n)"
         print(st) //0E is the hexadecimal representation of 14
         */
        //sample voltage value receiver based on visibility value ---------ENDS HERE
        
    }//func InitiatePressed()
    
    func readFIL(){
        
        DispatchQueue.global(qos: .background).async {
            
            //create an instance of Objective C class
            let instanceOfparser: parser = parser()
            //declare variables for use with printing or database comparisons
            //            var swiftGPS_Lat: Float? = Optional.none
            //            var swiftGPS_Long:Float? = Optional.none
            //            var swiftGround_speed:CInt? = Optional.none
            var swiftGPS_VSI:CShort? = Optional.none
            //var swiftGPS_heading:CInt? //Use Yaw value for heading instead of this
            var swiftGeo_Altitude:CInt? = Optional.none
            var swiftMSL_Altitude:CInt? = Optional.none
            var swiftFirmware_version:Float? = Optional.none
            var swiftBattPct:CInt? = Optional.none
            var swiftRoll:Float? = Optional.none
            var swiftPitch:Float? = Optional.none
            var swiftYaw:Float? = Optional.none //yaw = Heading
            var swiftAirspeedKnots:CInt? = Optional.none
            //var swiftAltitudeFeet:CInt? //use Geo Altitude instead of this
            var swiftVsiFtPerMin:CInt? = Optional.none
            
            var bytesToBeSentArray: [String] = [] //gets elements inserted at the beginning of while loop and EACH ELEMENT MUST BE REMOVED AT THE END OF EACH WHILE ITERATION
            
            
            
            var continueReceiving : Int = 0//variable to check whether to receive data from AHRS device or not
            if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
            {
                continueReceiving  = 10
            }
            /* Database structure placed here just for reference:
             struct K {
             static let batteryPercentage = "Battery_Per"
             static let ManualVisibility = "Manual_Visibility"
             static let altitudeSS = "Altitude_SS"
             static let rodSS = "Rate_Decent_SS"
             static let minRollSS = "Min_Roll"
             static let minPitchSS = "Min_Pitch"
             static let maxRollSS = "Max_Roll"
             static let maxPitchSS = "Max_Pitch"
             }
             */
            //creation of while loop for receiving UDP packets
            //var noOfIterations = 10000 Now using startReceiver value of 10 to start receiving
            while (continueReceiving == 10) //10 is treated as a true
            {
                //append 'IPAD' hex code bytes to the array for microcontroller here.
                //                bytesToBeSentArray.append(0x49)//HEX for I    These could be used if byteToBeSentArray
                //                bytesToBeSentArray.append(0x50)//HEX for P    was being reset or destroyed at the end of
                //                bytesToBeSentArray.append(0x41)//HEX for A    each while iteration.
                //                bytesToBeSentArray.append(0x44)//HEX for D
                // self.bytesToBeSentArray.insert("0D",at:0) //DCBA is the iPad's identifier
                // self.bytesToBeSentArray.insert("0C",at:1)
                //  self.bytesToBeSentArray.insert("0B",at:2)
                //  self.bytesToBeSentArray.insert("0A",at:3)
                
                bytesToBeSentArray.insert("0D",at:0) //DCBA is the iPad's identifier
                bytesToBeSentArray.insert("0C",at:1)
                bytesToBeSentArray.insert("0B",at:2)
                bytesToBeSentArray.insert("0A",at:3)
                //PROBLEM HERE. THIS IS ONLY PRINTING PITCH AND ROLL ONCE. MAY BE BECAUSE ALTERING THE PROEPRTY VALUE OF AN OBJECT IS NOT ALLOWED. EDIT: it was solved through closing of socket at the end of msgReceiver() function in parser.m file.
                //print("inside while loop")
                instanceOfparser.msgReceiver() // do this as long as app is actively running
                //try setting instanceOfparser.pitch value to be new 'instanceOfparser.pitch' here.
                print("\nReturned from msgReceiver func\n")
                //printing ObjectiveC properties value for test
                //print("myPitch:\(instanceOfparser.pitch)") //test
                //print("myRoll:\(instanceOfparser.roll)") //test
                
                //setting ObjectiveC property values to swift variables for usage with database and application.
                //Instead of print function, you can call a comparing method on the swift variables
                //                swiftGPS_Lat = instanceOfparser.gps_Lat
                //                if (swiftGPS_Lat == nil){
                //                    //do nothing
                //                }else{
                //                    print("Lat = \(swiftGPS_Lat!)")
                //                    //call caliberation display function
                //                    //call comparing function to database values
                //                }
                //                swiftGPS_Long = instanceOfparser.gps_Long
                //                if (swiftGPS_Long == nil){
                //                    //do nothing
                //                }else{
                //                    print("Long = \(swiftGPS_Long!)")
                //                }
                //                swiftGround_speed = instanceOfparser.ground_speed
                //                if (swiftGround_speed == nil || swiftGround_speed == 4095){
                //                    //do nothing
                //                }else{
                //                    print("Ownship 0x0A Horizontal Velocity = \(swiftGround_speed!)")//this is displayed as Ground Speed under GPS section in iLevil AHRS Utility App
                //                }
                
                /*------------------------------------SAFETY SETTING CHECKING---------------------------------------*/
                
                // Roll
                //1. Bring Roll from iLevil
                //2. Bring Roll from Database
                //3. Compare these two
                //(optional) Test Print what to do based on comparison results
                //4. Call the emergencyMsgSender() if Roll exceeds limits
                swiftRoll = instanceOfparser.roll
                if (swiftRoll == nil){
                    //do nothing
                }else
                {
                    print("Roll = \(swiftRoll!)")
                    let tempFR = swiftRoll! //is this a Float?
                    let tempSR = Float(tempFR) //if tempF is already a float, we do not need tempS
                    // DispatchQueue.main.async
                    //{
                    self.valueReceived = tempSR
                    //the following needs to run constantly in a loop as long as Manual Training is in progress
                    let temp1R = db.integer(forKey: K.maxRollSS)
                    //var altitudeFSS = db.integer(forKey: K.altitudeSS)
                    
                    print("Roll Max from Safety Setting: \(temp1R)")
                    
                    let temp2R = db.integer(forKey: K.minRollSS)
                    print("Roll Min from Safety Setting: \(temp2R)")
                    
                    if self.valueReceived > Float(temp1R)
                    {
                        print("Flip the visor")
                        //append 5th byte as hex
                        bytesToBeSentArray.insert("01",at:4)//HEX 01 = 1 in decimal
                        
                        bytesToBeSentArray.insert("00", at: 5)//manual immediate adjustment of the display
                        
                        bytesToBeSentArray.insert("00", at: 6)//
                        bytesToBeSentArray.insert("00", at: 7)//voltage value of MAX for clearing out visor when flipping it up
                        bytesToBeSentArray.insert("E4", at: 8)//
                        
                        //send bytesToBeSentArray to microcontroller
                        
                        
                        
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45 //this is to be checked as a 69 decimal
                        print("instanceOfparser.msgForMicrocontroller is: \(instanceOfparser.msgForMicrocontroller)")
                        
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00 //this can be done at the end of each iteration just before while loop bracket close
                        
                        //abort the training if visor flipped.
                        //Abort the training here instead of removing this byte
                        //self.abortOnFlipUp = true
                        //if (self.abortOnFlipUp)
                        // {
                        //                       self.abortTraining() //when this function is called, Show notification on screen that training has stopped because safety limits exceeded. Also, Change the Initiate/Abort button title to Initiate.
                        // }
                        
                        self.startReceiver = 0//prevents the while loop from running again when it breaks in next line. This is to make sure that now while loop can only run if "Initiate" titled button is pressed again.
                        
                        instanceOfparser.closeUDPsocket()//close the network socket otherwise next time even if Initiate button is pressed, we'll get stuck at recvfrom() call in parser.m
                        break //break while loop.
                        
                        //bytesToBeSentArray.remove(at: 4)//This should exist until Abort training function is implemented. That function will append the necessary remaining bytes after the fourth index and send the flip-up message to microcontroller. This statement exists because otherwise anotehr byte will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }
                    else if self.valueReceived < Float(temp2R)
                    {
                        print("Flip the visor")
                        //append 5th byte as ASCII 1 = 31 in HEX
                        bytesToBeSentArray.insert("01",at:4)//HEX 31 = ASCII 1
                        
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45 //this is to be checked as a 69 decimal
                        print("instanceOfparser.msgForMicrocontroller is: \(instanceOfparser.msgForMicrocontroller)")
                        
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00 //this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        //                       self.abortTraining() //when this function is called, Show notification on screen that training has stopped because safety limits exceeded. Also, Change the Initiate/Abort button title to Initiate.
                        // }
                        
                        self.startReceiver = 0//prevents the while loop from running again when it breaks in next line. This is to make sure that now while loop can only run if "Initiate" titled button is pressed again.
                        instanceOfparser.closeUDPsocket()//close the network socket otherwise next time even if Initiate button is pressed, we'll get stuck at recvfrom() call in parser.m
                        break //break while loop.
                        
                        //bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }
                    else
                    {
                        print("Do not Flip the visor")
                        //this is the first time 4th index and 5th index bytes are being appended. no need to remove pre-existing 4 and 5th index bytes here.
                        //append 5th byte as hex
                        bytesToBeSentArray.insert("00", at:4)//HEX 00 will mean DO NOT FLIP VISOR
                        
                        // bytesToBeSentArray.insert("00", at:5)//manual immediate adjustment of the display
                        bytesToBeSentArray.append("00")//manual immediate adjustment of the display. can be changed to insert for consistency. this is index 5.
                        print("4th index has:\(bytesToBeSentArray[4])")
                        print("5th index has:\(bytesToBeSentArray[5])")
                        
                    }
                    
                    //}
                }//else for Roll check
                
                //Pitch
                //1. Bring Pitch from iLevil
                //2. Bring Pitch from Database
                //3. Compare these two
                //(optional) Test Print what to do based on comparison results
                //4. Call the emergencyMsgSender() if Pitch exceeds limits
                swiftPitch = instanceOfparser.pitch
                if (swiftPitch == nil){
                    //do nothing
                }else
                {
                    print("\nPitch = \(swiftPitch!)")
                    let tempFP = swiftPitch! //is this a Float?
                    let tempSP = Float(tempFP) //if tempF is already a float, we do not need tempS
                    //  DispatchQueue.main.async
                    // {
                    self.valueReceived = tempSP
                    //the following needs to run constantly in a loop as long as Manual Training is in progress
                    let temp1P = db.integer(forKey: K.maxPitchSS)
                    print("Pitch Max from Safety Setting: \(temp1P)")
                    //var altitudeFSS = db.integer(forKey: K.altitudeSS)
                    
                    let temp2P = db.integer(forKey: K.minPitchSS)
                    print("Pitch Min from Safety Setting: \(temp2P)")
                    
                    if self.valueReceived > Float(temp1P)
                    {
                        print("Flip the visor")
                        //append 5th byte as ASCII 1 = 31 in HEX
                        bytesToBeSentArray.insert("01",at:4)//HEX 31 = ASCII 1
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00//this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        //abort the training if visor flipped.
                        //                      self.abortTraining() //when this function is called, Show notification on screen that training has stopped because safety limits exceeded. Also, Change the Initiate/Abort button title to Initiate.
                        // }
                        
                        self.startReceiver = 0//prevents the while loop from running again when it breaks in next line. This is to make sure that now while loop can only run if "Initiate" titled button is pressed again.
                        instanceOfparser.closeUDPsocket()//close the network socket otherwise next time even if Initiate button is pressed, we'll get stuck at recvfrom() call in parser.m
                        break //break while loop.
                        
                        // bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }
                    else if self.valueReceived < Float(temp2P)
                    {
                        print("Flip the visor")
                        //append 5th byte as ASCII 1 = 31 in HEX
                        bytesToBeSentArray.insert("01",at:4)//HEX 31 = ASCII 1
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00//this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        //abort the training if visor flipped.
                        //                      self.abortTraining() //when this function is called, Show notification on screen that training has stopped because safety limits exceeded. Also, Change the Initiate/Abort button title to Initiate.
                        // }
                        
                        self.startReceiver = 0//prevents the while loop from running again when it breaks in next line. This is to make sure that now while loop can only run if "Initiate" titled button is pressed again.
                        instanceOfparser.closeUDPsocket()//close the network socket otherwise next time even if Initiate button is pressed, we'll get stuck at recvfrom() call in parser.m
                        break //break while loop.
                        
                        // bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }
                    else
                    {
                        print("Do not Flip the visor")
                        //first remove the 4th and 5th index byte and then re-append. This prevents multiple instances of normal functioning bytes in the consecutive array cells.
                        bytesToBeSentArray.removeSubrange(4...5)
                        //                        if (bytesToBeSentArray[4] == "00" && bytesToBeSentArray[5] == "00")
                        //                        {
                        //                            bytesToBeSentArray.remove(at: 4)
                        //                            bytesToBeSentArray.remove(at: 5)
                        //                        }
                        
                        
                        //re-append
                        //append 4 and 5 index byte as hex
                        bytesToBeSentArray.insert("00",at:4)//HEX 00 will mean DO NOT FLIP VISOR
                        bytesToBeSentArray.insert("00", at: 5)//manual immediate adjustment of the display
                    }
                    
                }
                
                //Rate of Descent
                //1. Bring Vertical Speed from iLevil
                //2. Bring Rate of Descent from Database
                //3. Compare these two
                //(optional) Test Print what to do based on comparison results
                //4. Call the emergencyMsgSender() if Vertical Speed exceeds Rate of Descent limit
                swiftGPS_VSI = instanceOfparser.gps_VSI //gps_VSI is a short int
                if (swiftGPS_VSI == nil){
                    //do nothing
                }else{
                    print("Ownship 0x0A Vertical Velocity = \(swiftGPS_VSI!)") //This is displayed as VSI under GPS section in iLevil AHRS Utility App
                    let tempFVS = swiftGPS_VSI! //is this a Float?
                    let tempSVS = Int(tempFVS) //if tempF is already a float, we do not need tempS
                    // DispatchQueue.main.async
                    //{
                    self.valueReceivedasSigned = tempSVS
                    //the following needs to run constantly in a loop as long as Manual Training is in progress
                    let temp1VS = db.integer(forKey: K.rodSS)
                    //var altitudeFSS = db.integer(forKey: K.altitudeSS)
                    
                    print("Rate of Descent from Safety Setting: \(temp1VS)")
                    
                    //test statements start below
                    let tempTest = Int(temp1VS) //just for testing if it prints as a negative number or not when aircraft is going downwards
                    print("Rate of Descent from Safety Setting as INT is: \(tempTest)")//just for testing
                    //test statements ended above
                    
                    if (self.valueReceivedasSigned < Int(temp1VS)) // -1500kts is smaller than -1000kts. But -1500kts is consider a higher speed than -1000kts, that's why i have used smaller than sign in this statement.
                    {
                        print("Flip the visor")
                        //append 5th byte as ASCII 1 = 31 in HEX
                        bytesToBeSentArray.insert("01",at:4)//HEX 31 = ASCII 1
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45 //this is to be checked as a 69 decimal
                        print("instanceOfparser.msgForMicrocontroller is: \(instanceOfparser.msgForMicrocontroller)")
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00 //this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        //abort the training if visor flipped.
                        //                     self.abortTraining() //when this function is called, Show notification on screen that training has stopped because safety limits exceeded. Also, Change the Initiate/Abort button title to Initiate.
                        // }
                        
                        self.startReceiver = 0//prevents the while loop from running again when it breaks in next line. This is to make sure that now while loop can only run if "Initiate" titled button is pressed again.
                        instanceOfparser.closeUDPsocket()//close the network socket otherwise next time even if Initiate button is pressed, we'll get stuck at recvfrom() call in parser.m
                        break //break while loop.
                        
                        //bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }else{
                        print("Do not Flip the visor")
                        //first remove the 4th and 5th index byte and then re-append. This prevents multiple instances of normal functioning bytes in the consecutive array cells.
                        bytesToBeSentArray.removeSubrange(4...5)
                        //re-append
                        //append 4 and 5 index byte as hex
                        bytesToBeSentArray.insert("00", at:4)//HEX 00 will mean DO NOT FLIP VISOR
                        
                        bytesToBeSentArray.insert("00", at:5)//manual immediate adjustment of the display
                    }
                    //abort the training if visor flipped.
                }
                
                
                
                
                /* swiftGPS_heading = instanceOfparser.gps_heading //USE YAW VALUE FOR HEADING. DO NOT USE GPS HEADING.
                 if swiftGPS_heading != nil {
                 print("Heading =\(String(describing: swiftGPS_heading))")
                 }*/
                //                swiftGeo_Altitude = instanceOfparser.geo_Altitude
                //                if (swiftGeo_Altitude == nil || swiftGeo_Altitude == 0){
                //                    //do nothing
                //                }else{
                //                    print("Geo Altitude = \(swiftGeo_Altitude!)")
                //                }
                //
                //MSL Altitude
                //1. Bring MSL Altitude from iLevil
                //2. Bring Altitude limit from Database
                //3. Check if MSL Altitude had passed above altitude limit and trigger was set to 1
                //4. See if MSL Altitude has gone below the specified limit after going above the limit
                //(optional) Test Print what to do based on comparison results
                //5. Call the emergencyMsgSender() if needed
                swiftMSL_Altitude = instanceOfparser.mslAltitude                    //newly added for mslAltitude
                if(swiftMSL_Altitude == nil || swiftMSL_Altitude == 0 || swiftMSL_Altitude == 4095 || swiftMSL_Altitude == 20475)
                {
                    //do nothing
                }else
                {
                    print("MSL Altitude = \(swiftMSL_Altitude!)")
                    
                    let altitudeFSS = db.integer(forKey: K.altitudeSS)//bring safety altitude limit from database
                    if((swiftMSL_Altitude!) > Int(altitudeFSS))
                    {
                        self.altitudeSafetyTrigger = 1
                    }
                    
                    if (self.altitudeSafetyTrigger == 1 && (swiftMSL_Altitude!) < Int(altitudeFSS))//subtract a 10 or a 50 from Int(altitudeFSS) inside this check if you want to make sure that the visor does not flip just as it passes over the safety altitude. That will ensure that anomalous flip up due to altitude is avoided. This issue however is unlikely to happen often
                    {
                        print("Flip the visor - Aircraft below safe altitude")
                        //append 5th byte as 1
                        bytesToBeSentArray.insert("01",at:4)//HEX
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45 //i can always use this technique for appending bytes to the uint8_t type objective c properties. copying those in a byte array inside msgSender() function and finally send it. So, to use this way, first) i have to create 'no of bytes to be appended and sent to microcontroller' objective c properties. second) set these objective c properties to be equal to a sequential indexes of bytesToBeSentArray. third) i ll then just copy the properties one by one into an objective c byte array[] -which exists inside msgSender(). And then just send that objective c array like normal as i already have been sending 0x45 over to microcontroller. EDIT: NOT NEEDED NOW. WE HAVE SUCCESSFULLY STORES A STRING SWIFT ARRAY INTO A NSSTRING OBJECTIVE-C ARRAY
                        print("instanceOfparser.msgForMicrocontroller is: \(instanceOfparser.msgForMicrocontroller)")
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00 //this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        //abort the training if visor flipped.
                        //                     self.abortTraining() //when this function is called, Show notification on screen that training has stopped because safety limits exceeded. Also, Change the Initiate/Abort button title to Initiate.
                        // }
                        
                        self.startReceiver = 0//prevents the while loop from running again when it breaks in next line. This is to make sure that now while loop can only run if "Initiate" titled button is pressed again.
                        instanceOfparser.closeUDPsocket()//close the network socket otherwise next time even if Initiate button is pressed, we'll get stuck at recvfrom() call in parser.m
                        break //break while loop.
                        
                        //bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }
                    
                    //following statements are for appending normal functioning of aircraft bytes. They not inside an else for a reason. let them stay as is. If put inside else, they might not run even if altitude trigger was normally set to 1 and we didnt need to flip the visor - in which case normal bytes are to be appended.
                    //first remove the 4th and 5th index byte and then re-append. This prevents multiple instances of normal functioning bytes in the consecutive array cells.
                    bytesToBeSentArray.removeSubrange(4...5)
                    //re-append
                    //append 4 and 5 index byte as hex
                    bytesToBeSentArray.insert("00", at:4)//HEX 00 will mean DO NOT FLIP VISOR
                    bytesToBeSentArray.insert("00", at:5)//manual immediate adjustment of the display
                    
                }
                
                //Manual Visiblity and Ceiling implementation. Also checks for MSL Altitude and ceiling distance and reacts according.
                //1.
                //2.
                //3.
                //(optional)
                //4.Send the voltage value to microcontroller (append the HEX bytes for voltage value to bytesToBeSentArray)
                if(swiftMSL_Altitude == nil || swiftMSL_Altitude == 0 || swiftMSL_Altitude == 4095 || swiftMSL_Altitude == 20475) //add a check for negative altitude as well.
                {
                    //do nothing
                    print("\nNo Altitude Information received from AHRS device. Cannot run manual visibility and ceiling functionality.\n")
                }else
                {
                    /*
                     For operation modes:
                     0-Manual disregards the time to reach input and will immediately set the display to the sent value (The time parameter should still be filled with an ASCII value ie. 0000).
                     
                     1- Is to ramp the current display value to the desired display value over the time to reach the parameter.
                     */
                    
                    //REMEMBER TO REMOVE THE BYTES FROM 5,6,7,and 8th INDEX OF bytesToBeSentArray WHICH ARE APPENDED BELOW. It should not stay at 0x01 in next iteration unless new logic is developed that requires otherwise.
                    bytesToBeSentArray.insert("01",at:5)//HEX 01 = Decimal 01 to select mode of opacity change over time instead of sudden change
                    print("\nMSL Altitude received for manual functionality. Sending simulations now\n")
                    //bring values from database and manual page sliders
                    let manualVisFromSlider = db.float(forKey: K.ManualVisibility) //get slider visibility from database
                    let sliderVis = Float(manualVisFromSlider) //to be used in IF/ELSE statements
                    let manualCeilFromSlider = db.integer(forKey: K.ManualCeiling) //get slider ceiling from database
                    let sliderCeil = Int(manualCeilFromSlider) //to be used in IF/ELSE statements
                    let mslAltitude = Int(swiftMSL_Altitude!) //get current MSL Altitude of aircraft
                    //no change in vis
                    if((sliderCeil - mslAltitude) >= 100)//aircraft not within 100 ft of cloud ceiling
                    {
                        let voltsTranslation = self.visiblityToVoltage(v: sliderVis )//sliderVis is sent as is in this case
                        print("Volts to send are: \(voltsTranslation)")
                        let voltsToSend = Int(voltsTranslation*10)
                        let voltHexByteUpperCase = String(format:"%02X", voltsToSend)
                        
                        bytesToBeSentArray.insert("00",at:6)
                        bytesToBeSentArray.insert("00",at:7)
                        bytesToBeSentArray.insert(voltHexByteUpperCase,at:8)
                        //---------------Appending necessary bytes after voltage byte----------
                        //append 'time to reach', 'MaxRoll limit', 'MaxPitch limit' bytes at the 9,10,11 indexes
                        //1.time to reach //since we re sending only 1 second for time to change, probably dont need to convert this to HEX.
                        bytesToBeSentArray.insert("00", at:9) //9th index
                        bytesToBeSentArray.insert("00", at:10) //10th index
                        bytesToBeSentArray.insert("00", at:11) //11th index
                        bytesToBeSentArray.insert("01", at:12) //12th index take one second to change to given voltage
                        //2. MaxRoll limit
                        let rollLimitForMicrocontroller = Int8(db.integer(forKey: K.maxRollSS))
                        let rollHexByteUpperCase = String(format:"%02X", rollLimitForMicrocontroller)
                        let stringTypeHexRollLimitForMicrocontroller = String(rollHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:13)//13th index
                        bytesToBeSentArray.insert("00", at:14)//14th index
                        bytesToBeSentArray.insert(stringTypeHexRollLimitForMicrocontroller, at:15)//15th index
                        //3. MaxPitch Limit
                        let pitchLimitForMicrocontroller = Int8(db.integer(forKey: K.maxPitchSS))
                        let pitchHexByteUpperCase = String(format:"%02X", pitchLimitForMicrocontroller)
                        let stringTypeHexPitchLimitForMicrocontroller = String(pitchHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:16)//16th index
                        bytesToBeSentArray.insert("00", at:17)//17th index
                        bytesToBeSentArray.insert(stringTypeHexPitchLimitForMicrocontroller, at:18) //18th index
                        //--------------Storing swift array into objective-c array
                        //store the swift array bytes into objective-c NSString array
                        var count: UInt8 = 0
                        for bytes in bytesToBeSentArray{
                            instanceOfparser.manualNormalMsgBytes.append(bytes) // OR instanceOfparser.emgMsgBytes.append(bytesToBeSentArray[count])
                            print(instanceOfparser.manualNormalMsgBytes) //test print
                            count+=1 //not needed unless i decide to use or send the number of hex bytes appended to emgMsgBytes
                            print("\nHey\n") //test print
                        }
                        count -= 1 //After this statement run, count will have number of bytes appended. Use if needed
                        print("No of bytes appended = \(count)")
                        print(instanceOfparser.manualNormalMsgBytes) //print what was stored in the array
                        //------------------Sending objective-c array as parameter to msgSender() function.
                        //send the above array to msg sender function and remember to reset it and the end of every while loop iteration
                        instanceOfparser.normalMsgSender(instanceOfparser.manualNormalMsgBytes, ofSize:count)
                        
                        //clean up msg bytes after sending over network
                        instanceOfparser.manualNormalMsgBytes.removeAll(keepingCapacity: true)//remove all bytes for storing new oens in next iteration
                    }
                        
                        
                        
                        
                        //reduce vis to 87% of slider visibility
                    else if( (sliderCeil - mslAltitude) < 100 && (sliderCeil - mslAltitude) >= 87)
                    {
                        let decreasedVis = sliderVis * 0.87
                        let voltsTranslation = self.visiblityToVoltage(v: decreasedVis )//sliderVis is sent as is in this case
                        print("Volts to send are: \(voltsTranslation)")
                        let voltsToSend = Int(voltsTranslation*10)
                        let voltHexByteUpperCase = String(format:"%02X", voltsToSend)
                        
                        bytesToBeSentArray.insert("00",at:6)
                        bytesToBeSentArray.insert("00",at:7)
                        bytesToBeSentArray.insert(voltHexByteUpperCase,at:8)
                        //---------------Appending necessary bytes after voltage byte----------
                        //append 'time to reach', 'MaxRoll limit', 'MaxPitch limit' bytes at the 9,10,11 indexes
                        //1.time to reach //since we re sending only 1 second for time to change, probably dont need to convert this to HEX.
                        bytesToBeSentArray.insert("00", at:9) //9th index
                        bytesToBeSentArray.insert("00", at:10) //10th index
                        bytesToBeSentArray.insert("00", at:11) //11th index
                        bytesToBeSentArray.insert("01", at:12) //12th index take one second to change to given voltage
                        //2. MaxRoll limit
                        let rollLimitForMicrocontroller = Int8(db.integer(forKey: K.maxRollSS))
                        let rollHexByteUpperCase = String(format:"%02X", rollLimitForMicrocontroller)
                        let stringTypeHexRollLimitForMicrocontroller = String(rollHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:13)//13th index
                        bytesToBeSentArray.insert("00", at:14)//14th index
                        bytesToBeSentArray.insert(stringTypeHexRollLimitForMicrocontroller, at:15)//15th index
                        //3. MaxPitch Limit
                        let pitchLimitForMicrocontroller = Int8(db.integer(forKey: K.maxPitchSS))
                        let pitchHexByteUpperCase = String(format:"%02X", pitchLimitForMicrocontroller)
                        let stringTypeHexPitchLimitForMicrocontroller = String(pitchHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:16)//16th index
                        bytesToBeSentArray.insert("00", at:17)//17th index
                        bytesToBeSentArray.insert(stringTypeHexPitchLimitForMicrocontroller, at:18) //18th index
                        //--------------Storing swift array into objective-c array
                        //store the swift array bytes into objective-c NSString array
                        var count: UInt8 = 0
                        for bytes in bytesToBeSentArray{
                            instanceOfparser.manualNormalMsgBytes.append(bytes) // OR instanceOfparser.emgMsgBytes.append(bytesToBeSentArray[count])
                            print(instanceOfparser.manualNormalMsgBytes) //test print
                            count+=1 //not needed unless i decide to use or send the number of hex bytes appended to emgMsgBytes
                            print("\nHey\n") //test print
                        }
                        count -= 1 //After this statement run, count will have number of bytes appended. Use if needed
                        print("No of bytes appended = \(count)")
                        print(instanceOfparser.manualNormalMsgBytes) //print what was stored in the array
                        //------------------Sending objective-c array as parameter to msgSender() function.
                        //send the above array to msg sender function and remember to reset it and the end of every while loop iteration
                        instanceOfparser.normalMsgSender(instanceOfparser.manualNormalMsgBytes, ofSize:count)
                        
                        //clean up msg bytes after sending over network
                        instanceOfparser.manualNormalMsgBytes.removeAll(keepingCapacity: true)//remove all bytes for storing new oens in next iteration
                    }
                        //reduce vis to 75% of slider visibility
                    else if( (sliderCeil - mslAltitude) < 87 && (sliderCeil - mslAltitude) >= 75)
                    {
                        let decreasedVis = sliderVis * 0.75
                        let voltsTranslation = self.visiblityToVoltage(v: decreasedVis )//sliderVis is sent as is in this case
                        print("Volts to send are: \(voltsTranslation)")
                        let voltsToSend = Int(voltsTranslation*10)
                        let voltHexByteUpperCase = String(format:"%02X", voltsToSend)
                        
                        bytesToBeSentArray.insert("00",at:6)
                        bytesToBeSentArray.insert("00",at:7)
                        bytesToBeSentArray.insert(voltHexByteUpperCase,at:8)
                        //---------------Appending necessary bytes after voltage byte----------
                        //append 'time to reach', 'MaxRoll limit', 'MaxPitch limit' bytes at the 9,10,11 indexes
                        //1.time to reach //since we re sending only 1 second for time to change, probably dont need to convert this to HEX.
                        bytesToBeSentArray.insert("00", at:9) //9th index
                        bytesToBeSentArray.insert("00", at:10) //10th index
                        bytesToBeSentArray.insert("00", at:11) //11th index
                        bytesToBeSentArray.insert("01", at:12) //12th index take one second to change to given voltage
                        //2. MaxRoll limit
                        let rollLimitForMicrocontroller = Int8(db.integer(forKey: K.maxRollSS))
                        let rollHexByteUpperCase = String(format:"%02X", rollLimitForMicrocontroller)
                        let stringTypeHexRollLimitForMicrocontroller = String(rollHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:13)//13th index
                        bytesToBeSentArray.insert("00", at:14)//14th index
                        bytesToBeSentArray.insert(stringTypeHexRollLimitForMicrocontroller, at:15)//15th index
                        //3. MaxPitch Limit
                        let pitchLimitForMicrocontroller = Int8(db.integer(forKey: K.maxPitchSS))
                        let pitchHexByteUpperCase = String(format:"%02X", pitchLimitForMicrocontroller)
                        let stringTypeHexPitchLimitForMicrocontroller = String(pitchHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:16)//16th index
                        bytesToBeSentArray.insert("00", at:17)//17th index
                        bytesToBeSentArray.insert(stringTypeHexPitchLimitForMicrocontroller, at:18) //18th index
                        //--------------Storing swift array into objective-c array
                        //store the swift array bytes into objective-c NSString array
                        var count: UInt8 = 0
                        for bytes in bytesToBeSentArray{
                            instanceOfparser.manualNormalMsgBytes.append(bytes) // OR instanceOfparser.emgMsgBytes.append(bytesToBeSentArray[count])
                            print(instanceOfparser.manualNormalMsgBytes) //test print
                            count+=1 //not needed unless i decide to use or send the number of hex bytes appended to emgMsgBytes
                            print("\nHey\n") //test print
                        }
                        count -= 1 //After this statement run, count will have number of bytes appended. Use if needed
                        print("No of bytes appended = \(count)")
                        print(instanceOfparser.manualNormalMsgBytes) //print what was stored in the array
                        //------------------Sending objective-c array as parameter to msgSender() function.
                        //send the above array to msg sender function and remember to reset it and the end of every while loop iteration
                        instanceOfparser.normalMsgSender(instanceOfparser.manualNormalMsgBytes, ofSize:count)
                        
                        //clean up msg bytes after sending over network
                        instanceOfparser.manualNormalMsgBytes.removeAll(keepingCapacity: true)//remove all bytes for storing new oens in next iteration
                    }
                        //reduce vis to 62% of slider visibility
                    else if( (sliderCeil - mslAltitude) < 75 && (sliderCeil - mslAltitude) >= 62)
                    {
                        let decreasedVis = sliderVis * 0.62
                        let voltsTranslation = self.visiblityToVoltage(v: decreasedVis )//sliderVis is sent as is in this case
                        print("Volts to send are: \(voltsTranslation)")
                        let voltsToSend = Int(voltsTranslation*10)
                        let voltHexByteUpperCase = String(format:"%02X", voltsToSend)
                        
                        bytesToBeSentArray.insert("00",at:6)
                        bytesToBeSentArray.insert("00",at:7)
                        bytesToBeSentArray.insert(voltHexByteUpperCase,at:8)
                        //---------------Appending necessary bytes after voltage byte----------
                        //append 'time to reach', 'MaxRoll limit', 'MaxPitch limit' bytes at the 9,10,11 indexes
                        //1.time to reach //since we re sending only 1 second for time to change, probably dont need to convert this to HEX.
                        bytesToBeSentArray.insert("00", at:9) //9th index
                        bytesToBeSentArray.insert("00", at:10) //10th index
                        bytesToBeSentArray.insert("00", at:11) //11th index
                        bytesToBeSentArray.insert("01", at:12) //12th index take one second to change to given voltage
                        //2. MaxRoll limit
                        let rollLimitForMicrocontroller = Int8(db.integer(forKey: K.maxRollSS))
                        let rollHexByteUpperCase = String(format:"%02X", rollLimitForMicrocontroller)
                        let stringTypeHexRollLimitForMicrocontroller = String(rollHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:13)//13th index
                        bytesToBeSentArray.insert("00", at:14)//14th index
                        bytesToBeSentArray.insert(stringTypeHexRollLimitForMicrocontroller, at:15)//15th index
                        //3. MaxPitch Limit
                        let pitchLimitForMicrocontroller = Int8(db.integer(forKey: K.maxPitchSS))
                        let pitchHexByteUpperCase = String(format:"%02X", pitchLimitForMicrocontroller)
                        let stringTypeHexPitchLimitForMicrocontroller = String(pitchHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:16)//16th index
                        bytesToBeSentArray.insert("00", at:17)//17th index
                        bytesToBeSentArray.insert(stringTypeHexPitchLimitForMicrocontroller, at:18) //18th index
                        //--------------Storing swift array into objective-c array
                        //store the swift array bytes into objective-c NSString array
                        var count: UInt8 = 0
                        for bytes in bytesToBeSentArray{
                            instanceOfparser.manualNormalMsgBytes.append(bytes) // OR instanceOfparser.emgMsgBytes.append(bytesToBeSentArray[count])
                            print(instanceOfparser.manualNormalMsgBytes) //test print
                            count+=1 //not needed unless i decide to use or send the number of hex bytes appended to emgMsgBytes
                            print("\nHey\n") //test print
                        }
                        count -= 1 //After this statement run, count will have number of bytes appended. Use if needed
                        print("No of bytes appended = \(count)")
                        print(instanceOfparser.manualNormalMsgBytes) //print what was stored in the array
                        //------------------Sending objective-c array as parameter to msgSender() function.
                        //send the above array to msg sender function and remember to reset it and the end of every while loop iteration
                        instanceOfparser.normalMsgSender(instanceOfparser.manualNormalMsgBytes, ofSize:count)
                        
                        //clean up msg bytes after sending over network
                        instanceOfparser.manualNormalMsgBytes.removeAll(keepingCapacity: true)//remove all bytes for storing new oens in next iteration
                    }
                        //reduce vis to 50% of slider visibility
                    else if( (sliderCeil - mslAltitude) < 62 && (sliderCeil - mslAltitude) >= 50)
                    {
                        let decreasedVis = sliderVis * 0.50
                        let voltsTranslation = self.visiblityToVoltage(v: decreasedVis )//sliderVis is sent as is in this case
                        print("Volts to send are: \(voltsTranslation)")
                        let voltsToSend = Int(voltsTranslation*10)
                        let voltHexByteUpperCase = String(format:"%02X", voltsToSend)
                        
                        bytesToBeSentArray.insert("00",at:6)
                        bytesToBeSentArray.insert("00",at:7)
                        bytesToBeSentArray.insert(voltHexByteUpperCase,at:8)
                        //---------------Appending necessary bytes after voltage byte----------
                        //append 'time to reach', 'MaxRoll limit', 'MaxPitch limit' bytes at the 9,10,11 indexes
                        //1.time to reach //since we re sending only 1 second for time to change, probably dont need to convert this to HEX.
                        bytesToBeSentArray.insert("00", at:9) //9th index
                        bytesToBeSentArray.insert("00", at:10) //10th index
                        bytesToBeSentArray.insert("00", at:11) //11th index
                        bytesToBeSentArray.insert("01", at:12) //12th index take one second to change to given voltage
                        //2. MaxRoll limit
                        let rollLimitForMicrocontroller = Int8(db.integer(forKey: K.maxRollSS))
                        let rollHexByteUpperCase = String(format:"%02X", rollLimitForMicrocontroller)
                        let stringTypeHexRollLimitForMicrocontroller = String(rollHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:13)//13th index
                        bytesToBeSentArray.insert("00", at:14)//14th index
                        bytesToBeSentArray.insert(stringTypeHexRollLimitForMicrocontroller, at:15)//15th index
                        //3. MaxPitch Limit
                        let pitchLimitForMicrocontroller = Int8(db.integer(forKey: K.maxPitchSS))
                        let pitchHexByteUpperCase = String(format:"%02X", pitchLimitForMicrocontroller)
                        let stringTypeHexPitchLimitForMicrocontroller = String(pitchHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:16)//16th index
                        bytesToBeSentArray.insert("00", at:17)//17th index
                        bytesToBeSentArray.insert(stringTypeHexPitchLimitForMicrocontroller, at:18) //18th index
                        //--------------Storing swift array into objective-c array
                        //store the swift array bytes into objective-c NSString array
                        var count: UInt8 = 0
                        for bytes in bytesToBeSentArray{
                            instanceOfparser.manualNormalMsgBytes.append(bytes) // OR instanceOfparser.emgMsgBytes.append(bytesToBeSentArray[count])
                            print(instanceOfparser.manualNormalMsgBytes) //test print
                            count+=1 //not needed unless i decide to use or send the number of hex bytes appended to emgMsgBytes
                            print("\nHey\n") //test print
                        }
                        count -= 1 //After this statement run, count will have number of bytes appended. Use if needed
                        print("No of bytes appended = \(count)")
                        print(instanceOfparser.manualNormalMsgBytes) //print what was stored in the array
                        //------------------Sending objective-c array as parameter to msgSender() function.
                        //send the above array to msg sender function and remember to reset it and the end of every while loop iteration
                        instanceOfparser.normalMsgSender(instanceOfparser.manualNormalMsgBytes, ofSize:count)
                        
                        //clean up msg bytes after sending over network
                        instanceOfparser.manualNormalMsgBytes.removeAll(keepingCapacity: true)//remove all bytes for storing new oens in next iteration
                    }
                        //reduce vis to 37% of slider visibility
                    else if( (sliderCeil - mslAltitude) < 50 && (sliderCeil - mslAltitude) >= 37)
                    {
                        let decreasedVis = sliderVis * 0.37
                        let voltsTranslation = self.visiblityToVoltage(v: decreasedVis )//sliderVis is sent as is in this case
                        print("Volts to send are: \(voltsTranslation)")
                        let voltsToSend = Int(voltsTranslation*10)
                        let voltHexByteUpperCase = String(format:"%02X", voltsToSend)
                        
                        bytesToBeSentArray.insert("00",at:6)
                        bytesToBeSentArray.insert("00",at:7)
                        bytesToBeSentArray.insert(voltHexByteUpperCase,at:8)
                        //---------------Appending necessary bytes after voltage byte----------
                        //append 'time to reach', 'MaxRoll limit', 'MaxPitch limit' bytes at the 9,10,11 indexes
                        //1.time to reach //since we re sending only 1 second for time to change, probably dont need to convert this to HEX.
                        bytesToBeSentArray.insert("00", at:9) //9th index
                        bytesToBeSentArray.insert("00", at:10) //10th index
                        bytesToBeSentArray.insert("00", at:11) //11th index
                        bytesToBeSentArray.insert("01", at:12) //12th index take one second to change to given voltage
                        //2. MaxRoll limit
                        let rollLimitForMicrocontroller = Int8(db.integer(forKey: K.maxRollSS))
                        let rollHexByteUpperCase = String(format:"%02X", rollLimitForMicrocontroller)
                        let stringTypeHexRollLimitForMicrocontroller = String(rollHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:13)//13th index
                        bytesToBeSentArray.insert("00", at:14)//14th index
                        bytesToBeSentArray.insert(stringTypeHexRollLimitForMicrocontroller, at:15)//15th index
                        //3. MaxPitch Limit
                        let pitchLimitForMicrocontroller = Int8(db.integer(forKey: K.maxPitchSS))
                        let pitchHexByteUpperCase = String(format:"%02X", pitchLimitForMicrocontroller)
                        let stringTypeHexPitchLimitForMicrocontroller = String(pitchHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:16)//16th index
                        bytesToBeSentArray.insert("00", at:17)//17th index
                        bytesToBeSentArray.insert(stringTypeHexPitchLimitForMicrocontroller, at:18) //18th index
                        //--------------Storing swift array into objective-c array
                        //store the swift array bytes into objective-c NSString array
                        var count: UInt8 = 0
                        for bytes in bytesToBeSentArray{
                            instanceOfparser.manualNormalMsgBytes.append(bytes) // OR instanceOfparser.emgMsgBytes.append(bytesToBeSentArray[count])
                            print(instanceOfparser.manualNormalMsgBytes) //test print
                            count+=1 //not needed unless i decide to use or send the number of hex bytes appended to emgMsgBytes
                            print("\nHey\n") //test print
                        }
                        count -= 1 //After this statement run, count will have number of bytes appended. Use if needed
                        print("No of bytes appended = \(count)")
                        print(instanceOfparser.manualNormalMsgBytes) //print what was stored in the array
                        //------------------Sending objective-c array as parameter to msgSender() function.
                        //send the above array to msg sender function and remember to reset it and the end of every while loop iteration
                        instanceOfparser.normalMsgSender(instanceOfparser.manualNormalMsgBytes, ofSize:count)
                        
                        //clean up msg bytes after sending over network
                        instanceOfparser.manualNormalMsgBytes.removeAll(keepingCapacity: true)//remove all bytes for storing new oens in next iteration
                    }
                        //reduce vis to 25% of slider visibility
                    else if( (sliderCeil - mslAltitude) < 37 && (sliderCeil - mslAltitude) >= 25)
                    {
                        let decreasedVis = sliderVis * 0.25
                        let voltsTranslation = self.visiblityToVoltage(v: decreasedVis )//sliderVis is sent as is in this case
                        print("Volts to send are: \(voltsTranslation)")
                        let voltsToSend = Int(voltsTranslation*10)
                        let voltHexByteUpperCase = String(format:"%02X", voltsToSend)
                        
                        bytesToBeSentArray.insert("00",at:6)
                        bytesToBeSentArray.insert("00",at:7)
                        bytesToBeSentArray.insert(voltHexByteUpperCase,at:8)
                        //---------------Appending necessary bytes after voltage byte----------
                        //append 'time to reach', 'MaxRoll limit', 'MaxPitch limit' bytes at the 9,10,11 indexes
                        //1.time to reach //since we re sending only 1 second for time to change, probably dont need to convert this to HEX.
                        bytesToBeSentArray.insert("00", at:9) //9th index
                        bytesToBeSentArray.insert("00", at:10) //10th index
                        bytesToBeSentArray.insert("00", at:11) //11th index
                        bytesToBeSentArray.insert("01", at:12) //12th index take one second to change to given voltage
                        //2. MaxRoll limit
                        let rollLimitForMicrocontroller = Int8(db.integer(forKey: K.maxRollSS))
                        let rollHexByteUpperCase = String(format:"%02X", rollLimitForMicrocontroller)
                        let stringTypeHexRollLimitForMicrocontroller = String(rollHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:13)//13th index
                        bytesToBeSentArray.insert("00", at:14)//14th index
                        bytesToBeSentArray.insert(stringTypeHexRollLimitForMicrocontroller, at:15)//15th index
                        //3. MaxPitch Limit
                        let pitchLimitForMicrocontroller = Int8(db.integer(forKey: K.maxPitchSS))
                        let pitchHexByteUpperCase = String(format:"%02X", pitchLimitForMicrocontroller)
                        let stringTypeHexPitchLimitForMicrocontroller = String(pitchHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:16)//16th index
                        bytesToBeSentArray.insert("00", at:17)//17th index
                        bytesToBeSentArray.insert(stringTypeHexPitchLimitForMicrocontroller, at:18) //18th index
                        //--------------Storing swift array into objective-c array
                        //store the swift array bytes into objective-c NSString array
                        var count: UInt8 = 0
                        for bytes in bytesToBeSentArray{
                            instanceOfparser.manualNormalMsgBytes.append(bytes) // OR instanceOfparser.emgMsgBytes.append(bytesToBeSentArray[count])
                            print(instanceOfparser.manualNormalMsgBytes) //test print
                            count+=1 //not needed unless i decide to use or send the number of hex bytes appended to emgMsgBytes
                            print("\nHey\n") //test print
                        }
                        count -= 1 //After this statement run, count will have number of bytes appended. Use if needed
                        print("No of bytes appended = \(count)")
                        print(instanceOfparser.manualNormalMsgBytes) //print what was stored in the array
                        //------------------Sending objective-c array as parameter to msgSender() function.
                        //send the above array to msg sender function and remember to reset it and the end of every while loop iteration
                        instanceOfparser.normalMsgSender(instanceOfparser.manualNormalMsgBytes, ofSize:count)
                        
                        //clean up msg bytes after sending over network
                        instanceOfparser.manualNormalMsgBytes.removeAll(keepingCapacity: true)//remove all bytes for storing new oens in next iteration
                    }
                        //reduce vis to 12% of slider visibility
                    else if( (sliderCeil - mslAltitude) < 25 && (sliderCeil - mslAltitude) >= 12)
                    {
                        let decreasedVis = sliderVis * 0.12
                        let voltsTranslation = self.visiblityToVoltage(v: decreasedVis )//sliderVis is sent as is in this case
                        print("Volts to send are: \(voltsTranslation)")
                        let voltsToSend = Int(voltsTranslation*10)
                        let voltHexByteUpperCase = String(format:"%02X", voltsToSend)
                        
                        bytesToBeSentArray.insert("00",at:6)
                        bytesToBeSentArray.insert("00",at:7)
                        bytesToBeSentArray.insert(voltHexByteUpperCase,at:8)
                        //---------------Appending necessary bytes after voltage byte----------
                        //append 'time to reach', 'MaxRoll limit', 'MaxPitch limit' bytes at the 9,10,11 indexes
                        //1.time to reach //since we re sending only 1 second for time to change, probably dont need to convert this to HEX.
                        bytesToBeSentArray.insert("00", at:9) //9th index
                        bytesToBeSentArray.insert("00", at:10) //10th index
                        bytesToBeSentArray.insert("00", at:11) //11th index
                        bytesToBeSentArray.insert("01", at:12) //12th index take one second to change to given voltage
                        //2. MaxRoll limit
                        let rollLimitForMicrocontroller = Int8(db.integer(forKey: K.maxRollSS))
                        let rollHexByteUpperCase = String(format:"%02X", rollLimitForMicrocontroller)
                        let stringTypeHexRollLimitForMicrocontroller = String(rollHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:13)//13th index
                        bytesToBeSentArray.insert("00", at:14)//14th index
                        bytesToBeSentArray.insert(stringTypeHexRollLimitForMicrocontroller, at:15)//15th index
                        //3. MaxPitch Limit
                        let pitchLimitForMicrocontroller = Int8(db.integer(forKey: K.maxPitchSS))
                        let pitchHexByteUpperCase = String(format:"%02X", pitchLimitForMicrocontroller)
                        let stringTypeHexPitchLimitForMicrocontroller = String(pitchHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:16)//16th index
                        bytesToBeSentArray.insert("00", at:17)//17th index
                        bytesToBeSentArray.insert(stringTypeHexPitchLimitForMicrocontroller, at:18) //18th index
                        //--------------Storing swift array into objective-c array
                        //store the swift array bytes into objective-c NSString array
                        var count: UInt8 = 0
                        for bytes in bytesToBeSentArray{
                            instanceOfparser.manualNormalMsgBytes.append(bytes) // OR instanceOfparser.emgMsgBytes.append(bytesToBeSentArray[count])
                            print(instanceOfparser.manualNormalMsgBytes) //test print
                            count+=1 //not needed unless i decide to use or send the number of hex bytes appended to emgMsgBytes
                            print("\nHey\n") //test print
                        }
                        count -= 1 //After this statement run, count will have number of bytes appended. Use if needed
                        print("No of bytes appended = \(count)")
                        print(instanceOfparser.manualNormalMsgBytes) //print what was stored in the array
                        //------------------Sending objective-c array as parameter to msgSender() function.
                        //send the above array to msg sender function and remember to reset it and the end of every while loop iteration
                        instanceOfparser.normalMsgSender(instanceOfparser.manualNormalMsgBytes, ofSize:count)
                        
                        //clean up msg bytes after sending over network
                        instanceOfparser.manualNormalMsgBytes.removeAll(keepingCapacity: true)//remove all bytes for storing new oens in next iteration
                    }
                        //reduce vis to 8% of slider visibility
                    else if( (sliderCeil - mslAltitude) < 12 && (sliderCeil - mslAltitude) > 0)
                    {
                        let decreasedVis = sliderVis * 0.08
                        let voltsTranslation = self.visiblityToVoltage(v: decreasedVis )//sliderVis is sent as is in this case
                        print("Volts to send are: \(voltsTranslation)")
                        let voltsToSend = Int(voltsTranslation*10)
                        let voltHexByteUpperCase = String(format:"%02X", voltsToSend)
                        
                        bytesToBeSentArray.insert("00",at:6)
                        bytesToBeSentArray.insert("00",at:7)
                        bytesToBeSentArray.insert(voltHexByteUpperCase,at:8)
                        //---------------Appending necessary bytes after voltage byte----------
                        //append 'time to reach', 'MaxRoll limit', 'MaxPitch limit' bytes at the 9,10,11 indexes
                        //1.time to reach //since we re sending only 1 second for time to change, probably dont need to convert this to HEX.
                        bytesToBeSentArray.insert("00", at:9) //9th index
                        bytesToBeSentArray.insert("00", at:10) //10th index
                        bytesToBeSentArray.insert("00", at:11) //11th index
                        bytesToBeSentArray.insert("01", at:12) //12th index take one second to change to given voltage
                        //2. MaxRoll limit
                        let rollLimitForMicrocontroller = Int8(db.integer(forKey: K.maxRollSS))
                        let rollHexByteUpperCase = String(format:"%02X", rollLimitForMicrocontroller)
                        let stringTypeHexRollLimitForMicrocontroller = String(rollHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:13)//13th index
                        bytesToBeSentArray.insert("00", at:14)//14th index
                        bytesToBeSentArray.insert(stringTypeHexRollLimitForMicrocontroller, at:15)//15th index
                        //3. MaxPitch Limit
                        let pitchLimitForMicrocontroller = Int8(db.integer(forKey: K.maxPitchSS))
                        let pitchHexByteUpperCase = String(format:"%02X", pitchLimitForMicrocontroller)
                        let stringTypeHexPitchLimitForMicrocontroller = String(pitchHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:16)//16th index
                        bytesToBeSentArray.insert("00", at:17)//17th index
                        bytesToBeSentArray.insert(stringTypeHexPitchLimitForMicrocontroller, at:18) //18th index
                        //--------------Storing swift array into objective-c array
                        //store the swift array bytes into objective-c NSString array
                        var count: UInt8 = 0
                        for bytes in bytesToBeSentArray{
                            instanceOfparser.manualNormalMsgBytes.append(bytes) // OR instanceOfparser.emgMsgBytes.append(bytesToBeSentArray[count])
                            print(instanceOfparser.manualNormalMsgBytes) //test print
                            count+=1 //not needed unless i decide to use or send the number of hex bytes appended to emgMsgBytes
                            print("\nHey\n") //test print
                        }
                        count -= 1 //After this statement run, count will have number of bytes appended. Use if needed
                        print("No of bytes appended = \(count)")
                        print(instanceOfparser.manualNormalMsgBytes) //print what was stored in the array
                        //------------------Sending objective-c array as parameter to msgSender() function.
                        //send the above array to msg sender function and remember to reset it and the end of every while loop iteration
                        instanceOfparser.normalMsgSender(instanceOfparser.manualNormalMsgBytes, ofSize:count)
                        
                        //clean up msg bytes after sending over network
                        instanceOfparser.manualNormalMsgBytes.removeAll(keepingCapacity: true)//remove all bytes for storing new oens in next iteration
                        
                    }
                        //reduce vis to 0% of slider visibility
                    else if( (sliderCeil - mslAltitude) < 0)
                    {
                        let decreasedVis = sliderVis * 0
                        let voltsTranslation = self.visiblityToVoltage(v: decreasedVis )//sliderVis is sent as is in this case
                        print("Volts to send are: \(voltsTranslation)")
                        let voltsToSend = Int(voltsTranslation*10)
                        let voltHexByteUpperCase = String(format:"%02X", voltsToSend)
                        
                        bytesToBeSentArray.insert("00",at:6)
                        bytesToBeSentArray.insert("00",at:7)
                        bytesToBeSentArray.insert(voltHexByteUpperCase,at:8)
                        //---------------Appending necessary bytes after voltage byte----------
                        //append 'time to reach', 'MaxRoll limit', 'MaxPitch limit' bytes at the 9,10,11 indexes
                        //1.time to reach //since we re sending only 1 second for time to change, probably dont need to convert this to HEX.
                        bytesToBeSentArray.insert("00", at:9) //9th index
                        bytesToBeSentArray.insert("00", at:10) //10th index
                        bytesToBeSentArray.insert("00", at:11) //11th index
                        bytesToBeSentArray.insert("01", at:12) //12th index take one second to change to given voltage
                        //2. MaxRoll limit
                        let rollLimitForMicrocontroller = Int8(db.integer(forKey: K.maxRollSS))
                        let rollHexByteUpperCase = String(format:"%02X", rollLimitForMicrocontroller)
                        let stringTypeHexRollLimitForMicrocontroller = String(rollHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:13)//13th index
                        bytesToBeSentArray.insert("00", at:14)//14th index
                        bytesToBeSentArray.insert(stringTypeHexRollLimitForMicrocontroller, at:15)//15th index
                        //3. MaxPitch Limit
                        let pitchLimitForMicrocontroller = Int8(db.integer(forKey: K.maxPitchSS))
                        let pitchHexByteUpperCase = String(format:"%02X", pitchLimitForMicrocontroller)
                        let stringTypeHexPitchLimitForMicrocontroller = String(pitchHexByteUpperCase)
                        bytesToBeSentArray.insert("00", at:16)//16th index
                        bytesToBeSentArray.insert("00", at:17)//17th index
                        bytesToBeSentArray.insert(stringTypeHexPitchLimitForMicrocontroller, at:18) //18th index
                        //--------------Storing swift array into objective-c array
                        //store the swift array bytes into objective-c NSString array
                        var count: UInt8 = 0
                        for bytes in bytesToBeSentArray{
                            instanceOfparser.manualNormalMsgBytes.append(bytes) // OR instanceOfparser.emgMsgBytes.append(bytesToBeSentArray[count])
                            print(instanceOfparser.manualNormalMsgBytes) //test print
                            count+=1 //not needed unless i decide to use or send the number of hex bytes appended to emgMsgBytes
                            print("\nHey\n") //test print
                        }
                        count -= 1 //After this statement run, count will have number of bytes appended. Use if needed
                        print("No of bytes appended = \(count)")
                        print(instanceOfparser.manualNormalMsgBytes) //print what was stored in the array
                        //------------------Sending objective-c array as parameter to msgSender() function.
                        //send the above array to msg sender function and remember to reset it and the end of every while loop iteration
                        instanceOfparser.normalMsgSender(instanceOfparser.manualNormalMsgBytes, ofSize:count)
                        
                        //clean up msg bytes after sending over network
                        instanceOfparser.manualNormalMsgBytes.removeAll(keepingCapacity: true)//remove all bytes for storing new oens in next iteration
                        
                    }
                    else{
                        print("could not resolve a visibility simulation")
                    }
                    
                }
                
                
                
                swiftFirmware_version = instanceOfparser.firmware_version
                if (swiftFirmware_version == nil || swiftFirmware_version == 0.0){
                    //do nothing
                }else{
                    print("Firmware Version = \(swiftFirmware_version!)")
                }
                swiftBattPct = instanceOfparser.battPct
                if (swiftBattPct == nil || swiftBattPct == 0){
                    //do nothing
                }else{
                    print("Battery Percentage = \(swiftBattPct!)")
                }
                
                swiftYaw = instanceOfparser.yaw
                if (swiftYaw == nil){
                    //do nothing
                }else{
                    print("Heading/Yaw = \(swiftYaw!)")
                }
                swiftAirspeedKnots = instanceOfparser.airspeedKnots
                if (swiftAirspeedKnots == nil || swiftAirspeedKnots == 32767){
                    //do nothing
                }else{
                    print("iLevil AirSpeed (Knots) = \(swiftAirspeedKnots!)")
                }
                /* swiftAltitudeFeet = instanceOfparser.altitudeFeet //USE GEO ALTITUDE INSTEAD. ILEVIL SAID NOT TO USE THIS ONE
                 if swiftAltitudeFeet != nil {
                 print("Altitude (Feet) =\(String(describing: swiftAltitudeFeet))")
                 } */
                swiftVsiFtPerMin = instanceOfparser.vsiFtPerMin
                if (swiftVsiFtPerMin == nil || swiftVsiFtPerMin == 32767){
                    //do nothing
                }else{
                    print("iLevil Vertical Speed(ft per min) = \(swiftVsiFtPerMin!)")
                }
                /* TWO ways of sending a set of bytes will be:
                 
                 1. make 'msgForMicrocontroller' an array of bytes. Append bytes to it in each of above if conditions based on comparison with database. When everything is appended, come here to only call msgSender() on the instanceOfparser.
                 2. Annoher way could be to create an appender function in parser class. Also, create an array of bytes in parser class. This appender function will append some bytes to array of bytes in each of above IF-ELSE conditions based on the comparisons with database values. Once all the bytes have have been appended, that array (if needed, will be copied into another array of bytes and) will be sent to microcontroller. see sendto() function definition for details on the requirement of (const void*) as the type of array which is to be sent using sendto() function. */
                //  instanceOfparser.msgForMicrocontroller = 0x45
                //  instanceOfparser.msgSender()
                
                
                
                /* The following function DEFINITION can be used whenever the emergency signal is to be sent. Just copy paste the definition of function or reference it for future use.
                 The following function name is for the event when System Test Button is pressed and it sends flip up signal to visor.
                 @IBAction func systemTestPressed(_ sender: UIButton) {
                 print("System Test Button Pressed!\n")
                 //create a dedicated emergency signal object
                 let msgForMicroInstanceOfParser: parser = parser()
                 //fill the emergencyFlipUp property with emergency signal code. ASCI '922'
                 msgForMicroInstanceOfParser.emergencyFlipUp[0] = 0x39
                 msgForMicroInstanceOfParser.emergencyFlipUp[1] = 0x32
                 msgForMicroInstanceOfParser.emergencyFlipUp[2] = 0x32
                 
                 msgForMicroInstanceOfParser.emergencyMsgSender()
                 }
                 */
                /*------------------------------Cleaning up after each iteration for new messages to be received and sent----------------------*/
                //close the socket here
                instanceOfparser.closeUDPsocket()
                //close(instanceOfparser.sockfd)
                //noOfIterations -= 1
                if (self.startReceiver == 10) //If Abort button gets pressed within any run of iteration, startReceiver is set to 0 and thus continueReceiving will not be 10 anymore- which will stop the while loop here
                {
                    continueReceiving  = 10
                }
                else{
                    continueReceiving = 0;
                }
                //remove all bytes of message from this iteration and get the msg array for microcontroller ready for insertion of new message in next iteration
                bytesToBeSentArray.removeAll(keepingCapacity: true)
                
            }//while
            
        }//dispatch queue
    }//func readFIL()
    
    
}//class Manual_ViewController: UIViewController
