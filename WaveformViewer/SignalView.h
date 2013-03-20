//
//  CellView.h
//  WaveformViewer
//
//  Created by student on 31.01.13.
//  Copyright (c) 2013 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCDParser.h"
#import "Data.h"

@interface SignalView : UIView{
    UIBezierPath *normalPath;
    UIBezierPath *undefPath;
    UIBezierPath *highPath;
    UIBezierPath *path;
    CGFloat x;
    CGFloat y;
    Signal* signal;
    CGFloat beginTime;
    CGFloat endTime;
    CGFloat tapTime;
    
    VCDParser* parser;
    NSString* shortName;
    
    Data* data;
}

-(void) drawLow:(NSInteger)time;
-(void) drawHigh:(NSInteger)time;
-(void) drawHighO:(NSInteger)time;
-(void) drawUndefined:(NSInteger)time;
-(void) drawCursor;

-(void)moveAllPoints;

-(id) initWithFrameAndCo:(CGRect)frame parser:(VCDParser*)_parser shortName:(NSString *)_shortName;

@end
