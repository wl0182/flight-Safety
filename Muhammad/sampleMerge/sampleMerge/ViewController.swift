//
//  ViewController.swift
//  sampleMerge
//
//  Created by Muhammad Daniyal on 4/3/20.
//  Copyright © 2020 MuhammadDaniyal. All rights reserved.
//

import UIKit

//no need to import "parser.h" here because Bridging-Header.h automatically does that for us.
class ViewController: UIViewController {

   override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //create an instance of Objective C class
        let instanceOfparser: parser = parser()
        //declare variables for use with printing or database comparisons
        var swiftGPS_Lat: Float? = Optional.none
        var swiftGPS_Long:Float? = Optional.none
        var swiftGround_speed:CInt? = Optional.none
        var swiftGPS_VSI:CShort? = Optional.none
        //var swiftGPS_heading:CInt? //Use Yaw value for heading instead of this
        var swiftGeo_Altitude:CInt? = Optional.none
        var swiftFirmware_version:Float? = Optional.none
        var swiftBattPct:CInt? = Optional.none
        var swiftRoll:Float? = Optional.none
        var swiftPitch:Float? = Optional.none
        var swiftYaw:Float? = Optional.none //yaw = Heading
        var swiftAirspeedKnots:CInt? = Optional.none
        //var swiftAltitudeFeet:CInt? //use Geo Altitude instead of this
        var swiftVsiFtPerMin:CInt? = Optional.none
        
        //creation of while loop for receiving UDP packets
        var noOfIterations = 1000
        while noOfIterations > 1{ //PROBLEM HERE. THIS IS ONLY PRINTING PITCH AND ROLL ONCE. MAY BE BECAUSE ALTERING THE PROEPRTY VALUE OF AN OBJECT IS NOT ALLOWED.
            //print("inside while loop")
            instanceOfparser.msgReceiver() // do this as long as app is actively running
            //try setting instanceOfparser.pitch value to be new 'instanceOfparser.pitch' here.
            
            //printing ObjectiveC properties value for test
            //print("myPitch:\(instanceOfparser.pitch)") //test
            //print("myRoll:\(instanceOfparser.roll)") //test
            
            //setting ObjectiveC property values to swift variables for usage with database and application.
            //Instead of print function, you can call a comparing method on the swift variables
            swiftGPS_Lat = instanceOfparser.gps_Lat
            if (swiftGPS_Lat == nil || swiftGPS_Lat == 0.0){
                //do nothing
            }else{
                print("Lat = \(swiftGPS_Lat!)")
                //call caliberation display function
                //call comparing function to database values
            }
            swiftGPS_Long = instanceOfparser.gps_Long
            if (swiftGPS_Long == nil || swiftGPS_Long == 0.0){
                //do nothing
            }else{
                print("Long = \(swiftGPS_Long!)")
            }
            swiftGround_speed = instanceOfparser.ground_speed
            if (swiftGround_speed == nil || swiftGround_speed == 0){
                //do nothing
            }else{
                print("Ground Speed = \(swiftGround_speed!)")
            }
            swiftGPS_VSI = instanceOfparser.gps_VSI
            if (swiftGPS_VSI == nil || swiftGPS_VSI == 0){
                //do nothing
            }else{
                print("VSI/ Vertical Speed = \(swiftGPS_VSI!)")
            }
            /* swiftGPS_heading = instanceOfparser.gps_heading //USE YAW VALUE FOR HEADING. DO NOT USE GPS HEADING.
            if swiftGPS_heading != nil {
                print("Heading =\(String(describing: swiftGPS_heading))")
            }*/
            swiftGeo_Altitude = instanceOfparser.geo_Altitude
            if (swiftGeo_Altitude == nil || swiftGeo_Altitude == 0){
                //do nothing
            }else{
                print("Geo Altitude = \(swiftGeo_Altitude!)")
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
            swiftRoll = instanceOfparser.roll
            if (swiftRoll == nil || swiftRoll == 0.0){
                //do nothing
            }else{
                print("Roll = \(swiftRoll!)")
            }
            swiftPitch = instanceOfparser.pitch
            if (swiftPitch == nil || swiftPitch == 0.0){
                //do nothing
            }else{
                print("Pitch = \(swiftPitch!)")
            }
            swiftYaw = instanceOfparser.yaw
            if (swiftYaw == nil || swiftYaw == 0.0){
                //do nothing
            }else{
                print("Heading/Yaw = \(swiftYaw!)")
            }
            swiftAirspeedKnots = instanceOfparser.airspeedKnots
            if (swiftAirspeedKnots == nil || swiftAirspeedKnots == 0){
                //do nothing
            }else{
                print("Air Speed (Knots) = \(swiftAirspeedKnots!)")
            }
           /* swiftAltitudeFeet = instanceOfparser.altitudeFeet //USE GEO ALTITUDE INSTEAD. ILEVIL SAID NOT TO USE THIS ONE
            if swiftAltitudeFeet != nil {
                           print("Altitude (Feet) =\(String(describing: swiftAltitudeFeet))")
                       } */
            swiftVsiFtPerMin = instanceOfparser.vsiFtPerMin
            if (swiftVsiFtPerMin == nil || swiftVsiFtPerMin == 0){
                //do nothing
            }else{
                print("VSI (ft per min) = \(swiftVsiFtPerMin!)")
            }
            
            
            noOfIterations -= 1
        }
        
        //print("came out of while loop")
       // parser *object1 = [[parser alloc]init];
       //object1.msgReceiver();
    }


}

