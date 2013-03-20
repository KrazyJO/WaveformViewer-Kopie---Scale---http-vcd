//
//  Signal.m
//  VCDParser
//
//  Created by pluto on 28.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Signal.h"


@implementation Signal

@synthesize name;
@synthesize shortName;
@synthesize module;
@synthesize valueDict;

-(id)init
{
  self = [super init]; 
  if(self != nil)
  { 
    valueDict = [NSMutableDictionary dictionary];
  }
  return self;
}

@end
