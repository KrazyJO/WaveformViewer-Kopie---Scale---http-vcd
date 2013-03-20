//
//  ViewerCell.m
//  WaveformViewer
//
//  Created by student on 31.01.13.
//  Copyright (c) 2013 student. All rights reserved.
//

#import "ViewerCell.h"

@implementation ViewerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        rect = CGRectMake(DISTANCE, 2, self.bounds.size.width, self.bounds.size.height-4);
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)drawSignal:(VCDParser *)_parser shortName:(NSString *)_shortName{
    rect = CGRectMake(DISTANCE, 2, self.bounds.size.width-DISTANCE, self.bounds.size.height-4);
    parser=_parser;
    shortName=_shortName;
}

-(void)layoutSubviews{
    rect = CGRectMake(DISTANCE, 2, self.bounds.size.width, self.bounds.size.height-4);
    if (parser != nil) {
        [self drawSignal];
    }
    [super layoutSubviews];
}

-(void)drawSignal{
    [cellView removeFromSuperview];
    cellView = [[SignalView alloc] initWithFrameAndCo:rect parser:parser shortName:shortName];
    [self addSubview:cellView];
}

@end
