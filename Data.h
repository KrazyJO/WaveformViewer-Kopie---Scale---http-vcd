//
//  Data.h
//  WaveformViewer
//
//  Created by student on 14.02.13.
//  Copyright (c) 2013 student. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Data : NSObject {
}

@property CGFloat scale;
@property CGFloat beginTime;
@property CGFloat endTime;
@property CGFloat tapTime;


+ (Data *)shareData;

-(CGFloat) beginTimeInPixel;
-(CGFloat) endTimeInPixel;

@end