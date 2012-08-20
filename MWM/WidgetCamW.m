/*****************************************************************************
 *  Copyright (c) 2011 Meta Watch Ltd.                                       *
 *  www.MetaWatch.org                                                        *
 *                                                                           *
 =============================================================================
 *                                                                           *
 *  Licensed under the Apache License, Version 2.0 (the "License");          *
 *  you may not use this file except in compliance with the License.         *
 *  You may obtain a copy of the License at                                  *
 *                                                                           *
 *    http://www.apache.org/licenses/LICENSE-2.0                             *
 *                                                                           *
 *  Unless required by applicable law or agreed to in writing, software      *
 *  distributed under the License is distributed on an "AS IS" BASIS,        *
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. *
 *  See the License for the specific language governing permissions and      *
 *  limitations under the License.                                           *
 *                                                                           *
 *****************************************************************************/

//
//  WidgetWeather.m
//  MWM
//
//  Created by Siqi Hao on 4/20/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "WidgetCamW.h"

@implementation WidgetCamW

@synthesize preview, updateIntvl, updatedTimestamp, settingView, widgetSize, widgetID, delegate, previewRef, widgetName, cam_weather_monitor, weatherDict;

static NSInteger widget = 10011;
static CGFloat widgetWidth = 96;
static CGFloat widgetHeight = 32;

+ (CGSize) getWidgetSize {
    return CGSizeMake(widgetWidth, widgetHeight);
}

- (id)init
{
    self = [super init];
    if (self) {
        widgetSize = CGSizeMake(widgetWidth, widgetHeight);
        preview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widgetWidth, widgetHeight)];
        widgetID = widget;
        widgetName = @"WidgetCamW";
        updateIntvl = 60;
        updatedTimestamp = 0;
        
		//Setup delegation
        cam_weather_monitor = [CamWeather_Monitor sharedCamMonitor];
		cam_weather_monitor.delegate = self;
        
        // Setting
		/*
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"WidgetWeatherSettingView" owner:nil options:nil];
        self.settingView = [topLevelObjects objectAtIndex:0];
        self.settingView.alpha = 0;
        [(UISegmentedControl*)[settingView viewWithTag:3001] addTarget:self action:@selector(toggleValueChanged:) forControlEvents:UIControlEventValueChanged];
        if (useCelsius) {
            [(UISegmentedControl*)[settingView viewWithTag:3001] setSelectedSegmentIndex:0];
        } else {
            [(UISegmentedControl*)[settingView viewWithTag:3001] setSelectedSegmentIndex:1];
        }
        
        [(UITextField*)[settingView viewWithTag:3002] setDelegate:self];
        [(UITextField*)[settingView viewWithTag:3002] setText:currentCityName];
        
        [(UIButton*)[settingView viewWithTag:3003] addTarget:self action:@selector(updateBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (updateIntvl == 30*60) {
            [(UIButton*)[settingView viewWithTag:3003] setTitle:@"Half an Hour" forState:UIControlStateNormal];
        } else if (updateIntvl == 3600) {
            [(UIButton*)[settingView viewWithTag:3003] setTitle:@"Hourly" forState:UIControlStateNormal];
        } else if (updateIntvl == 2*3600) {
            [(UIButton*)[settingView viewWithTag:3003] setTitle:@"2 Hours" forState:UIControlStateNormal];
        } else if (updateIntvl == 6*3600) {
            [(UIButton*)[settingView viewWithTag:3003] setTitle:@"6 Hours" forState:UIControlStateNormal];
        } else if (updateIntvl == 24*3600) {
            [(UIButton*)[settingView viewWithTag:3003] setTitle:@"Daily" forState:UIControlStateNormal];
        } else {
            [(UIButton*)[settingView viewWithTag:3003] setTitle:@"Hourly" forState:UIControlStateNormal];
            updateIntvl = 3600;
            [self saveData];
        }
		 */
        
    }
    return self;
}

- (void) camWeather_didUpdate: (NSDictionary *)cam_weather{
	[self setWeatherDict:cam_weather];
	NSLog(@"DEBUG -- WEATHER DID UPDATE!!!");
	NSLog(@"DEBUG -- WEATHER: %@",[[weatherDict allValues] description]);
	[self drawWeather];
	[delegate widget:self updatedWithError:nil];
}

- (void) camWeather_updateDidFailWithError:(NSString *)error_text{
	NSLog(@"Error: %@",error_text);
}

- (void) prepareToUpdate {
    [cam_weather_monitor start_monitor];
    [delegate widgetViewCreated:self];
}

- (void) stopUpdate {
	[cam_weather_monitor stop_monitor];
}

- (void) update:(NSInteger)timestamp {
    if (timestamp < 0 || (timestamp - updatedTimestamp >= updateIntvl && updateIntvl >= 0)) {
        // -1: force update; update by interval; update by next calendar
        if (timestamp < 0) {
            timestamp = (NSInteger)[NSDate timeIntervalSinceReferenceDate];
        }
        [self doInternalUpdate:timestamp];
    }
}

- (void) doInternalUpdate:(NSInteger)timestamp {
    updatedTimestamp = timestamp;
	[cam_weather_monitor fetch_weather];
}

- (void) drawNullWeatherWithText:(NSString*)drawingText {
    UIFont *font = [UIFont fontWithName:@"MetaWatch Small caps 8pt" size:8];   
    //UIFont *largeFont = [UIFont fontWithName:@"MetaWatch Large 16pt" size:16];
    CGSize size  = CGSizeMake(widgetWidth, widgetHeight);
    
    UIGraphicsBeginImageContextWithOptions(size,NO,1.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(ctx, [[UIColor clearColor]CGColor]);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, widgetWidth, widgetHeight));
    
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    
    /*
     Draw the Weather
     */
    [drawingText drawInRect:CGRectMake(0, 12, widgetWidth, widgetHeight) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    CGImageRelease(previewRef);
    previewRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();   
    
    for (UIView *view in self.preview.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = 7001;
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.preview addSubview:imageView];
}

- (void) drawWeather {
    if (weatherDict == nil) {
        [self drawNullWeatherWithText:@"No Weather Data"];
        return;
    }
    
    UIFont *font = [UIFont fontWithName:@"MetaWatch Small caps 8pt" size:8];   
    //UIFont *largeFont = [UIFont fontWithName:@"MetaWatch Large 16pt" size:16];
    CGSize size  = CGSizeMake(widgetWidth, widgetHeight);

    UIGraphicsBeginImageContextWithOptions(size,NO,1.0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    
    //CGContextSetFillColorWithColor(ctx, [[UIColor clearColor]CGColor]);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, widgetWidth, widgetHeight));
    
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    
    /*
     Draw the Weather
     */	
	NSString *weather = [NSString stringWithFormat:@"Temp: %@\nHumid: %@, Wind: %@, Summary: %@",[weatherDict objectForKey:@"TEMP"],[weatherDict objectForKey:@"HUMID"],[weatherDict objectForKey:@"WIND"],[weatherDict objectForKey:@"SUMMARY"]];
	[weather drawInRect:CGRectMake(0, 2, widgetWidth-1,widgetHeight-1) withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	
    
    // transfer image
    CGImageRelease(previewRef);
    previewRef = CGBitmapContextCreateImage(ctx);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();   
    
    for (UIView *view in self.preview.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = 7001;
    imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.preview addSubview:imageView];

}

- (void) dealloc {
    CGImageRelease(previewRef);
    [self stopUpdate];
    [delegate widgetViewShoudRemove:self];
}

@end
