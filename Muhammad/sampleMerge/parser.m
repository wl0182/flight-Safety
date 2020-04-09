//
//  parser.m
//  sampleMerge
//
//  Created by Muhammad Daniyal on 4/3/20.
//  Copyright © 2020 MuhammadDaniyal. All rights reserved.
//

#import "parser.h"

@implementation parser

//+ for class methods, - for instance methods.
//+(static void) packetParserMsg:uint8_t *mesg andSize:ssize_t n {.... } //OBjectiveC version of following funciton
-(void) packetParser:(uint8_t *)mesg withSize:(ssize_t) n {
    //printf("rcvd from AstroLink:\n");
    uint8_t cleanedMessage[n];
    int counter = 0;
    //remove Byte stuffing from GDL90 messages
    for(int y = 1; y<(n-1); y++)
    {
        //printf("%s ", &mesg[y]); //this prints a string.. but our data is binary
//        printf("%02X ", mesg[y]);
        if (mesg[y] == 0x7D)
        {
            y++;
            cleanedMessage[counter++] = mesg[y]^0x20;
        }
        else cleanedMessage[counter++] = mesg[y];
    }
    printf("\n");
    
    //calculate crc to verify if message is valid
    //if crc == (cleanedMessage[counter-2]+(cleanedMessage[counter-1]<<8)) message passed
    //else do not decode this message..
    //                   unsigned short crc = [self GDL90_CRC_Compute:cleanedMessage:(cleanedMessage.length-2)];
    
    //verify which message we received
    int MID = cleanedMessage[0]; //first byte indicates Message ID
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
          //  NSLog(@"GPS Lat: %0.3f",self.gps_Lat);
          //  NSLog(@"GPS Long: %0.3f",self.gps_Long);
          //  NSLog(@"GPS groundspeed: %d",self.Ground_speed);
          //  NSLog(@"GPS Vert Speed: %d",self.gps_VSI);
            //NSLog(@"GPS Heading: %d",gps_heading);//no need for this. We are probably using yaw value for heading (Ananda named yaw as Heading and it is consistent with utility app
            //NSLog(@"GPS Altitude: %d",Geo_Altitude);// DO NOT USE THIS (as per iLevel code)
            
            break;
            
        case 0x0B: //received only once in 5000 loops
        //    printf("Received GPS ALtitude message\r\n");
            //decode GPS altitude here
            
            //this is ellipsoid ALtitude (not Mean Sea Level Altitude)
            self.geo_Altitude  = (short int)((cleanedMessage[1]<<8)+cleanedMessage[2])*5;
          //  NSLog(@"Geo Altitude: %d", self.Geo_Altitude); //NOT BEING RECEIVED even in 1000 iterations of while loop
            
            break;
            
        case 0x4C: //received iLevil message
            if (cleanedMessage[2] == 0x00)
            {
              //  printf("Received Levil Status message\r\n");
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
                //
                //
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
                NSLog(@"Roll: %.1f, Pitch: %.1f, Heading: %.1f\r\n",self.roll,self.pitch,self.yaw);
                //NSLog(@"Air Speed(kts): %d, Altitude(ft): %d",self.airspeedKnots, self.altitudeFeet);//Values not making sense. AirSpeed = 32767 and Altitude= -1
            }
            break;
            
        default:
            break;
    }
}

- (void) msgReceiver
{
    //@autoreleasepool
    //{
        //variables
        ssize_t n;
        socklen_t len;
        int sockfd;//this socket gets created and destroyed once per each function call
        uint8_t mesg[1024];
        
        //socket
        struct sockaddr_in servaddr,cliaddr;
        sockfd = socket(AF_INET, SOCK_DGRAM, 0);//this socket gets created and destroyed once per each function call
        bzero(&servaddr, sizeof(servaddr));
        servaddr.sin_family = AF_INET;
        servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
        servaddr.sin_port = htons(43211);
        bind(sockfd, (struct sockaddr *) &servaddr, sizeof(servaddr));
        len = sizeof(cliaddr);
        
      //  printf("\nabout to recvfrom\n");
        //int i=0;
        //receive and process loop
        //while (i <1000)
        //{
        n = recvfrom(sockfd, mesg, 1024, 0, (struct sockaddr *) &cliaddr, &len);
      //  printf("\nrecvfrom done \n");
        if (n>0) //if we have bytes
        {
            //create new thread here and destroy thread soon as packetParser returns
            [self packetParser:mesg withSize:n]; //switch
            
        }//if n>0
        
       // printf("\n");
        close(sockfd);//this socket gets created and destroyed once per each function call
        //    i++;
        //}//while
   // }
        
}

@end

// FOLLOWING IS THE FULL MAIN.M FILE THAT RECEIVES MESSAGES FROM ILEVIL DEVICE


 //
 //  main.m
 //  iLevelDecoder
 //
 //  Created by Muhammad Daniyal on 3/16/20.
 //  Copyright © 2020 MuhammadDaniyal. All rights reserved.
 //
 //
 //  THIS CODE RECEIVES MESSAGES FROM ASTROLINK USING UDP SOCKETS ON PORT 43211
 //  Recvfrom() runs 1000 times




/*int main(int argc, const char * argv[]) {
    
    @autoreleasepool
    {
          msgReceiver();
    }

    return 0;
 }
*/

