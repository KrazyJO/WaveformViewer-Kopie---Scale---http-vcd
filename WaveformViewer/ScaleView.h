//
//  ScaleView.h
//  WaveformViewer
//
//  Created by student on 14.02.13.
//  Copyright (c) 2013 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Data.h"

@interface ScaleView : UIView {
    UIBezierPath *path;
    CGFloat x;
    CGFloat y;
    NSInteger beginTime;
    NSInteger endTime;
    CGFloat tapX;
    
    Data* data;
    
    //NSInteger step;
    CGFloat step;
    
    NSMutableArray* textFilds;
}

-(void) drawPoint:(NSInteger)time;
@end
