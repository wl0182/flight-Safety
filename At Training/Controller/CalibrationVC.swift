//
//  CalibrationVC.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 2/19/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

class CalibrationVC: UIViewController {
    
    
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var rollLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var LatitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var ellipsoidAltLabel: UILabel!
    @IBOutlet weak var mslAltLabel: UILabel!
    @IBOutlet weak var groundSpeedLabel: UILabel!
    @IBOutlet weak var vsiLabel: UILabel!
    
    //battery,version
    var batteryVar : Int = 0          //connection
    var versionVar : Float = 0       //battery percentage
    //roll,pitch,heading
    var rollVar : Float = 0         //firmware version
    var pitchVar : Float = 0        //connection
    var headingVar : Float = 0      //Heading/Yaw
    // variables
    var latitudeVar : Float = 0     //Latitude
    var longitudeVar : Float = 0    //Longitude
    //Altitudes
    var ellipAltVar : Int = 0       //Ellipsoid Altitude
    var mslAltVar : Int = 0         //MSL Altitude
    //Speeds
    var groundSpeedVar : Int = 0    //ground/horizontal speed
    var verticalSpeedVar : Int = 0  //vertical speed (VSI)
    
                                         
    
    
    var startReceiver: Int = 0;//this gets set to 10 when show button is pressed.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
                                        override func viewWillAppear(_ animated: Bool) {
                                            //udpate the labels
                                            batteryLabel.text = String(batteryVar)
                                            versionLabel.text = String(versionVar)
                                            
                                            rollLabel.text = String(rollVar)
                                            pitchLabel.text = String(pitchVar)
                                            headingLabel.text = String(headingVar)
                                            
                                            LatitudeLabel.text = String(latitudeVar)
                                            longitudeLabel.text = String(longitudeVar)
                                            
                                            ellipsoidAltLabel.text = String(ellipAltVar)
                                            mslAltLabel.text = String(mslAltVar)
                                            
                                            groundSpeedLabel.text = String(groundSpeedVar)
                                            vsiLabel.text = String(verticalSpeedVar)
                                        }
    override func viewWillDisappear(_ animated: Bool) {
        startReceiver = 0
    }
    
    @IBAction func showPressed(_ sender: UIButton) {
        print("Showing Ilevel info ..")
        // set the start receiver variable to positive here
        startReceiver = 10 //while loop for receiving data from AHRS only runs as long as startReceiver stays 10. COMMENT THIS OUT FOR DISABLING THE RECEIVER WHILE LOOP
        // call the value bringer function
        caliberationValueBringer()
    }
    
    func caliberationValueBringer() {
        
        DispatchQueue.global(qos: .background).async {
            
            //create an instance of Objective C class
            let instanceOfparser: parser = parser()
            //declare variables for use with printing or database comparisons
            var swiftGPS_Lat: Float? = Optional.none
            var swiftGPS_Long:Float? = Optional.none
            var swiftGround_speed:CInt? = Optional.none
            var swiftGPS_VSI:CShort? = Optional.none
            //var swiftGPS_heading:CInt? //Use Yaw value for heading instead of this
            var swiftGeo_Altitude:CInt? = Optional.none
            var swiftMSL_Altitude:CInt? = Optional.none
            var swiftFirmware_version:Float? = Optional.none
            var swiftBattPct:CInt? = Optional.none
            var swiftRoll:Float? = Optional.none
            var swiftPitch:Float? = Optional.none
            var swiftYaw:Float? = Optional.none //yaw = Heading


            var continueReceiving : Int = 0//variable to check whether to receive data from AHRS device or not
            if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
            {
                continueReceiving  = 10
            }
            
            //creation of while loop for receiving UDP packets
            //var noOfIterations = 10000 Now using startReceiver value of 10 to start receiving
            while (continueReceiving == 10) //10 is treated as a true
            {
                
                instanceOfparser.msgReceiver() // do this as long as app is actively running
                //try setting instanceOfparser.pitch value to be new 'instanceOfparser.pitch' here.
                print("\nReturned from msgReceiver func\n")

                //setting ObjectiveC property values to swift variables for usage with database and application.
                //Instead of print function, you can call UI Label Changer inside main thread
                
                // Latitude
                swiftGPS_Lat = instanceOfparser.gps_Lat
                if (swiftGPS_Lat == nil){
                    //do nothing
                }else{
                    print("Lat = \(swiftGPS_Lat!)")
                    //store latitude in global var that updates the UI label
                    self.latitudeVar = (swiftGPS_Lat!)
                    
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
     
                            self.LatitudeLabel.text = String(self.latitudeVar)

                        }
                    }
                }
                
                // Longitude
                swiftGPS_Long = instanceOfparser.gps_Long
                if (swiftGPS_Long == nil){
                    //do nothing
                }else{
                    print("Long = \(swiftGPS_Long!)")
                    //store long in gloabal var
                    self.longitudeVar = (swiftGPS_Long!)
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
                            //Update UI Labels when values have been set
                            self.longitudeLabel.text = String(self.longitudeVar)
                        }
                    }
                }
                
                // Horizontal velocity
                swiftGround_speed = instanceOfparser.ground_speed
                if (swiftGround_speed == nil || swiftGround_speed == 4095){
                    //do nothing
                }else{
                    print("Ownship 0x0A Horizontal Velocity = \(swiftGround_speed!)")//this is displayed as Ground Speed under GPS section in iLevil AHRS Utility App
                    self.groundSpeedVar = Int(swiftGround_speed!)
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
                            //Update UI Labels when values have been set
                            self.groundSpeedLabel.text = String(self.groundSpeedVar)
      
                        }
                    }
                }
                
                // Roll
                swiftRoll = instanceOfparser.roll
                if (swiftRoll == nil){
                    //do nothing
                }else
                {
                    print("Roll = \(swiftRoll!)")
                    self.rollVar = (swiftRoll!)
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
                            //Update UI Labels when values have been set
                            
                            self.rollLabel.text = String(self.rollVar)
                            
                        }
                    }
                }//else for Roll check
                
                //Pitch
                swiftPitch = instanceOfparser.pitch
                if (swiftPitch == nil){
                    //do nothing
                }else
                {
                    print("\nPitch = \(swiftPitch!)")
                    self.pitchVar = (swiftPitch!)
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
                            //Update UI Labels when values have been set
                            
                            self.pitchLabel.text = String(self.pitchVar)
                            
                            
                        }
                    }
                }
                
                //Vertical Speed
                swiftGPS_VSI = instanceOfparser.gps_VSI //gps_VSI is a short int
                if (swiftGPS_VSI == nil){
                    //do nothing
                }else{
                    print("Ownship 0x0A Vertical Velocity = \(swiftGPS_VSI!)") //This is displayed as VSI under GPS section in iLevil AHRS Utility App
                    self.verticalSpeedVar = Int(swiftGPS_VSI!)
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
                            //Update UI Labels when values have been set
                            
                            self.vsiLabel.text = String(self.verticalSpeedVar)
                            
                        }
                    }
                }
                
                //Ellipsoid Altitude
                swiftGeo_Altitude = instanceOfparser.geo_Altitude
                if (swiftGeo_Altitude == nil || swiftGeo_Altitude == 0){
                    //do nothing
                }else{
                    print("Geo Altitude = \(swiftGeo_Altitude!)") //this is Ellipsoid Altitude
                    self.ellipAltVar = Int(swiftGeo_Altitude!)
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
                            //Update UI Labels when values have been set
                            self.ellipsoidAltLabel.text = String(self.ellipAltVar)

                        }
                    }
                }
                
                //MSL Altitude
                swiftMSL_Altitude = instanceOfparser.mslAltitude                    //newly added for mslAltitude
                if(swiftMSL_Altitude == nil || swiftMSL_Altitude == 0 || swiftMSL_Altitude == 4095 || swiftMSL_Altitude == 20475)
                {
                    //do nothing
                }else{
                    print("MSL Altitude = \(swiftMSL_Altitude!)")
                    self.mslAltVar = Int(swiftMSL_Altitude!)
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
                            //Update UI Labels when values have been set
                            self.mslAltLabel.text = String(self.mslAltVar)

                        }
                    }
                }
                
                //Firmware Version
                swiftFirmware_version = instanceOfparser.firmware_version
                if (swiftFirmware_version == nil || swiftFirmware_version == 0.0){
                    //do nothing
                }else{
                    print("Firmware Version = \(swiftFirmware_version!)")
                    self.versionVar = (swiftFirmware_version!)
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
                            //Update UI Labels when values have been set
                            
                            self.versionLabel.text = String(self.versionVar)
                            
                        }
                    }
                }
                
                //Battery Percentage
                swiftBattPct = instanceOfparser.battPct
                if (swiftBattPct == nil || swiftBattPct == 0){
                    //do nothing
                }else{
                    print("Battery Percentage = \(swiftBattPct!)")
                    self.batteryVar = Int(swiftBattPct!)
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
                            //Update UI Labels when values have been set
                            self.batteryLabel.text = String(self.batteryVar)

                        }
                    }
                    
                }
                
                //Heading
                swiftYaw = instanceOfparser.yaw
                if (swiftYaw == nil){
                    //do nothing
                }else{
                    print("Heading/Yaw = \(swiftYaw!)")
                    self.headingVar = (swiftYaw!)
                    //update the UI Labels in the main thread
                    if (self.startReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        DispatchQueue.main.sync{
                            //Update UI Labels when values have been set
                            self.headingLabel.text = String(self.headingVar)
                            
                        }
                    }
                }
                
                
                /*------------------------------Cleaning up after each iteration for new messages to be received----------------------*/
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
       
                
            }//while
            
        }//dispatch queue
    }//func caliberationValueBringer()
}

