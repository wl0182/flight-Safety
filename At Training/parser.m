//
//  parser.m
//  At Training
//
//  Created by Muhammad Daniyal on 4/14/20.
//

//
//  parser.m
//  crctester
//
//  Created by Muhammad Daniyal on 4/9/20.
//  Copyright © 2020 MuhammadDaniyal. All rights reserved.
//

//  parser.m
//  sampleMerge
//  Created by Muhammad Daniyal on 4/3/20.



#import "parser.h"
uint16_t crc16Table [256];



@implementation parser

//+ for class methods, - for instance methods.
//+(static void) packetParserMsg:uint8_t *mesg andSize:ssize_t n {.... } //OBjectiveC version of following funciton
//-(void) packetParser:(uint8_t *)mesg withSize:(ssize_t) n {
-(void) packetParser:(uint8_t *)cleanedMessage withSize:(ssize_t) n {

    //print the cleaned message:
    printf("Cleaned Message is:\n");
    for(int y = 0; y<n; y++) //THIS IS A FULL MESSAGE. COPY DATA FROM INDEX 1 TO < N-1 FOR DECODABLE MESSAGE
        {
            //printf("%s ", &mesg[y]); //this prints a string.. but our data is binary
            printf("%02X ", cleanedMessage[y]);
            
        }
        printf("\n");
    
    //REMOVE BEGIN AND END FLAG BEFORE FOLLOWING
    //verify which message we received
    int MID = cleanedMessage[0]; //first byte indicates Message ID
    printf("Message id = %02X \n",MID);
    switch (MID) {
        case 0:
            printf("Received Heartbeat message\r\n");
            //decode time here
            break;
            
        case 0x0A:
            printf("Received ownship message\r\n");
            //decode GPS location here (i.e. get Lat and Long values
            int tempInt;
            //get Latitude
            tempInt =(cleanedMessage[5]<<16)+(cleanedMessage[6]<<8)+(cleanedMessage[7]);
            if (tempInt & 0x800000)
            {
                self.gps_Lat = (-1)*(float)(((tempInt^0xFFFFFF)+1)*90)/4194304;
            }
            else
            {
                self.gps_Lat = (float)(tempInt*90)/4194304;
            }
            
            
            //get Longitude
            
            tempInt =(cleanedMessage[8]<<16)+(cleanedMessage[9]<<8)+(cleanedMessage[10]);
            if (tempInt & 0x800000)
            {
                self.gps_Long = (-1)*((float)(((tempInt^0xFFFFFF)+1)*90)/4194304);
            }
            else
            {
                self.gps_Long = ((float)(tempInt*90)/4194304);
            }
            
            
            //get ground speed
            
            self.ground_speed =(cleanedMessage[14]<<4)+((cleanedMessage[15] &  0xF0)>>4);
            
            
            //get GPS vertical speed
            
            self.gps_VSI = (short int)(cleanedMessage[16]+((cleanedMessage[15] &  0x0F)<<8))*64;
            
            
            //get heading
            
            self.gps_heading = cleanedMessage[17]*(360/256);
            
            
            //get geoAltitude
            //DO NOT USE THIS (as per iLevel decoder code)
            
            //get values
            NSLog(@"GPS Lat: %0.3f",self.gps_Lat);
            NSLog(@"GPS Long: %0.3f",self.gps_Long);
            NSLog(@"GPS groundspeed: %d",self.ground_speed);
            NSLog(@"GPS Vert Speed: %d",self.gps_VSI); //Feets per Minute FPM. See FAA fdl90 doc for more.
            NSLog(@"GPS Heading: %d",_gps_heading);//no need for this. We are probably using yaw value for heading (Ananda named yaw as Heading and it is consistent with utility app
            //NSLog(@"GPS Altitude: %d",gps_Altitude);// DO NOT USE THIS (as per iLevel code)
            
            break;
            
        case 0x0B: //received only once in 5000 loops
            printf("Received GPS ALtitude message\r\n");
            //decode GPS altitude here
            //this is ellipsoid ALtitude (not Mean Sea Level Altitude)
            self.geo_Altitude  = (short int)((cleanedMessage[1]<<8)+cleanedMessage[2])*5; //this altitude is actually Ellipsoid Altitude
            NSLog(@"Geo Altitude (Ellipsoid altitude): %d", self.geo_Altitude); //NOT BEING RECEIVED even in 1000 iterations of while loop
            
            //add this ellipsoid value to final altitude value and display finalAltitude in swift whether or not GPS STATUS message adds the altitude variation to its value or not.
            //self.finalAltitude = self.geo_Altitude;
            //NSLog(@"Final Altitude: %d",self.finalAltitude);
            
            break;
            
        case 0x4C: //received iLevil message
            if (cleanedMessage[2] == 0x00)
            {
                printf("Received Levil Status message\r\n");
                //decode battery percent etc
                self.firmware_version = ((float)cleanedMessage[4])/10.0;
                self.battPct = (int)cleanedMessage[5];
                //  NSLog(@"Firmware Version: %0.1f",self.Firmware_version);
                //  NSLog(@"Battery Percentage: %d",self.battPct);
                //
                //                            int errorCode = cleanedMessage[6]*256+cleanedMessage[6];//what is this for?
                //                            int status_version = cleanedMessage[3];//what is this for?
                //
                //                            Cant find the usage of following either
                //                            if (status_version == 0x02)
                //                            {
                //                                //check GPS status
                //                                int WAAS = cleanedMessage[8];
                //                                int Sattelites = cleanedMessage[9];
                //                            }
            }
            else if (cleanedMessage[2] == 0x01)
            {
                printf("Received Levil AHRS message\r\n");
                self.roll = ((float)((short int)((cleanedMessage[4]*256)+cleanedMessage[5])))/10.0;
                self.pitch = ((float)((short int)((cleanedMessage[6]*256)+cleanedMessage[7])))/10.0;
                self.yaw = (float)((short int)((cleanedMessage[8]*256)+cleanedMessage[9]))/10.0;//yaw = Heading
                self.airspeedKnots = ((short int)(cleanedMessage[16]*256+cleanedMessage[17]));
                self.altitudeFeet = ((short int)(cleanedMessage[18]*256+cleanedMessage[19]));
                self.vsiFtPerMin = ((short int)(cleanedMessage[20]*256+cleanedMessage[21]));
                if ((self.airspeedKnots !=0x7FFF) && (self.altitudeFeet !=0xFFFF) && (self.vsiFtPerMin != 0x7FFF))
                {
                    self.airspeedKnots = self.airspeedKnots/10;
                    self.altitudeFeet = self.altitudeFeet-5000;
                }
                //NSLog(@"Roll: %.1f, Pitch: %.1f, Heading: %.1f\r\n",self.roll,self.pitch,self.yaw);
                //NSLog(@"Air Speed(kts): %d, Altitude(ft): %d",self.airspeedKnots, self.altitudeFeet);//Values not making sense. AirSpeed = 32767 and Altitude= -1
            }
           else if (cleanedMessage[2] == 0x07)
            {
                self.altitudeVariation =((short int)(cleanedMessage[11]*256+cleanedMessage[12])); //ASK ANANDA IF THIS IS CORRECT WAY TO DECODE THE ALTITUDE VARIATION IN MESSAGE ID is (0X4C) (0x45) (0x07). See page 33 of iLevil Comm protocol for details.
                self.mslAltitude = self.geo_Altitude + self.altitudeVariation;
            }
            break;
 
        default:
            break;
    }
}

-(instancetype)init
{
    //this init function is called only once at the beginning
    //self.CRC16Table is a global variable u16
    //create crc table at the beginning of your program, only once
    self = [super init];
    if (self) {
        
        uint16_t i,bitctr,crc = {0};
        self.sockfd = socket(AF_INET, SOCK_DGRAM, 0);;//the only socket we will use for both receiving and sending messages
        for (i = 0; i < 256; i++) {
            crc = (i << 8);
            for (bitctr = 0; bitctr < 8; bitctr++) {
             
                crc = (crc<<1)^((crc & 0x8000) ? 0x1021 : 0);
            }
           // NSLog(@"calculated crc (inplace of NSNumber) is %hu \n Now sending it to crcTable\n",crc);
            crc16Table[i] = crc;
           // NSLog(@"The crcTable has: %hu", crc16Table[i]);
        }
        
        
    }
    return self;
    
}

-(unsigned short) gdl90_CRC_Compute: (uint8_t *) data ofLength: (unsigned long)length
{
    unsigned long i;
   //unsigned short crc = 0;
   unsigned short crc2 = 0;
    
    
    for (i = 0; i <length; i++)
    {
        //CRC16Table was initialized at the beginning of your program

      crc2 = crc16Table[crc2>>8]^(crc2<<8)^(unsigned short)data[i]; //see if removing (unsigned short) does anything

    }
  //  printf("CRC = %hu \n", crc2);
    //return crc2;
    return crc2;
}
//Notes on global variables
//uint8_t RxData_1[255] is where my received data is stored (raw)
//u8 Bufferlength  //stores the total number of bytes received
-(void) scanData: (uint8_t *) RxData_1 ofLength:(uint8_t) BufferLength
{
    printf("Inside scanData function\n");
    uint8_t Wifi_data[255] = {0};
    uint8_t Wifi_data_without_flags[255]={0};
    int count_for_flag_removal =0;
    uint8_t ellipsoid_data_without_flags[255] = {0};
    int count_for_ellipsoid_flag_removal =0;
    static uint8_t Wifi_counter = 0;
    static uint8_t GDL90Message_in = 0;
    static uint8_t ownShip_in = 0;
    static uint8_t ellipsoidAltitude_in = 0;
    
    
    for (uint8_t Wifi_follow = 0; Wifi_follow <= BufferLength; Wifi_follow++)
    {
 //if there is E after L after the beginning ~ character i.e case id = 0x4C
                                if (RxData_1[Wifi_follow] == 0x45)//found an E
                                {    if (RxData_1[Wifi_follow-1] == 0x4C)//found an L before E
                                        {  if (RxData_1[Wifi_follow-2] == 0x7E)//found a '~' before LE THUS ->//gdl90 message found
                                            {
                                                printf("\nFound GDL90 message\n");
                                                Wifi_data[0]=0x4C; //sets the first element of Wifi_data to be 'L'. since 4C = 'L'
                                                GDL90Message_in = 1;
                                                Wifi_counter=1;
                                            }
                                        }
                                }
                                if (GDL90Message_in) //if GDL90 message found is TRUE
                                {
                                                                       
                                    if (RxData_1[Wifi_follow]== 0x7E)//if the character is '~', count this as one message, compute crc, and if all good with crc, send it to processor function
                                    {
                                        GDL90Message_in = 0;
                                        
                                        //analyze message
                                        //check crc
                                        printf("Calling GDL90crcCompute function..\n");
                                        uint16_t crc = [self gdl90_CRC_Compute:Wifi_data ofLength: Wifi_counter-2];//call ComputeCRC func
                                        
                                       if (crc == (Wifi_data[Wifi_counter-2]+(Wifi_data[Wifi_counter-1]<<8)))//all good with crc
                                        {
                                            printf("Calling packetparser function\n");
                                            //call parser function
                                            printf("Wifi_Data[0] is :%02X", Wifi_data[0]);
                                            [self packetParser:Wifi_data withSize:BufferLength];
                                            //ProcessGDL90Message(Wifi_data); //processor function //IS IT SUPPOSED TO BE 'RxData_1' instead of Wifi_date? Wifi_Data is probably empty at this point. I could be wrong though.
                                            
                                        }
                           
                                        continue; //this used to be break statement. but now it is a continue for going to next iteration of for loop
                                    }
                                    
                                    //remove byte stuffing: USE THIS ONE
                                    if (((RxData_1[Wifi_follow]== 0x5E)||(RxData_1[Wifi_follow]== 0x5D)) &&(RxData_1[Wifi_follow-1]== 0x7D)) // 5E is ^, 5D is ], 7D is }
                                    {   //printf("\nremoving byte stuffing\n");
                                        Wifi_data[Wifi_counter-1]=RxData_1[Wifi_follow]^0x20;
                                        Wifi_counter--;
                                    }
                                    else
                                    {
                                       // printf("\nno need to remove byte stuffing, approving and storing message for parsing in next iteration\n");
                                        Wifi_data[Wifi_counter] = RxData_1[Wifi_follow];
                                    }
                                    
                                    Wifi_counter++;
                                }
        
        
        
//if there is 0A after a beginning '~' ---ownship report received -- gives Lat,Long,ground_speed, and VSI
        
        if (RxData_1[Wifi_follow] == 0x0A)//found a 0x0A
        {    if (RxData_1[Wifi_follow-1] == 0x7E)//found an ~ before 0x0A
                 {
                     printf("\nFound Ownship (Lat,Long etc.) message\n");
                     Wifi_data[0]=0x7E; //sets the first element of Wifi_data to be '0x7E'.
                 
                     ownShip_in = 1;
                     Wifi_counter=1;
                 }
        }
         if (ownShip_in) //if ownship message found is TRUE
         {

             if (RxData_1[Wifi_follow]== 0x7E)//if the character is '~', count this as one message, compute crc, and if all good with crc, send it to processor function
             {
                 ownShip_in = 0;
                 
                 //u come here only if you have discovered an END flag '~' i.e 0x7E
                 Wifi_data[Wifi_counter] = RxData_1[Wifi_follow]; //Now the Message is complete with start and end flags
                 
                 //remove start and end flags if you have first character of Wifi_data as 0x7E
                 for (int t=1 ; t< Wifi_counter; t++)
                 {
                     Wifi_data_without_flags[count_for_flag_removal]=Wifi_data[t];
                     count_for_flag_removal++;
                 }
                 
                 
                 //analyze message
                 //check crc
                 printf("Calling GDL90crcCompute function..\n");
                // uint16_t crc = [self gdl90_CRC_Compute:Wifi_data_without_flags ofLength: Wifi_counter-2];//call ComputeCRC func. wifi_counter -2 is meant to remove the FCS bytes itself. The end flag byte was never inserted in Wifi_data. if end flag had been here, the ofLength: Wifi_counter-3
                 uint16_t crc = [self gdl90_CRC_Compute:Wifi_data_without_flags ofLength: count_for_flag_removal-2];//check if Wifi_counter needs to change to accommodate the line 342 and loop on line 345.
                 if (crc == (Wifi_data[Wifi_counter-2]+(Wifi_data[Wifi_counter-1]<<8)))//all good with crc
                 {
                     printf("Calling packetparser function\n");
                     //call parser function
                     printf("Wifi_Data[0] is :%02X", Wifi_data[0]);
                     [self packetParser:Wifi_data_without_flags withSize:count_for_flag_removal];
                     //ProcessGDL90Message(Wifi_data); //processor function //IS IT SUPPOSED TO BE 'RxData_1' instead of Wifi_date? Wifi_Data is probably empty at this point. I could be wrong though.
                 }
                
                 continue;
             }
             
             //remove byte stuffing: USE THIS ONE
             //------>if needed, change the following to run only on encounter of control-escape character i.e 0x7D which is } in ASCII. the GDL90 FAA doc only asks to look for control escape character and not the 5E or 5D unlike ilevil message byte stuffing requirement. since 0A message id is not an iLevil message, we should probably follow what FAA GDL90 doc says.
             if (((RxData_1[Wifi_follow]== 0x5E)||(RxData_1[Wifi_follow]== 0x5D)) &&(RxData_1[Wifi_follow-1]== 0x7D)) // 5E is ^, 5D is ], 7D is }
             {   //printf("\nremoving byte stuffing\n");
                 Wifi_data[Wifi_counter-1]=RxData_1[Wifi_follow]^0x20;
                 Wifi_counter--;
             }
             else//character by character writer (when byte stuffing elimation not needed)
             {
                 // printf("\nno need to remove byte stuffing, approving and storing character\n");
                 Wifi_data[Wifi_counter] = RxData_1[Wifi_follow];
             }
             
             Wifi_counter++;
         }
        
        
//if there is 0B after a beginning '~'
                                    if (RxData_1[Wifi_follow] == 0x0B)//found an E
                                    {   if (RxData_1[Wifi_follow-1] == 0x7E)//found a '~' before 0x0B
                                            
                                            {
                                                printf("\nFound Geo Altitude (Ellipsoid Altitude) message, i.e case 0B\n");
                                              
                                                Wifi_data[0]=0x7E; //sets the first element of Wifi_data to be '7E'.
                                   
                                            
                                                ellipsoidAltitude_in = 1;
                                                Wifi_counter=1;
                                            }
                                    }
                                    if (ellipsoidAltitude_in) //if Geo Altitude (Ellipsoid Altitude) message found is TRUE
                                    {
                                                                           
                                        if (RxData_1[Wifi_follow]== 0x7E)//if the character is '~', count this as one message, compute crc, and if all good with crc, send it to processor function
                                        {
                                            ellipsoidAltitude_in = 0;
                                            
                                            //u come here only if you have discovered an END flag '~' i.e 0x7E
                                            Wifi_data[Wifi_counter] = RxData_1[Wifi_follow]; //Now the Message is complete with start and end flags
                                            
                                            //remove start and end flags if you have first character of Wifi_data as 0x7E
                                            printf("\nTest print ellipsoid altitude message:\n");
                                            for (int t=1 ; t< Wifi_counter; t++)
                                            {
                                                ellipsoid_data_without_flags[count_for_ellipsoid_flag_removal]=Wifi_data[t];
                                                printf("%02X ", ellipsoid_data_without_flags[count_for_ellipsoid_flag_removal]);
                                                count_for_ellipsoid_flag_removal++;
                                            }
                                            
                                            
                                            //analyze message
                                            //check crc
                                    // self made statement: NSString * data2 = [NSString stringWithFormat:@"%s", Wifi_data];
                                            printf("Calling GDL90crcCompute function..\n");

                                            uint16_t crc = [self gdl90_CRC_Compute:ellipsoid_data_without_flags ofLength: count_for_ellipsoid_flag_removal-2];//call ComputeCRC func


                                            if (crc == (Wifi_data[Wifi_counter-2]+(Wifi_data[Wifi_counter-1]<<8)))//all good with crc

                                            {
                                                printf("Calling packetparser function\n");
                                                //call parser function
                                                printf("Wifi_Data[0] is :%02X", Wifi_data[0]);
                                                [self packetParser:ellipsoid_data_without_flags withSize:count_for_ellipsoid_flag_removal];

                                                
                                            }
                                         
                                            continue; //used to break but now continues the FOR loop iteration
                                        }
                                        
                                        //remove byte stuffing: USE THIS ONE
                                        //------>if needed, change the following to run only on encounter of control-escape character i.e 0x7D which is } in ASCII. the GDL90 FAA doc only asks to look for control escape character and not the 5E or 5D unlike ilevil message byte stuffing requirement. since 0B message id is also not an iLevil message, we should probably follow what FAA GDL90 doc says.
                                        if (((RxData_1[Wifi_follow]== 0x5E)||(RxData_1[Wifi_follow]== 0x5D)) &&(RxData_1[Wifi_follow-1]== 0x7D)) // 5E is ^, 5D is ], 7D is }. //if (RxData_1[Wifi_follow]== 0x7D) // this is the condition that FAA gdl90 asks us to check for geoaltitude and ownship reports. above condition was given by Ananda from iLevil so i am using that for every case because it seems to be working either way.
                                        {
                                            //printf("\nremoving byte stuffing\n");
                                            Wifi_data[Wifi_counter-1]=RxData_1[Wifi_follow]^0x20;
                                            Wifi_counter--;
                                        }
                                        else //character by character writer (when byte stuffing elimation not needed)
                                        {
                                           // printf("\nno need to remove byte stuffing, approving and storing message for parsing in next iteration\n");
                                            Wifi_data[Wifi_counter] = RxData_1[Wifi_follow];
                                        }
                                        
                                        Wifi_counter++;
                                    }
        
   
    }
}
- (void) msgReceiver
{
    
        //variables
        ssize_t n;
        socklen_t len;
//      int sockfd;//this socket gets created in init function now
        uint8_t mesg[1024] = {0};

        //socket
        struct sockaddr_in servaddr,cliaddr;
    
        self.sockfd = socket(AF_INET, SOCK_DGRAM, 0);//this socket gets created and destroyed once per each function call
        bzero(&servaddr, sizeof(servaddr));
        servaddr.sin_family = AF_INET;
        servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
        servaddr.sin_port = htons(43211);
        bind(self.sockfd, (struct sockaddr *) &servaddr, sizeof(servaddr));
        len = sizeof(cliaddr);
        
        printf("\nabout to recvfrom\n");
                 
        n = recvfrom(self.sockfd, mesg, 1024, 0, (struct sockaddr *) &cliaddr, &len);
//        uint8_t escaped[256] = {0};
        if (n>0) //if we have bytes
        {
            printf("Received %zi bytes. About to call scanData function\n", n);
            
//            //printf("Message receied without begin and end flags is:\n");  //
//            NSLog(@"Raw Bytes received (escaped[]) :\n");                   //this block is not needed
//            for (int u = 0; u < n; u++)                                     //
//            {                                                               //
//                escaped[u]=mesg[u];                                         //
//                printf("%02X ",escaped[u]);                                 //
//            }
            //send mesg and n to scanData function.
            [self scanData:mesg ofLength:n];
                        

        }//if n>0
    //close(self.sockfd);//this socket gets created and destroyed once per each function call

}
//plain string sender testing function for network connection
- (void) msgSender //not being used
{
    
    uint8_t byteArrayForMicro[26] = {0};// OR we can create uint8_t mesgBeingSent[no_of_bytes_being_sent] = {0}; and use 'mesgBeingSent' for the parameter of (const void *) in sendto() function
//    int microfd = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in testsvr;
    bzero(&testsvr, sizeof(testsvr));
    testsvr.sin_family = AF_INET;
    testsvr.sin_addr.s_addr = inet_addr("192.168.1.12");
    
    testsvr.sin_port = htons(43211);
    socklen_t len2 = sizeof(testsvr);
    byteArrayForMicro[0] = self.msgForMicrocontroller; //i can always fall back on this technique for sending bytes over network.
    //tester code end
    printf("\nInside msgSender right now.\nSending the message to Microcontroller\n");
      //tester code start
      //test for sending msg to microcontroller
    //send(microfd, "Hello from IPAD Hello from IPAD Hello from IPAD Hello from IPAD", 60, 0);
    sendto(self.sockfd, "Hello from IPAD Hello from IPAD Hello from IPAD Hello from IPAD", 63, 0, (struct sockaddr *) &testsvr, len2);
    printf("byteArrayForMicro[0] is %hhu", byteArrayForMicro[0]);
    if(byteArrayForMicro[0] == 0){
        //do nothing
        sendto(self.sockfd, "DO NOT FLIP THE VISOR", 21, 0, (struct sockaddr *) &testsvr, len2);
    }else if (byteArrayForMicro[0] == 69){
        sendto(self.sockfd, "FLIP THE VISOR", 13, 0, (struct sockaddr *) &testsvr, len2);
    sendto(self.sockfd, byteArrayForMicro, 40, 0, (struct sockaddr *) &testsvr, len2);//third argument is the no of characters to be sent
    }
    printf("MSG SENT TO MICROCONTROLLER!");

    //close(self.sockfd);
    
}
//new message sender as of april24th, 2020
//this is being called for sending the voltage value based on the ceiling and slider visibility from manual scenario
- (void) normalMsgSender: (NSString *) simulationMsgBytes ofSize:(uint8_t)numberOfBytes
{
        //int noOfBytes = (int) numberOfBytes *2;
        int noOfBytes = 19*2;//we never need to send more than 19*2 bytes. This will take care of unnecessary or erroroneous bytes
        uint8_t * bytesReadyToSend = (uint8_t *)[simulationMsgBytes UTF8String];
    
        uint8_t byteArrayForMicro[19] = {0};// OR we can create uint8_t mesgBeingSent[no_of_bytes_being_sent] = {0}; and use 'mesgBeingSent' for the parameter of (const void *) in sendto() function
    //    int microfd = socket(AF_INET, SOCK_DGRAM, 0); //REMOVE THIS
        
        struct sockaddr_in normalSvr;
        bzero(&normalSvr, sizeof(normalSvr));
        normalSvr.sin_family = AF_INET;
        normalSvr.sin_addr.s_addr = inet_addr("192.168.1.12");
        normalSvr.sin_port = htons(43211);
        socklen_t len2 = sizeof(normalSvr);
    
        byteArrayForMicro[0] = self.msgForMicrocontroller; //i can always fall back on this technique for sending bytes over network.//REMOVE THIS
        
        //tester code end
        printf("\nInside normalMsgSender right now.\nSending the message to Microcontroller\n");
          //tester code start
          //test for sending msg to microcontroller
        //send(microfd, "Hello from IPAD Hello from IPAD Hello from IPAD Hello from IPAD", 60, 0);
        sendto(self.sockfd, "Hello from IPAD Hello from IPAD Hello from IPAD Hello from IPAD", 63, 0, (struct sockaddr *) &normalSvr, len2);
        printf("byteArrayForMicro[0] is %hhu", byteArrayForMicro[0]);
//        if(byteArrayForMicro[0] == 0){
//            //do nothing
//            sendto(self.sockfd, "DO NOT FLIP THE VISOR", 21, 0, (struct sockaddr *) &testsvr, len2);
//        }
//        else if (byteArrayForMicro[0] == 69)
//        {
        sendto(self.sockfd, "RECIEVED VOLTAGE INSTRUCTIONS", 30, 0, (struct sockaddr *) &normalSvr, len2);
        sendto(self.sockfd, bytesReadyToSend, noOfBytes, 0, (struct sockaddr *) &normalSvr, len2);//third argument is the no of characters to be sent
       // }
        printf("\nMSG SENT TO MICROCONTROLLER!");

        //close(self.sockfd);
}
//Used for sending emg trigger for 'system test' as well as safety violation during Manual Training
- (void) emergencyMsgSender:(NSString *) emgMsgBytes ofSize:(uint8_t) noOfBytes{
   
 //   int numberOfBytes = (int) noOfBytes * 2;
    int numberOfBytes = 19*2; //we never need to send more than 19*2 bytes. This will take care of unnecessary or erroroneous bytes
    uint8_t * emgBytesReadyToSend = (uint8_t *)[emgMsgBytes UTF8String];
    
    struct sockaddr_in emergencysvr;
    bzero(&emergencysvr, sizeof(emergencysvr));
    emergencysvr.sin_family = AF_INET;
    emergencysvr.sin_addr.s_addr = inet_addr("192.168.1.12"); // SET THIS TO BE THE IP ADDRESS OF MICROCONTROLLER (192.168.1.11). DO NOT FORGET!
    emergencysvr.sin_port = htons(43211);
    socklen_t len2 = sizeof(emergencysvr);
    
    //byteArrayForMicro[0] = self.msgForMicrocontroller;
    //tester code end
    //printf("\nSending the message to Microcontroller\n");
      //tester code start
      //test for sending msg to microcontroller
    //send(microfd, "Hello from IPAD Hello from IPAD Hello from IPAD Hello from IPAD", 60, 0);
    sendto(self.sockfd, "Next byte set is an emergency flip-up message", 24, 0, (struct sockaddr *) &emergencysvr, len2); //just a test string that gets sent over network
    sendto(self.sockfd, emgBytesReadyToSend, numberOfBytes, 0, (struct sockaddr *) &emergencysvr, len2);
    printf("\nEMERGENCY MSG SENT TO MICROCONTROLLER!");
    //close(self.sockfd);
    
}
-(void) closeUDPsocket{
    close(self.sockfd);
}

@end
