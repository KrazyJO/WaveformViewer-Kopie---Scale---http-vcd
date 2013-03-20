//
//  Signal.h
//  VCDParser
//
//  Created by pluto on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Signal : NSObject {

  NSString *name;
  NSString *shortName;
  NSString *module;
  
  NSMutableDictionary *valueDict;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *shortName;
@property (nonatomic, retain) NSString *module;
@property (nonatomic, retain) NSMutableDictionary *valueDict;

-(id)init;

@end
