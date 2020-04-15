//
//  parser.h
//  At Training
//
//  Created by Muhammad Daniyal on 4/14/20.
//  Copyright © 2020 WASSIM LAGNAOUI. All rights reserved.
//
//
//  parser.h
//  crctester
//
//  Created by Muhammad Daniyal on 4/9/20.
//  Copyright © 2020 MuhammadDaniyal. All rights reserved.
//
//
//  parser.h
//  sampleMerge
//  Created by Muhammad Daniyal on 4/3/20.


#import <Foundation/Foundation.h>

#import <stdio.h>
#import <stdlib.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <string.h>
#import <arpa/inet.h>   /* inet(3) functions */

NS_ASSUME_NONNULL_BEGIN
@interface parser : NSObject
//extern int global;

//properties:s
//bring all the variables from main.m file here and declare them as properties.
@property float gps_Lat;
@property float gps_Long;
@property int ground_speed;
@property short int gps_VSI;
@property int gps_heading;
//@property int gps_Altitude;
@property int geo_Altitude;
@property int mslAltitude;
@property int16_t altitudeVariation; //signed 16 bit
@property float firmware_version;
@property int battPct;
@property float roll;
@property float pitch;
@property float yaw;//yaw = Heading
@property int airspeedKnots;
@property int altitudeFeet;
@property int vsiFtPerMin;
@property uint8_t msgForMicrocontroller; //for normal simulation msgs
@property NSData * emergencyFlipUp; //for emergency visor flip up

//@property NSMutableArray * testMsg;
//@property NSMutableArray * CRC16Table;

//@property uint16_t CRC16Table; //gives error:"Incompatible pointer to integer conversion assigning to 'uint16_t' (aka 'unsigned short') from 'NSMutableArray *' " when i typing:" _CRC16Table = [[NSMutableArray alloc] init]; " that's why i have used NSMutableArray type for this instead (shown below)




//methods:
//-(void) packetParser:(uint8_t *) mesg withSize:(ssize_t) n;
-(void) packetParser:(uint8_t *)preCleanedMessage withSize:(ssize_t) n;
-(void) msgReceiver;
-(void) msgSender;
-(void) scanData: (uint8_t *) RxData_1 ofLength:(uint8_t) BufferLength;
-(unsigned short) gdl90_CRC_Compute: (uint8_t *) data ofLength: (unsigned long)length;
-(void) emergencyMsgSender;
//-(unsigned short) gdl90_CRC_Compute: (uint8_t *) data ofLength: (unsigned long)length;
//-(unsigned short) gdl90_CRC_Compute: (NSMutableArray *) data ofLength: (unsigned long)length;


@end

NS_ASSUME_NONNULL_END
