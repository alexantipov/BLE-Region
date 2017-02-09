//
//  SettingsManage.m
//  BleDemo
//
//  Created by Alex on 1/19/17.
//  Copyright © 2017 Alex. All rights reserved.
//

#import "SettingsManage.h"
#import <UIKit/UIKit.h>

@implementation SettingsManage

- (void) opneSettings {
    
    NSURL *bluetoothURLOS8 = [NSURL URLWithString:@"prefs:root=General&path=Bluetooth"];
    NSURL *bluetoothURLOS9 = [NSURL URLWithString:@"prefs:root=Bluetooth"];
    NSURL * bluetoothURLOS10 = [NSURL URLWithString:@"Prefs:root=Bluetooth"];
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 10) {
        Class<NSObject> workSpaceClass = NSClassFromString(@"LSApplicationWorkspace");
        if (workSpaceClass) {
            id workSpaceInstance = [workSpaceClass performSelector:NSSelectorFromString(@"defaultWorkspace")];
            SEL selector = NSSelectorFromString(@"openSensitiveURL:withOptions:");
            if ([workSpaceInstance respondsToSelector:selector]) {
                [workSpaceInstance performSelector:selector withObject:bluetoothURLOS10 withObject:nil];
            }
        }
    }else if ([[[UIDevice currentDevice] systemVersion] intValue] >= 9) {
        [[UIApplication sharedApplication] openURL:bluetoothURLOS9];
    }
    else {
        [[UIApplication sharedApplication] openURL:bluetoothURLOS8];
    }
}

@end
