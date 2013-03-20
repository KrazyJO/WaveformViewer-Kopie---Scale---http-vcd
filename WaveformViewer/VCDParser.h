//
//  VCDParser.h
//  VCDParser
//
//  Created by pluto on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Signal.h"

@interface VCDParser : NSObject {
  NSString *path;
  NSString *vcdStr;
  NSString *currentModule;
  
  NSString *timescale;
  NSString *version;
  
  NSMutableDictionary *signalDict;
  NSMutableArray *timesArray;
  
  NSNumber *currentTime;
    
  //Mod
    NSString* urlPath;
}

@property (nonatomic, retain) NSString *version;

@property (nonatomic, retain) NSString *timescale;
@property (nonatomic, retain) NSMutableDictionary *signalDict;
@property (nonatomic, retain) NSMutableArray *timesArray;


-(id)initWithVCDFile:(NSString*) path;
//Mod->
-(id)initWithVCDFileFromUrl:(NSString*) url;
//<-
-(void)parse;

-(BOOL)processCommand:(NSString*)command withArgument:(NSString*)argument;

@end
