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

#import <UIKit/UIKit.h>
#import "DevicePickerViewController.h"

@implementation DevicePickerViewController

-(IBAction)cancelButtonPressed:(id)sender
{
    NSLog(@"cancelButtonPressed");
    [self.pickerDelegate dismissPickerRequested:self withSession:self.sid];

}

-(void)addScreen:(WebscreenViewController *)screen
{
    [self.screens addObject:screen];
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)removeScreen:(WebscreenViewController *)screen
{
    [self.screens removeObject:screen];
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.screens = [[NSMutableArray alloc] init];

    self.table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.table];

    self.title = @"Screen Selection";

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:doneButton];

    [self.pickerDelegate loadedPicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.screens count] > 0) {
        return @"Available screens";
    }
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([self.screens count] > 0) {
    return @"Please select one of the above screens to start your Webscreen presentation on.";
    }

    return @"No screen is available. Please attach a video cable to this device or activate wireless screen mirroring (e.g. AirPlay).";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.screens.count==0) {
        return 1;
    }
    return self.screens.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.imageView.image = nil;

    if(self.screens.count==0){
        cell.textLabel.text =  @"No screens connected.";
        [cell setUserInteractionEnabled:false];
        cell.textLabel.textColor = [UIColor grayColor];
    } else {

        WebscreenViewController *wvc = [self.screens objectAtIndex:indexPath.row];
        UIScreen *screen = wvc.window.screen;
        cell.textLabel.text = [NSString stringWithFormat:@"Display: #%@",[wvc.screenId substringFromIndex:31]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Apple TV or Cable at resolution %@",NSStringFromCGSize(screen.bounds.size)];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.screens.count==0) {
        return;
    }
    WebscreenViewController *wvc = [self.screens objectAtIndex:indexPath.row];
    [self.pickerDelegate picker:self didSelectScreen:wvc forSession:self.sid];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
