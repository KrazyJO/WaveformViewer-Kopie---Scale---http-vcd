//
//  Data.m
//  WaveformViewer
//
//  Created by student on 14.02.13.
//  Copyright (c) 2013 student. All rights reserved.
//

#import "Data.h"

@implementation Data {
    
}

+(Data *) shareData {
    static Data *sharedData;
    
    @synchronized(self)
    {
        if (!sharedData)
            sharedData = [[Data alloc] init];
        
        return sharedData;
    }

}

-(CGFloat) beginTimeInPixel{
    return self.beginTime / self.scale;
}

-(CGFloat)endTimeInPixel{
    return self.endTime / self.scale;
}
@end
