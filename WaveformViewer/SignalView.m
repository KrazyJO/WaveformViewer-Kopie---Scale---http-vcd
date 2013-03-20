//
//  CellView.m
//  WaveformViewer
//
//  Created by student on 31.01.13.
//  Copyright (c) 2013 student. All rights reserved.
//

#import "SignalView.h"
#import "ViewerCell.h"
@implementation SignalView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrameAndCo:(CGRect)frame parser:(VCDParser *)_parser shortName:(NSString *)_shortName{
    self = [super initWithFrame:frame];
    if (self) {
        //parentView = parent;
        parser = _parser;
        data = [Data shareData];
        endTime = data.endTime;
        beginTime = data.beginTime;
        shortName = _shortName;
        tapTime = data.tapTime;
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    x = -1;
    y = self.center.y;
    normalPath = [UIBezierPath bezierPath];
    [normalPath moveToPoint:CGPointMake(x, y)];
    undefPath = [UIBezierPath bezierPath];
    [undefPath moveToPoint:CGPointMake(x, y)];
    highPath = [UIBezierPath bezierPath];
    [highPath moveToPoint:CGPointMake(x, y)];
    
    path = normalPath;
    
    //[[UIColor blackColor] setStroke];
    
    for (Signal *tmp in [parser.signalDict allValues]){
        if ([[tmp shortName] isEqualToString:shortName]){
            signal=tmp;
        }
    }
    
    CGFloat scale = (rect.size.width)/(endTime-beginTime);
    [[Data shareData] setScale:scale];
    NSInteger intTime;
    
    for (NSNumber* time in parser.timesArray){
        NSString *value = [signal.valueDict objectForKey:time];
        
        if (value != NULL) {
            if (time.intValue <= beginTime) {
                if ([value isEqualToString:@"x"]){
                    [self drawUndefined:-1] ;
                }
                if ([value isEqualToString:@"0"]){
                    [self drawLow:-1];
                }
                if ([value isEqualToString:@"1"]){
                    [self drawHigh:-1];
                }
                if ([value isEqualToString:@"z"]){
                    [self drawHighO:-1];
                }
            }
            
            if (time.floatValue > beginTime && time.floatValue < endTime){
                intTime = time.intValue;
                if ([value isEqualToString:@"x"]){
                    [self drawUndefined:(intTime-beginTime)*scale] ;
                }
            
                if ([value isEqualToString:@"0"]){
                    [self drawLow:(intTime-beginTime)*scale];
                }
            
                if ([value isEqualToString:@"1"]){
                    [self drawHigh:(intTime-beginTime)*scale];
                }
            
                if ([value isEqualToString:@"z"]){
                    [self drawHighO:(intTime-beginTime)*scale];
                }
            }
        }
    }
    
    [self drawUndefined:rect.size.width+10];
    [[UIColor blackColor] setStroke];
    [normalPath setLineWidth:1];
    [normalPath stroke];
    [[UIColor blueColor] setStroke];
    [highPath setLineWidth:1];
    [highPath stroke];
    [[UIColor redColor] setStroke];
    [undefPath setLineWidth:1];
    [undefPath stroke];
    
    [self drawCursor];
    
    [super drawRect:rect];
}

-(void) drawHigh:(NSInteger)time{
    x = time;
    [path addLineToPoint:CGPointMake(x, y)];
    //[[UIColor blackColor] setStroke];
    path = normalPath;
    [self moveAllPoints];
    y = self.center.y - 15;
    [path addLineToPoint:CGPointMake(x, y)];
    path = normalPath;
    [self moveAllPoints];
}

-(void) drawHighO:(NSInteger)time{
    x = time;
    [path addLineToPoint:CGPointMake(x, y)];
    //[[UIColor blueColor] setStroke];
    path = normalPath;
    [self moveAllPoints];
    y = self.center.y;
    [path addLineToPoint:CGPointMake(x, y)];
    path = highPath;
    [self moveAllPoints];
}

-(void) drawLow:(NSInteger)time{
    x = time;
    [path addLineToPoint:CGPointMake(x, y)];
    //[[UIColor blackColor] setStroke];
    path = normalPath;
    [self moveAllPoints];
    y = self.center.y + 15;
    [path addLineToPoint:CGPointMake(x, y)];
    path = normalPath;
    [self moveAllPoints];
}

-(void) drawUndefined:(NSInteger)time{
    x = time;
    [path addLineToPoint:CGPointMake(x, y)];
    //[[UIColor redColor] setStroke];
    path = normalPath;
    [self moveAllPoints];
    y=self.center.y;
    [path addLineToPoint:CGPointMake(x, y)];
    path = undefPath;
    [self moveAllPoints];
}

-(void)moveAllPoints{
    [normalPath moveToPoint:CGPointMake(x, y)];
    [undefPath moveToPoint:CGPointMake(x, y)];
    [highPath moveToPoint:CGPointMake(x, y)];
}

-(void)drawCursor {
    if (tapTime > beginTime && tapTime < endTime) {
        CGFloat time = tapTime - beginTime;
        CGFloat pixelX = time * [data scale];
        UIBezierPath* cursorPath = [UIBezierPath bezierPath];
        CGPoint cursorPoint = CGPointMake(pixelX, 0);
        [cursorPath moveToPoint:cursorPoint];
        cursorPoint.y = 150;
        [cursorPath addLineToPoint:cursorPoint];
        
        [cursorPath stroke];
    }
}

@end
