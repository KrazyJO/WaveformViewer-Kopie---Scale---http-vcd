//
//  ViewerCell.h
//  WaveformViewer
//
//  Created by student on 31.01.13.
//  Copyright (c) 2013 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCDParser.h"
#import "SignalView.h"

#define DISTANCE 150

@interface ViewerCell : UITableViewCell {
    CGRect rect;
    VCDParser* parser;
    NSString* shortName;
    SignalView *cellView;
}

@property Signal* signal;

-(void)drawSignal:(VCDParser*)_parser shortName:(NSString *)_shortName;

-(void)drawSignal;

@end
