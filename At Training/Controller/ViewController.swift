//
//  ViewController.swift
//  At Training
//
//  Created by WASSIM LAGNAOUI on 2/8/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var systemTest: UIButton!
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var batteryLabel: UILabel!
    @IBOutlet weak var firmwareLabel: UILabel!
    
    // variables
    var temp1 : String = "" //connection
    var temp2 : Int = 0     //battery percentage
    var temp3 : Float = 0   //firmware version
    
    
    var startHomePageReceiver: Int = 10 //make this 0 anywhere you want to stop receiving while loop
    var bytesToBeSentForSystemTest: [String] = [] //gets elements inserted at the beginning of while loop and EACH ELEMENT MUST BE REMOVED AT THE END OF EACH WHILE ITERATION
    var systemTestBytesReadyToBeSentToMicrocontroller: Bool = false
    var continueNetworkValueBringer: Bool = true
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //bringValuesForHomePage()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated) //not sure if this is needed
        print("Hello it's me again the home page")
        print("Inside ViewDidAppear")
        startHomePageReceiver = 10
        continueNetworkValueBringer = true
        bringValuesForHomePage()
           
    }
    override func viewWillDisappear(_ animated: Bool) {
        //udpate the labels
        connectionLabel.text = String(temp1)
        batteryLabel.text    = "\(temp2)% "
        firmwareLabel.text   = String(temp3)
    }
    
    
    
    
    @IBAction func SavePressed(_ sender: UIButton) {
        print("System Test Pressed")
        systemTestMessageBuilder() //build the message
        systemTestBytesReadyToBeSentToMicrocontroller = true //will need to go into one more while iteration for sending the built bytes
        
    }
//
//    func updateUI()  {
//        //udpate the labels
//        connectionLabel.text = String(temp1)
//        batteryLabel.text    = "\(temp2)% "
//        firmwareLabel.text   = String(temp3)
//    }
    
    func systemTestMessageBuilder(){
        
        bytesToBeSentForSystemTest.insert("0D",at:0) //DCBA is the iPad's identifier
        bytesToBeSentForSystemTest.insert("0C",at:1)
        bytesToBeSentForSystemTest.insert("0B",at:2)
        bytesToBeSentForSystemTest.insert("0A",at:3)
        bytesToBeSentForSystemTest.insert("01",at:4)//EMG Trig
        bytesToBeSentForSystemTest.insert("00",at:5)//op mode
        bytesToBeSentForSystemTest.insert("00",at:6)//volt
        bytesToBeSentForSystemTest.insert("00",at:7)//volt
        bytesToBeSentForSystemTest.insert("E4",at:8)//volt
        bytesToBeSentForSystemTest.insert("00",at:9)//timetoreach
        bytesToBeSentForSystemTest.insert("00",at:10)//timetoreach
        bytesToBeSentForSystemTest.insert("00",at:11)//timetoreach
        bytesToBeSentForSystemTest.insert("00",at:12)//timetoreach
        bytesToBeSentForSystemTest.insert("00",at:13)//roll  //if microcontroller wants roll and pitch values from last
        bytesToBeSentForSystemTest.insert("00",at:14)//roll  //use of the app, we can bring values here from database
        bytesToBeSentForSystemTest.insert("00",at:15)//roll  //and sent them to microcontroller. I have assumed that
        bytesToBeSentForSystemTest.insert("00",at:16)//pitch //for system test functionality to flip the visor
        bytesToBeSentForSystemTest.insert("00",at:17)//pitch //microcontroller wont need or care about Roll and Pitch
        bytesToBeSentForSystemTest.insert("00",at:18)//pitch //values.
        
    }
    func bringValuesForHomePage()//EXIT THIS FUNCTION WHEN USER HAS LEFT THIS PAGE
    {
        print("function was called")
        
        DispatchQueue.global(qos: .background).async
            {
                
                    print("inside dispatch queue")
                    //create an instance of Objective C class
                    let homePageInstanceOfparser: parser = parser()
                    
                    var swiftFirmware_version:Float? = Optional.none
                    var swiftBattPct:CInt? = Optional.none
                    
                    var continueHomePageReceiving : Int = 0//variable to check whether to receive data from AHRS device or not
                    if (self.startHomePageReceiver == 10) //only if 'Initiate' titled button is pressed, the startReceiver is set to 10.
                    {
                        continueHomePageReceiving  = 10
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
                    //var noOfIterations = 100 //Now using startReceiver value of 10 to start receiving
                    while (continueHomePageReceiving == 10) //10 is treated as a true
                    //while(noOfIterations > 1)
                    {
                        
                        //print("inside while loop")
                        homePageInstanceOfparser.msgReceiver() // do this as long as app is actively running
                        //try setting instanceOfparser.pitch value to be new 'instanceOfparser.pitch' here.
                        print("\nOn Home Page, Returned from msgReceiver func\n")
                        
                        swiftFirmware_version = homePageInstanceOfparser.firmware_version
                        if (swiftFirmware_version == nil || swiftFirmware_version == 0.0){
                            //do nothing
                            self.temp1 = "Not Connected"//temp1 is connection status UI Label being shown to user
                        }else{
                            print("Firmware Version = \(swiftFirmware_version!)")
                            //set the UI label to above printed value
                            self.temp3 = (swiftFirmware_version!)
                            self.temp1 = "Connected" //temp1 is connection status UI Label being shown to user
                        }
                        swiftBattPct = homePageInstanceOfparser.battPct
                        if (swiftBattPct == nil || swiftBattPct == 0){
                            //do nothing
                        }else{
                            print("Battery Percentage = \(swiftBattPct!)")
                            //set the UI Label to above printed value
                            self.temp2 = Int(swiftBattPct!)
                        }
                        
                        //update the UI Labels in the main thread
                        DispatchQueue.main.sync {
                            //Update UI Labels when values have been set
                                  //udpate the labels
                            self.connectionLabel.text = String(self.temp1)
                            self.batteryLabel.text    = "\(self.temp2)%"
                            self.firmwareLabel.text   = String(self.temp3)
                                  //self.updateUI()
                        }
                        
                        if(self.systemTestBytesReadyToBeSentToMicrocontroller == true) //if this Bool is true
                        {
                            //store the swift array bytes into objective-c NSString array
                            var count: UInt8 = 0
                            for byte in self.bytesToBeSentForSystemTest
                            {
                                homePageInstanceOfparser.systemTestBytes.append(byte) // OR .append(bytesToBeSentArray[count])
                                print(homePageInstanceOfparser.systemTestBytes) //test print
                                count+=1 //not needed unless i decide to use or send the number of hex bytes appended
                                print("\nSetting System Test Message Bytes...\n") //test print
                            }
                            count -= 1 //After this statement runs, count will have number of bytes appended. Use if needed
                            print("No of bytes appended to systemTest msg = \(count)")
                            print(homePageInstanceOfparser.systemTestBytes) //print what was stored in the array
                            homePageInstanceOfparser.emergencyMsgSender(homePageInstanceOfparser.systemTestBytes, ofSize: count)//IT IS NOT SENDING THE CORERCT BYTES AS OF 9PM APRIL 25. THE VALUE DISPLAYED ON MICROCONTROLLER ARE: '8\Xa0\xbf' which is undefined. check emergencyMsgSender function-for one thing, it needs fixing in sendto function. and then bytes will have to be copied inside an objective c array inside that function as well before finally sending it to microcontroller.
                            
                            self.startHomePageReceiver = 0 //stop the while loop from receiving further values
                            self.systemTestBytesReadyToBeSentToMicrocontroller = false //just for reseting for next time
                            self.continueNetworkValueBringer = false //to exit the BringValuesForHomePage() function so that no instance of parser continues to exist when we leave this page after pressing the system test button
                        
                        }
                        /*------------------------------Cleaning up after each iteration for new messages to be received and sent----------------------*/
                        
                        //remove all bytes of message from this iteration and get the msg array for microcontroller ready for insertion of new message in next iteration
                        self.bytesToBeSentForSystemTest.removeAll(keepingCapacity: true) //try moving this inside above if() statement. it should work the same. Benefit of removal: no unnecessary removing of bytes as long as there is nothing to remove.
                        //close the socket here
                        homePageInstanceOfparser.closeUDPsocket()
                        //close(instanceOfparser.sockfd)
                        //noOfIterations -= 1
                        if (self.startHomePageReceiver == 10) //If Abort button gets pressed within any run of iteration, startReceiver is set to 0 and thus continueReceiving will not be 10 anymore- which will stop the while loop here
                        {
                            continueHomePageReceiving  = 10
                        }
                        else{
                            continueHomePageReceiving = 0;
                        }
                        if(self.continueNetworkValueBringer == false)
                        {
                            return
                        }
                        
                    }//while
                
                
                
        }//dispatch queue
        
    }//BringValuesForHomePage()
    
}

