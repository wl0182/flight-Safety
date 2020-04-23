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
    
    var temp3 : Float = 0
    var startReceiver: Int = 0;
   // var altitudeFSS = db.integer(forKey: K.altitudeSS)//this statement will be cut from here and used down inside while loop.
    
    
    
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
        db.set(tempI, forKey: K.ManualCeiling)//write db.set() for ceilingSlider here
        
    }
    
    
    
    
    //
    @IBAction func InitiatePressed(_ sender: UIButton) {
        
        let title = sender.currentTitle
        
        if title == "Initiate" {
            print("I am reading from The ILevel")
            startReceiver = 10 //while loop for receiving data from AHRS only runs as long as startReceiver stays 10. COMMENT THIS OUT FOR DISABLING THE RECEIVER WHILE LOOP
            readFIL()
            sender.setTitle("Abort", for: .normal)
            
        }
        else {
            sender.setTitle("Initiate", for: .normal)
            startReceiver = 0 //if startReceiver is any value other than 10, while loop for receiving AHRS data will not run
            altitudeSafetyTrigger = 0 //set the safety altitude trigger to zero when abort is pressed
            print("I stopped reading from the Ilevel")
        }
        
        //sample voltage value receiver based on visibility value STARTS HERE
        let vo = visiblityToVoltage(v: temp3 )
        print("Voltage return is \(vo)")
        let volts = Int(vo*10)
        let hexByte = String(volts, radix:16)
        print("voltage converted to hex string is: \(hexByte)")
        print("Visiblity = \(db.float(forKey: K.ManualVisibility))")
        
        //sample voltage value receiver based on visibility value ENDS HERE
        
    }
    
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
            
            var bytesToBeSentArray: [UInt8] = [] //gets elements inserted at the beginning of while loop and EACH ELEMENT MUST BE REMOVED AT THE END OF EACH WHILE ITERATION
           
            
            
            var continueReceiving : Int = 0//variable to check whether to receive data from AHRS device or not
            if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
            {
                continueReceiving  = 10
            }
            /* just for reference:
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
            while (continueReceiving == 10)
            {
                //append 'IPAD' hex code bytes to the array for microcontroller here.
//                bytesToBeSentArray.append(0x49)//HEX for I    These could be used if byteToBeSentArray
//                bytesToBeSentArray.append(0x50)//HEX for P    was being reset or destroyed at the end of
//                bytesToBeSentArray.append(0x41)//HEX for A    each while iteration.
//                bytesToBeSentArray.append(0x44)//HEX for D
                bytesToBeSentArray.insert(0x49,at:0)
                bytesToBeSentArray.insert(0x50,at:1)
                bytesToBeSentArray.insert(0x41,at:2)
                bytesToBeSentArray.insert(0x44,at:3)
                
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
                        //append 5th byte as ASCII 1 = 31 in HEX
                        bytesToBeSentArray.insert(0x31,at:4)//HEX 31 = ASCII 1
                        
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45 //this is to be checked as a 69 decimal
                        print("instanceOfparser.msgForMicrocontroller is: \(instanceOfparser.msgForMicrocontroller)")
                        
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00 //this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        
                        /* //the following will be a better method once array type for emergencyFlipUp[] is figured out. It has to be an array whose each cell holds 8 bits.
                         //create a dedicated emergency signal object
                         let msgForMicroInstanceOfParser: parser = parser()
                         //fill the emergencyFlipUp property with emergency signal code. ASCI '922'
                         msgForMicroInstanceOfParser.emergencyFlipUp[0] = 0x39
                         msgForMicroInstanceOfParser.emergencyFlipUp[1] = 0x32
                         msgForMicroInstanceOfParser.emergencyFlipUp[2] = 0x32
                         
                         msgForMicroInstanceOfParser.emergencyMsgSender()
                         */
                        bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }
                    else if self.valueReceived < Float(temp2R)
                    {
                        print("Flip the visor")
                        //append 5th byte as ASCII 1 = 31 in HEX
                        bytesToBeSentArray.insert(0x31,at:4)//HEX 31 = ASCII 1
                        
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45 //this is to be checked as a 69 decimal
                        print("instanceOfparser.msgForMicrocontroller is: \(instanceOfparser.msgForMicrocontroller)")
                        
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00 //this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        
                        /* //the following will be a better method once array type for emergencyFlipUp[] is figured out. It has to be an array whose each cell holds 8 bits.
                         //create a dedicated emergency signal object
                         let msgForMicroInstanceOfParser: parser = parser()
                         //fill the emergencyFlipUp property with emergency signal code. ASCI '922'
                         msgForMicroInstanceOfParser.emergencyFlipUp[0] = 0x39
                         msgForMicroInstanceOfParser.emergencyFlipUp[1] = 0x32
                         msgForMicroInstanceOfParser.emergencyFlipUp[2] = 0x32
                         
                         msgForMicroInstanceOfParser.emergencyMsgSender()
                         */
                         bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }
                    else
                    {
                        print("Do not Flip the visor")
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
                        bytesToBeSentArray.insert(0x31,at:4)//HEX 31 = ASCII 1
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00//this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        
                        /* //the following will be a better method once array type for emergencyFlipUp[] is figured out. It has to be an array whose each cell holds 8 bits.
                         //create a dedicated emergency signal object
                         let msgForMicroInstanceOfParser: parser = parser()
                         //fill the emergencyFlipUp property with emergency signal code. ASCI '922'
                         msgForMicroInstanceOfParser.emergencyFlipUp[0] = 0x39
                         msgForMicroInstanceOfParser.emergencyFlipUp[1] = 0x32
                         msgForMicroInstanceOfParser.emergencyFlipUp[2] = 0x32
                         
                         msgForMicroInstanceOfParser.emergencyMsgSender()
                         */
                        bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }
                    else if self.valueReceived < Float(temp2P)
                    {
                        print("Flip the visor")
                        //append 5th byte as ASCII 1 = 31 in HEX
                        bytesToBeSentArray.insert(0x31,at:4)//HEX 31 = ASCII 1
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00//this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        
                        /* //the following will be a better method once array type for emergencyFlipUp[] is figured out. It has to be an array whose each cell holds 8 bits.
                         //create a dedicated emergency signal object
                         let msgForMicroInstanceOfParser: parser = parser()
                         //fill the emergencyFlipUp property with emergency signal code. ASCI '922'
                         msgForMicroInstanceOfParser.emergencyFlipUp[0] = 0x39
                         msgForMicroInstanceOfParser.emergencyFlipUp[1] = 0x32
                         msgForMicroInstanceOfParser.emergencyFlipUp[2] = 0x32
                         
                         msgForMicroInstanceOfParser.emergencyMsgSender()
                         */
                        bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }
                    else
                    {
                        print("Do not Flip the visor")
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
                        bytesToBeSentArray.insert(0x31,at:4)//HEX 31 = ASCII 1
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45 //this is to be checked as a 69 decimal
                        print("instanceOfparser.msgForMicrocontroller is: \(instanceOfparser.msgForMicrocontroller)")
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00 //this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        
                        /* //the following will be a better method once array type for emergencyFlipUp[] is figured out. It has to be an array whose each cell holds 8 bits.
                         //create a dedicated emergency signal object
                         let msgForMicroInstanceOfParser: parser = parser()
                         //fill the emergencyFlipUp property with emergency signal code. ASCI '922'
                         msgForMicroInstanceOfParser.emergencyFlipUp[0] = 0x39
                         msgForMicroInstanceOfParser.emergencyFlipUp[1] = 0x32
                         msgForMicroInstanceOfParser.emergencyFlipUp[2] = 0x32
                         
                         msgForMicroInstanceOfParser.emergencyMsgSender()
                         */
                        bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }else{
                        print("Do not Flip the visor")
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
                    
                    if (self.altitudeSafetyTrigger == 1 && (swiftMSL_Altitude!) < Int(altitudeFSS))
                    {
                        print("Flip the visor - Aircraft below safe altitude")
                        //append 5th byte as ASCII 1 = 31 in HEX
                        bytesToBeSentArray.insert(0x31,at:4)//HEX 31 = ASCII 1
                        //send a string to microcontroller
                        instanceOfparser.msgForMicrocontroller = 0x45 //this is to be checked as a 69 decimal
                        print("instanceOfparser.msgForMicrocontroller is: \(instanceOfparser.msgForMicrocontroller)")
                        instanceOfparser.msgSender()
                        instanceOfparser.msgForMicrocontroller = 0x00 //this can be done at the end of each iteration just before while loop bracket close
                        //abort the training if visor flipped.
                        
                        /* //the following will be a better method once array type for emergencyFlipUp[] is figured out. It has to be an array whose each cell holds 8 bits.
                         //create a dedicated emergency signal object
                         let msgForMicroInstanceOfParser: parser = parser()
                         //fill the emergencyFlipUp property with emergency signal code. ASCI '922'
                         msgForMicroInstanceOfParser.emergencyFlipUp[0] = 0x39
                         msgForMicroInstanceOfParser.emergencyFlipUp[1] = 0x32
                         msgForMicroInstanceOfParser.emergencyFlipUp[2] = 0x32
                         
                         msgForMicroInstanceOfParser.emergencyMsgSender()
                         */
                        bytesToBeSentArray.remove(at: 4)//to reset the 4th byte. otherwise it will be inserted again and 0x44 from this block will get pushed instead of getting overwritten
                    }
                }
                
                //Manual Visiblity and Ceiling implementation. Also checks for MSL Altitude and ceiling distance and reacts according.
                //1.
                //2.
                //3.
                //(optional)
                //4.Send the voltage value to microcontroller (append the HEX bytes for voltage value to bytesToBeSentArray)
                if(swiftMSL_Altitude == nil || swiftMSL_Altitude == 0 || swiftMSL_Altitude == 4095 || swiftMSL_Altitude == 20475)
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
                    bytesToBeSentArray.insert(0x31,at:5)//HEX 31 = ASCII 1 = to select mode of opacity change over time instead of sudden change
                    print("\nMSL Altitude received for manual functionality. Sending simulations now\n")
                    //bring values from database and manual page sliders
                    let manualVisFromSlider = db.float(forKey: K.ManualVisibility)
                    let sliderVis = Float(manualVisFromSlider) //to be used in IF/ELSE statements
                    let manualCeilFromSlider = db.integer(forKey: K.ManualCeiling)
                    let sliderCeil = Int(manualCeilFromSlider) //to be used in IF/ELSE statements
                    let mslAltitude = Int(swiftMSL_Altitude!)
                    if((sliderCeil - mslAltitude) >= 100)//aircraft not within 100 ft of cloud ceiling
                    {
                        let voltsToSend = self.visiblityToVoltage(v: sliderVis )
                        print("Volts to send are: \(voltsToSend)")
                        //bytesToBeSentArray.insert(0x31,at:6)
                        //bytesToBeSentArray.insert(0x31,at:7)  FIND A SOLUTION FOR THIS FIRST. EITHER 49 IF STATEMENTS/SWIFT CASES. OR A float to hex convertor funciton
                        //bytesToBeSentArray.insert(0x31,at:8)
                        
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
