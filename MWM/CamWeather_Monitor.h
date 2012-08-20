//
//  CamWeather_Monitor.h
//  MWM
//
//  Created by James Snee on 20/08/2012.
//  Copyright (c) 2012 Meta Watch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CamWeather_Monitor : NSObject{
	int update_rate;
}

+ (CamWeather_Monitor *) sharedCamMonitor;

@property (strong, nonatomic) NSString *curr_temp;
@property (strong, nonatomic) NSString *curr_humid;
@property (strong, nonatomic) NSString *curr_wind;
@property (strong, nonatomic) NSString *curr_summary;
@property (strong, nonatomic) NSDictionary *curr_cam_weather;
@property BOOL running;
@property (strong, nonatomic) NSTimer *monitor_timer;

@property (assign, nonatomic) id delegate;

- (void) fetch_weather;

- (int) get_update_rate;
- (void) set_update_rate:(int)rate;

- (void) start_monitor;
- (void) stop_monitor;

@end

@protocol CamWeather_Delegate <NSObject>

- (void) camWeather_didUpdate: (NSDictionary *)cam_weather;
- (void) camWeather_updateDidFailWithError:(NSString *)error_text;

@end
