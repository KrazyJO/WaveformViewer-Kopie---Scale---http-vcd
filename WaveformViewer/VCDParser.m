#import "VCDParser.h"

@implementation VCDParser
@synthesize timescale;
@synthesize version;
@synthesize signalDict;
@synthesize timesArray;

-(id)initWithVCDFile:(NSString*) pathToVCD
{
    self = [super init];
    if(self != nil)
    {
        path = pathToVCD;
        signalDict = [NSMutableDictionary dictionary];
        timesArray = [NSMutableArray array];
        currentTime = [NSNumber numberWithInt:-1];
    }
    return self;
}

//Mod->
-(id)initWithVCDFileFromUrl:(NSString*) urlToVCD
{
    self = [super init];
    if(self != nil)
    {
        urlPath = urlToVCD;
        signalDict = [NSMutableDictionary dictionary];
        timesArray = [NSMutableArray array];
        currentTime = [NSNumber numberWithInt:-1];
    }
    return self;
}
//<-

-(void)parse
{
  NSError *error;
  //Ori ->
  //vcdStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
  //<-
    
  //Mod ->
    if (path != nil){
        vcdStr = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    } else if (urlPath != nil){
        NSURL* url = [NSURL URLWithString:urlPath];
        vcdStr = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    }
    
        
  //<-
  if (vcdStr == nil) {
    NSLog(@"Error reading file at %@\n%@",path, [error localizedFailureReason]);
  }
  else {
    int vcdStrLen = [vcdStr length];
    
    NSRange cmdStartRange;
    cmdStartRange = NSMakeRange(0, vcdStrLen);
    
    NSRange cmdEndRange;
    NSRange cmdRange;
    NSRange argRange;
    BOOL endDefinitionsReached=NO;
    
    //parse definitions:
    while(YES) {
      //searching for begin of command, defined with '$':
      cmdStartRange = [vcdStr rangeOfString:@"$" options:0 range:cmdStartRange];
      if(cmdStartRange.length==0) break; //no more commands found -> break loop
      
      //searching for end of command, defined with whitespace:
      cmdEndRange = NSMakeRange(cmdStartRange.location,vcdStrLen-cmdStartRange.location);
      cmdEndRange = [vcdStr rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0 range:cmdEndRange];
      if(cmdEndRange.length==0) break; //no more commands found -> break loop
      
      //set the index range of the found command
      cmdRange = NSMakeRange(cmdStartRange.location+1, cmdEndRange.location-cmdStartRange.location-1); 
      //get the string of the command:
      NSString *cmd = [vcdStr substringWithRange:cmdRange];

      //search for next '$end':
      cmdStartRange = NSMakeRange(cmdRange.location+cmdRange.length,vcdStrLen-cmdRange.location-cmdRange.length);
      cmdStartRange = [vcdStr rangeOfString:@"$end" options:0 range:cmdStartRange];
      if(cmdStartRange.length==0)
      {
        NSLog(@"Error: No $end of command %@ found\n",cmd);
        return;
      }

      //get the argument index range of the command:
      argRange = NSMakeRange(cmdRange.location+cmdRange.length, cmdStartRange.location-cmdRange.location-cmdRange.length);        
      //get the string of the argument:
      NSString *arg = [vcdStr substringWithRange:argRange];
      //trimm whitespace:
      arg = [arg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];      
      
      //process command:
      if(![self processCommand:cmd withArgument:arg]) 
      {
        endDefinitionsReached = YES;
        break;
      }
      //set new starting point of next command search;
      cmdStartRange.location = argRange.location+argRange.length+1;
      cmdStartRange.length = vcdStrLen-cmdStartRange.location;
      if(cmdStartRange.location >= vcdStrLen) break;
    } 

    //parse signal values:
    if(endDefinitionsReached) 
    {
      cmdStartRange.location = argRange.location+argRange.length+1;
      cmdStartRange.length = vcdStrLen-cmdStartRange.location;
      
      while(YES)
      {
        cmdEndRange = [vcdStr rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"$#01xXzZ"] options:0 range:cmdStartRange];
        if(cmdEndRange.length == 0) break;
        
        NSString *token = [vcdStr substringWithRange:cmdEndRange];

        //search for next whitespace:
        cmdStartRange.location = cmdEndRange.location + cmdEndRange.length;
        cmdStartRange.length = [vcdStr length] - cmdStartRange.location;
        cmdEndRange = [vcdStr rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0 range:cmdStartRange];
        
        //get substring between token and whitespace
        cmdRange.location = cmdStartRange.location;
        cmdRange.length = cmdEndRange.location - cmdStartRange.location;
        NSString *tokenVal = [vcdStr substringWithRange:cmdRange];

        if([token compare:@"#"] == NSOrderedSame)
        {
          //token is a time
          currentTime = [NSNumber numberWithInt:[tokenVal intValue]];
          [timesArray addObject:currentTime];
        }
        else if([token compare:@"$"] == NSOrderedSame)
        {
          //token is a command, simulation commands are not implemented yet
        }
        else //token is a value
        {
          //replace beginning '@' char by 'xx' as strings begining with '@' are invalid as key...
          if([[tokenVal substringToIndex:1] isEqualToString:@"@"])
          {
            NSString *tmpStr = @"xx";
            tokenVal = [tmpStr stringByAppendingString:[tokenVal substringFromIndex:1]];
          }
          cmdStartRange = [vcdStr rangeOfString:@"$" options:0 range:cmdStartRange];
          Signal *signal = [signalDict valueForKey:tokenVal];

//          NSLog(@"Signal %@ changed to value %@ at time %@\n",signal.name,token,currentTime);
          
          [signal.valueDict setObject:token forKey:currentTime];
        }
        
        cmdStartRange.location = cmdEndRange.location + cmdEndRange.length;
        cmdStartRange.length = vcdStrLen-cmdStartRange.location;
      }
    }
  }
}

-(BOOL)processCommand:(NSString*)command withArgument:(NSString*)argument;
{
  if([command compare:@"timescale"] == NSOrderedSame)
  {
    timescale = argument;
  }
  else if([command compare:@"version"] == NSOrderedSame)
  {
    version = argument;
  }
  else if([command compare:@"scope"] == NSOrderedSame)
  {
    NSRange modRange;
    modRange = [argument rangeOfString:@"module"];
    if(modRange.length == 0)
    {
      NSLog(@"Warning: Argument %@ of command scope is not supported (only module is supported)",argument);
      return YES;
    }
    modRange.location += modRange.length;
    modRange.length = [argument length]-modRange.location;
    currentModule = [argument substringWithRange:modRange];
    currentModule = [currentModule stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];      
  }
  else if([command compare:@"var"] == NSOrderedSame)
  {
    NSRange wireStartRange,wireStopRange,wireRange;
    wireStartRange = [argument rangeOfString:@"wire"];
    if(wireStartRange.length == 0)
    {
      NSLog(@"Warning: Argument %@ of command var is not supported (only wire is supported)",argument);
      return YES;
    }
    wireStartRange.location += wireStartRange.length+1;
    wireStartRange.length = [argument length]-wireStartRange.location;
    NSString *wireArg = [argument substringWithRange:wireStartRange];

    //search for next whitespace:
    wireStartRange = [wireArg rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *sizeStr = [wireArg substringToIndex:wireStartRange.location];
    
    //search for next whitespace:
    wireStartRange.location += wireStartRange.length;
    wireStartRange.length = [wireArg length] - wireStartRange.location;
    wireStopRange = [wireArg rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0 range:wireStartRange];
    
    //get substring between whitespaces
    wireRange.location = wireStartRange.location;
    wireRange.length = wireStopRange.location - wireStartRange.location;
    NSString *signalShortName = [wireArg substringWithRange:wireRange];
    
    //replace beginning '@' char by 'xx' as strings begining with '@' are invalid as key...
    if([[signalShortName substringToIndex:1] isEqualToString:@"@"])
    {
      NSString *tmpStr = @"xx";
      signalShortName = [tmpStr stringByAppendingString:[signalShortName substringFromIndex:1]];
    }
    
    NSString *signalName = [wireArg substringFromIndex:wireStopRange.location];
    //trimm whitespace:
    signalName = [signalName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];      
    
    Signal *signal = [[Signal alloc] init];
    [signal setName:signalName];
    [signal setShortName:signalShortName];
    [signal setModule:currentModule];

    //store signal in signalDict:
    [signalDict setValue:signal forKey:signalShortName];
  }
  else if([command compare:@"enddefinitions"] == NSOrderedSame)
  {
    return NO; //stop further processing of commands
  }  
  else if([command compare:@"comment"] == NSOrderedSame)
  {
    //ignore comments
  }
  else if([command compare:@"upscope"] == NSOrderedSame)
  {
    //module hierarchy not implemented yet
  }
  else if([command compare:@"date"] == NSOrderedSame)
  {
    //date is ignored
  }
  else
  {
    NSLog(@"Warning: Command '%@' not supported",command);
  }
  
  return YES; //further process data
}
@end
