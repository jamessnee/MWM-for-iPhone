//
//  CamWeather_Monitor.m
//  MWM
//
//  Created by James Snee on 20/08/2012.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import "CamWeather_Monitor.h"

#define CAM_W_UPDATE_RATE 60

@implementation CamWeather_Monitor
@synthesize curr_temp, curr_humid, curr_wind, curr_summary, curr_cam_weather, delegate, running, monitor_timer;

static CamWeather_Monitor *cam_weather_monitor;
+ (CamWeather_Monitor *) sharedCamMonitor{
	if(cam_weather_monitor == nil){
		cam_weather_monitor = [[CamWeather_Monitor alloc]init];
	}
	return cam_weather_monitor;
}

- (id) init{
	self = [super init];
	if(self){
		curr_temp = @"";
		curr_humid = @"";
		curr_wind = @"";
		curr_summary = @"";
		NSArray *keys = [[NSArray alloc]initWithObjects:@"TEMP",@"HUMID",@"WIND",@"SUMMARY",nil];
		NSArray *vals = [[NSArray alloc]initWithObjects:curr_temp,curr_humid,curr_wind,curr_summary, nil];
		curr_cam_weather = [[NSDictionary alloc] initWithObjects:vals forKeys:keys];
		
		update_rate = CAM_W_UPDATE_RATE;
		
		running = NO;
	}
	return self;
}

- (void) fetch_weather{
	NSLog(@"Fetching Weather");
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	dispatch_async(queue, ^{
		NSError *error;
		NSString *top_contents = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.cl.cam.ac.uk/research/dtg/weather/current-obs.txt"] encoding:NSUTF8StringEncoding error:&error];
		if(error){
			dispatch_sync(dispatch_get_main_queue(), ^{
				[delegate camWeather_updateDidFailWithError:[error description]];
			});
		}else{
			NSArray *lines = [top_contents componentsSeparatedByString:@"\n"];
			//Clean the array
			NSMutableArray *lines_clean = [[NSMutableArray alloc]init];
			for(NSString *line in lines){
				if (![line isEqualToString:@""]) {
					[lines_clean addObject:line];
				}
			}
			//Temperature
			NSString *line_temp = [lines_clean objectAtIndex:1];
			NSString *temp = [[line_temp componentsSeparatedByString:@":"] objectAtIndex:1];
			temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
			curr_temp = temp;
			
			//Humid
			NSString *line_humid = [lines_clean objectAtIndex:3];
			NSString *humid = [[line_humid componentsSeparatedByString:@":"] objectAtIndex:1];
			humid = [humid stringByReplacingOccurrencesOfString:@" " withString:@""];
			curr_humid = humid;
			
			//Wind
			NSString *line_wind = [lines_clean objectAtIndex:5];
			NSString *wind_line = [[line_wind componentsSeparatedByString:@":"] objectAtIndex:1];
			NSArray *wind_arr = [wind_line componentsSeparatedByString:@" "];
			NSString *wind;
			for (NSString *component in wind_arr){
				if(![component isEqualToString:@""]){
					wind = component;
					break;
				}
			}
			curr_wind = wind;
			
			//Summary
			NSString *summary_line = [lines_clean objectAtIndex:8];
			NSString *summary = [[summary_line componentsSeparatedByString:@":"] objectAtIndex:1];
			summary = [summary stringByReplacingOccurrencesOfString:@" " withString:@""];
			curr_summary = summary;
		}
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			NSArray *keys = [[NSArray alloc]initWithObjects:@"TEMP",@"HUMID",@"WIND",@"SUMMARY",nil];
			NSArray *vals = [[NSArray alloc]initWithObjects:curr_temp,curr_humid,curr_wind,curr_summary, nil];
			curr_cam_weather = [[NSDictionary alloc] initWithObjects:vals forKeys:keys];
			[delegate camWeather_didUpdate:curr_cam_weather];
		});
	});
}

- (void) start_monitor{
	if (!running) {
		//monitor_timer = [NSTimer timerWithTimeInterval:update_rate target:self selector:@selector(fetch_weather) userInfo:nil repeats:YES];
		running = YES;
		NSLog(@"Monitor Started");
	}
	NSLog(@"Monitor already running");
}

- (void) stop_monitor{
	if(running){
		[monitor_timer invalidate];
		monitor_timer = nil;
		running = NO;
		NSLog(@"Monitor Stopped");
	}
	NSLog(@"Monitor is already stopped");
}

- (int) get_update_rate{
	return update_rate;
}

- (void) set_update_rate:(int)rate{
	update_rate = rate;
}

@end
