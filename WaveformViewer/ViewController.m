//
//  ViewController.m
//  WaveformViewer
//
//  Created by student on 31.01.13.
//  Copyright (c) 2013 student. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    NSBundle* bundle = [NSBundle mainBundle];
    //NSString* file = [bundle pathForResource:@"simple" ofType:@"vcd"];
    //parser = [[VCDParser alloc] initWithVCDFile:file];
    parser = [[VCDParser alloc] initWithVCDFileFromUrl:@"http://dl.dropbox.com/s/2tmn47zyoiqxs7d/very_simple.vcd"];
    [parser parse];
    dict = [parser signalDict];
    keyArray = [dict allKeys];
    beginTime = 0;
    endTime = [[parser.timesArray lastObject] floatValue]/2;
    oldX = -1;
    
    data = [Data shareData];
    
    [data setBeginTime:beginTime];
    [data setEndTime:endTime];
    [data setTapTime:-1.0];
    
    //Cursor-Platzierung
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.tableView addGestureRecognizer:tap];
    
    //Scrollen vertical
    UIPinchGestureRecognizer* pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.tableView addGestureRecognizer:pinch];
    
    //Scrollen horizontal, Verschieben des Cursors
    DirectionPanGestureRecognizer* scroll = [[DirectionPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleScroll:)];
    scroll.direction = DirectionPanGestureRecognizerHorizontal;
    [self.tableView addGestureRecognizer:scroll];
    
    scaleRect = CGRectMake(150, 44+2, self.view.bounds.size.width-150, 25-4);
    scaleView = [[ScaleView alloc] initWithFrame:scaleRect];
    [self.view addSubview:scaleView];
        
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* code that uses the returned key */
        
    static NSString *CellIdentifier = @"Cell";
    Signal* signal = [dict objectForKey:[keyArray objectAtIndex:indexPath.row]];
    
    ViewerCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ViewerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //Text
    cell.textLabel.text = [signal name];
    
    //Drawing
    [cell drawSignal:parser shortName:[signal shortName]];
    
    [scaleView setNeedsDisplay];
    
    //[scaleView removeFromSuperview];
    
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return _objects.count;
    return [keyArray count];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *Zeichnet einen Cursor bei TapGesture
 */
-(void)handleTap:(UITapGestureRecognizer *)sender {
    CGFloat pointX = [sender locationOfTouch:0 inView:scaleView].x;
    CGFloat time = [data beginTime] + (pointX / [data scale]);
    [data setTapTime:time];
//    CGFloat time2 = [data scale] * time;
//    NSLog(@"time: %f, scale: %f beginTime: %f, time2: %f", time, [data scale], [data beginTime], time2);
    
    
    [self.tableView reloadData];
}

-(void)handlePinch:(UIPinchGestureRecognizer *)sender{
    CGFloat velocity = sender.velocity;
    if(sender.velocity > 0) {
        if (velocity < 1){
            velocity = 1;
        } else if(velocity > 30){
            velocity = 30;
        }
    } else if(sender.velocity < 0) {
        if (velocity > -1){
            velocity = -1;
        } else if(velocity < -30){
            velocity = -30;
        }
    }
    endTime -= velocity/3;
    if (endTime < beginTime+10){
        endTime = beginTime+10;
    }
    
    beginTime += velocity/3;
    if (beginTime > endTime -10){
        beginTime = endTime -10;
    } else if (beginTime < 0){
        beginTime = 0;
    }
    [data setBeginTime:beginTime];
    [data setEndTime:endTime];
    
    [self.tableView reloadData];
}

-(void)handleScroll:(DirectionPanGestureRecognizer *)sender{
    CGFloat pointX = [sender locationInView:scaleView].x;
    CGFloat cursorX = [data tapTime]*[data scale];
    if (pointX < cursorX+20 && pointX > cursorX-20) {
        NSLog(@"scroll tap");
        CGFloat time = [data beginTime] + (pointX / [data scale]);
        [data setTapTime:time];
    } else {
        // verhindert zu schnelles scrollen
        CGFloat velocity = 0;
        if (oldX > 0){
            velocity = oldX-[sender locationInView:self.view].x;
        }
        
        if (velocity > 50 || velocity < -50){
            velocity = 0;
        }
    
        //linke Grenze
        oldX = [sender locationInView:self.view].x;
        beginTime += velocity/3;
        endTime += velocity/3;
    
        CGFloat lastTime = [[parser.timesArray lastObject] floatValue];
    
        if (beginTime < 0){
            endTime = endTime - beginTime;
            beginTime = 0;
        } else if (endTime > lastTime){
            beginTime = beginTime + (lastTime - endTime);
            endTime = lastTime;
        }
    
    
        [data setBeginTime:beginTime];
        [data setEndTime:endTime];
    }
    [self.tableView reloadData];

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //Wird bei jeder Rotation aufgerufen!
    [scaleView removeFromSuperview];
    scaleView = nil;
    scaleRect = CGRectMake(150, 44+2, self.view.bounds.size.width-150, 25-4);
    scaleView = [[ScaleView alloc] initWithFrame:scaleRect];
    [self.view addSubview:scaleView];
    
    //[scaleView setNeedsDisplay];
}

- (void)openFile:(id)sender{
    NSLog(@"open");
    
    NSString* urlString = @"http://dl.dropbox.com/s/2tmn47zyoiqxs7d/very_simple.vcd";
    NSError* error;
    NSURL* url = [NSURL URLWithString:urlString];
    NSString* file = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    /*
     NSURL  *url = [NSURL URLWithString:stringURL];
     NSData *urlData = [NSData dataWithContentsOfURL:url];
     if (urlData)
     {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
     
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"filename.png"];
        [urlData writeToFile:filePath atomically:YES];
     }
    */
}

@end
