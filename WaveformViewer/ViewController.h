//
//  ViewController.h
//  WaveformViewer
//
//  Created by student on 31.01.13.
//  Copyright (c) 2013 student. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCDParser.h"
#import "ViewerCell.h"
#import "DirectionPanGestureRecognizer.h"
#import "Data.h"
#import "ScaleView.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    VCDParser *parser;
    NSMutableDictionary* dict;
    NSArray* keyArray;
    CGFloat beginTime;
    CGFloat endTime;
    CGFloat oldX;
    
    Data* data;
    ScaleView *scaleView;
    CGRect scaleRect;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)openFile:(id)sender;

-(void) handlePinch: (UIPinchGestureRecognizer*) sender;
-(void) handleScroll: (DirectionPanGestureRecognizer*) sender;
-(void) handleTap: (UITapGestureRecognizer*) sender;

@end
