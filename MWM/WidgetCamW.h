/* ORIGINAL LICENCE */

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

/* ORIGINAL HEADER */
//  Created by Siqi Hao on 4/20/12.
//  Copyright (c) 2012 Meta Watch. All rights reserved.

/* MODIFIED HEADER */
//	Modified by James Snee on 20/8/2012

#import <Foundation/Foundation.h>
#import "MWMWidgetDelegate.h"
#import "CamWeather_Monitor.h"

@interface WidgetCamW : NSObject <UITextFieldDelegate, UIActionSheetDelegate, CamWeather_Delegate>

// MetaWatch Widget Interface
@property (nonatomic, strong) UIView *preview;
@property (nonatomic) NSInteger updateIntvl;
@property (nonatomic) NSInteger updatedTimestamp;
@property (nonatomic, strong) UIView *settingView;
@property (nonatomic, readonly) CGSize widgetSize;
@property (nonatomic, readonly) NSInteger widgetID;
@property (nonatomic, readonly) NSString *widgetName;
@property (nonatomic) CGImageRef previewRef;
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) NSDictionary *weatherDict;

@property (nonatomic, strong)CamWeather_Monitor *cam_weather_monitor;

+ (CGSize) getWidgetSize;

- (void) update:(NSInteger)timestamp;
- (void) prepareToUpdate;
- (void) stopUpdate;

@end

