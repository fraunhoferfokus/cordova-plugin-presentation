/*
 * Copyright 2014 Fraunhofer FOKUS
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * AUTHORS: Martin Lasak <martin.lasak@fokus.fraunhofer.de>
 */

#ifndef DevicePickerViewController_h
#define DevicePickerViewController_h

#import <UIKit/UIKit.h>
#import "WebscreenViewController.h"

@protocol DevicePickerDelegate;

@interface DevicePickerViewController : UIViewController  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<DevicePickerDelegate> pickerDelegate;
@property (nonatomic, strong) NSString *sid;
@property (nonatomic, strong) NSMutableArray *screens;
@property (nonatomic, strong) UITableView *table;

-(void)addScreen:(WebscreenViewController *)screen;
-(void)removeScreen:(WebscreenViewController *)screen;

@end

@protocol DevicePickerDelegate <NSObject>
- (void)dismissPickerRequested:(DevicePickerViewController *)controller withSession:(NSString *)sessionId;
- (void)picker:(DevicePickerViewController *)controller didSelectScreen:(WebscreenViewController *)screen forSession:(NSString *)sid;
- (void)loadedPicker;
@end

#endif
