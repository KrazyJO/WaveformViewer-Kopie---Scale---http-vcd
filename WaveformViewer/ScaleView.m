//
//  ScaleView.m
//  WaveformViewer
//
//  Created by student on 14.02.13.
//  Copyright (c) 2013 student. All rights reserved.
//

#import "ScaleView.h"

@implementation ScaleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        data = [Data shareData];
        step = 10;
        textFilds = [[NSMutableArray alloc] init];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //Alle TextFelder entfernen
    for (UITextField* tmp in textFilds){
        [tmp removeFromSuperview];
        //[textFilds removeObject:tmp]; //Fehler!!! nicht loeschen waerend der schleife!
    }
    [textFilds removeAllObjects];
    
    x = -1;
    y = rect.size.height-2;
    path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(x, y)];
    [path addLineToPoint:CGPointMake(rect.size.width+1, y)];
    
    NSInteger beginTimeCut = data.beginTime /step;
    beginTimeCut *= step;
    
    if (step*data.scale < 20){
        step *=2;
    } else if (step*data.scale > 40){
        step /=2;
    }
     
    for (NSInteger n=0-(data.beginTime-beginTimeCut); n < (data.endTime-data.beginTime); n=n+step){
        [self drawPoint:n*data.scale];
        UITextField *tmp = [[UITextField alloc] init];
        
        NSInteger time = beginTimeCut+(step*(textFilds.count));
        
        NSString* string = [[NSString alloc] initWithFormat:@"%d",time];
        
        [tmp setText:string];
        [tmp setFont:[UIFont systemFontOfSize: 8.0]];
        [tmp setFrame:CGRectMake((n*data.scale)+1, 0, 18, 10)];
        [self addSubview:tmp];
        
        [textFilds addObject:tmp];
    }
    
    [[UIColor blackColor] setStroke];
    [path setLineWidth:1];
    [path stroke];
}


-(void) drawPoint:(NSInteger)time{
    x = time;
    [path moveToPoint:CGPointMake(x, y)];
    
    [path addLineToPoint:CGPointMake(x, y-10)];
}
@end
