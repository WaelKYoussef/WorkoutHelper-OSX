//
//  AppDelegate.m
//  WorkoutHelper
//
//  Created by Wael Youssef on 10/9/15.
//  Copyright © 2015 Wael Youssef. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property(nonatomic)int exercisesCount;
@property(nonatomic)int exercises;
@property(nonatomic)int reps;
@property(nonatomic)int repsSubtract;
@property(nonatomic)int timePerRep;
@property(nonatomic)int timePerRepSubtract;
@property(nonatomic)int timePerRest;
@property(nonatomic)int timePerRestSubtract;
@property(nonatomic)BOOL rest;
@property(nonatomic,strong)NSView*homeView;
@property(nonatomic,strong)NSTextField*userInput;
@property(nonatomic,strong)NSView*counterView;
@property(nonatomic,strong)NSTextField*counter;
@property(nonatomic,strong)NSTimer*timer;
@property(nonatomic,strong)NSSound*peepSound;
@property(nonatomic,strong)NSSound*stopSound;

@end

@implementation AppDelegate

-(void)writeLine:(NSString*)line{
    NSMutableAttributedString*line1=[[NSMutableAttributedString alloc] initWithString:line attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:100.0],NSForegroundColorAttributeName:[NSColor whiteColor]}];
    [_counter setAttributedStringValue:line1];
    CGSize size=line1.size;
    size.width+=50.0;
    [_counter setFrame:NSMakeRect((_counterView.bounds.size.width-size.width)/2.0, (_counterView.bounds.size.height-size.height)/2.0, size.width, size.height)];
}

-(void)timerLoop{
    if (_rest) {
        _timePerRestSubtract++;
        if (_timePerRestSubtract==_timePerRest) {
            _timePerRestSubtract=0;
            _rest=false;
            _repsSubtract++;
            if (_repsSubtract==_reps) {
                _repsSubtract=0;
                _exercises--;
                if (_exercises==0) {
                    [_timer invalidate];
                    _timer=nil;
                    
                    [self writeLine:@"DONE"];
                    return;
                }
            }
        }
        else if ((_timePerRest-_timePerRestSubtract)<4){
            [self playBeep];
        }
    }
    else{
        _timePerRepSubtract++;
        if (_timePerRepSubtract==_timePerRep) {
            _timePerRepSubtract=0;
            _rest=true;
            [self playStopBeep];
        }
    }
    [self drawText];
}

-(void)drawText{
    NSMutableParagraphStyle*style=[[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    NSMutableAttributedString*line1=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Exercise: %d | Set: %d\n%@",(_exercisesCount -  _exercises) + 1,_reps-_repsSubtract,_rest?@"REST":@"WORK"] attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:100.0],NSForegroundColorAttributeName:[NSColor whiteColor],NSParagraphStyleAttributeName:style}];
    
    int value=(!_rest?(_timePerRep-_timePerRepSubtract):(_timePerRest-_timePerRestSubtract));
    NSMutableAttributedString*line2=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%d",value] attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:460.0],NSForegroundColorAttributeName:_rest?[NSColor blueColor]:[NSColor whiteColor],NSParagraphStyleAttributeName:style}];
    [line1 appendAttributedString:line2];
    
    [_counter setAttributedStringValue:line1];
    
    CGSize size=line1.size;
    size.width+=50.0;
    //size.height+=20.0;
    [_counter setFrame:NSMakeRect((_counterView.bounds.size.width-size.width)/2.0, (_counterView.bounds.size.height-size.height)/2.0, size.width, size.height)];
}

-(void)playBeep{
    if (_peepSound) { [_peepSound play]; }
}

-(void)playStopBeep{
    if (_stopSound) { [_stopSound play]; }
}

-(void)startWorkout{
    [self drawText];
    _timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerLoop) userInfo:nil repeats:true];
}

-(void)ready{
    [self writeLine:@"READY"];
    [self playBeep];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(set) userInfo:nil repeats:false];
}

-(void)set{
    [self writeLine:@"SET"];
    [self playBeep];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(go) userInfo:nil repeats:false];
}

-(void)go{
    [self writeLine:@"GO"];
    [self playBeep];
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(startWorkout) userInfo:nil repeats:false];
}

-(void)userInputAction{
    NSArray*values=[_userInput.stringValue componentsSeparatedByString:@","];
    if (values.count!=4) {
        [_userInput setStringValue:@""];
        return;
    }
    
    _exercises=[values[0] intValue];
    _exercisesCount=[values[0] intValue];
    _reps=[values[1] intValue];
    _timePerRep=[values[2] intValue];
    _timePerRest=[values[3] intValue];
    _rest=false;
    _repsSubtract=_timePerRepSubtract=_timePerRestSubtract=0;
    
    [_homeView removeFromSuperview];
    [_counterView setFrame:[_window.contentView bounds]];
    [_window.contentView addSubview:_counterView];
    
    [self ready];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    _exercises=_reps=_timePerRep=_timePerRest=0;
    _repsSubtract=_timePerRepSubtract=_timePerRestSubtract=0;
    
    _homeView=[[NSView alloc] initWithFrame:[_window.contentView bounds]];
    [_homeView setWantsLayer:true];
    [_homeView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_homeView.layer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0)];
    [_window.contentView addSubview:_homeView];
    
    
    NSString * infoText = @"Enter the following, comma separated in the same order:\nExercise count, Set count, Set time in seconds, Rest time in seconds";
    NSMutableParagraphStyle * pS = [[NSMutableParagraphStyle alloc] init];
//    [pS setLineBreakMode:NSLineBreakByWordWrapping];
    NSFont * infoFont = [NSFont fontWithName:@"HelveticaNeue" size:25.0];
    
    CGFloat maxWidth = _homeView.bounds.size.width;
    CGRect r =  [infoText boundingRectWithSize:NSMakeSize(maxWidth, 0) options: NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: infoFont, NSParagraphStyleAttributeName: pS}];
    NSTextField * infoLabel=[[NSTextField alloc] initWithFrame:NSMakeRect(0.0,  _homeView.bounds.size.height-r.size.height - 40, maxWidth, r.size.height)];
    [infoLabel setAutoresizingMask:NSViewMaxXMargin|NSViewMinXMargin|NSViewMinYMargin|NSViewWidthSizable];
    [infoLabel setBackgroundColor:[NSColor clearColor]];
    [infoLabel setMaximumNumberOfLines:4];
    [infoLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [infoLabel.layer setOpaque:false];
    [infoLabel setDrawsBackground:true];
    [infoLabel setBordered:false];
    [infoLabel setAlignment:NSTextAlignmentCenter];
    [infoLabel.layer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.0)];
    [infoLabel setFont:infoFont];
    [infoLabel setEditable:false];
    [infoLabel setStringValue:infoText];
    [_homeView addSubview:infoLabel];
    
    NSFont*userInputFont=[NSFont fontWithName:@"HelveticaNeue" size:40.0];
    NSString*userInputHolderString=@"Exercise count, Set count, Rep time, Rest time";
    CGSize userInputSize=[userInputHolderString sizeWithAttributes:@{NSFontAttributeName:userInputFont}];
    userInputSize.height+=10.0;
    _userInput=[[NSTextField alloc] initWithFrame:NSMakeRect(0.0, (_homeView.bounds.size.height-userInputSize.height)/2.0, _homeView.bounds.size.width, userInputSize.height)];
    [_userInput setBackgroundColor:[NSColor clearColor]];
    [_userInput setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin|NSViewMaxYMargin];
    [_userInput.layer setOpaque:false];
    [_userInput setAlignment:NSTextAlignmentCenter];
    [_userInput.layer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.0)];
    [_userInput setFont:userInputFont];
    [_userInput setPlaceholderString:userInputHolderString];
    [_userInput setTarget:self];
    [_userInput setAction:@selector(userInputAction)];
    [_homeView addSubview:_userInput];
    
    _counterView=[[NSView alloc] initWithFrame:[_window.contentView bounds]];
    [_counterView setWantsLayer:true];
    [_counterView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_counterView.layer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0)];
    //[_window.contentView addSubview:_counterView];
    
    _counter=[[NSTextField alloc] initWithFrame:_counterView.bounds];
    [_counter setAutoresizingMask:NSViewMaxXMargin|NSViewMinXMargin|NSViewMinYMargin|NSViewMaxYMargin];
    [_counter setBackgroundColor:[NSColor clearColor]];
    [_counter.layer setOpaque:false];
    [_counter setDrawsBackground:true];
    [_counter setBordered:false];
    [_counter setAlignment:NSTextAlignmentCenter];
    [_counter.layer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.0)];
    [_counter setFont:[NSFont fontWithName:@"HelveticaNeue" size:75.0]];
    [_counter setEditable:false];
    [_counter setStringValue:@"Counter"];
    [_counterView addSubview:_counter];
    
    _peepSound=[[NSSound alloc] initWithContentsOfFile:@"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/telephony/dtmf-0.caf" byReference:YES];
    _stopSound=[[NSSound alloc] initWithContentsOfFile:@"/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/telephony/busy_tone_ansi.caf" byReference:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
