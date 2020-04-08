//
//  parser.h
//  sampleMerge
//
//  Created by Muhammad Daniyal on 4/3/20.
//  Copyright © 2020 MuhammadDaniyal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <stdio.h>
#import <stdlib.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <string.h>
#import <arpa/inet.h>   /* inet(3) functions */

NS_ASSUME_NONNULL_BEGIN

@interface parser : NSObject

//properties:
//bring all the variables from main.m file here and declare them as properties.
@property float GPS_Lat;
@property float GPS_Long;
@property int Ground_speed;
@property short int GPS_VSI;
@property int GPS_heading;
@property int Geo_Altitude;
@property float Firmware_version;
@property int battPct;
@property float roll;
@property float pitch;
@property float yaw;
@property int airspeedKnots;
@property int altitudeFeet;
@property int vsiFtPerMin;


//methods:
-(void) packetParser:(uint8_t *) mesg withSize:(ssize_t) n;
-(void) msgReceiver;

@end

NS_ASSUME_NONNULL_END