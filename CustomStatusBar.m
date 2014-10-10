//
//  CustomStatusBar.m
//
//  Created by Adam Strzelecki on 09.10.2014.
//  Copyright (c) 2014 nanoANT Adam Strzelecki. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//
//  Inspired by:
//    https://gist.github.com/guidosabatini/4066796
//    https://github.com/nst/iOS-Runtime-Headers (UIStatusBarComposedData.h)
//
//  Tested on iOS7 simulator and device.

// Make sure you enable it only when doing internal development. Never let this
// code to be compiled to final release, as it will be rejected from AppStore.
#if 1

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef NS_ENUM(unsigned int, StatusBarDataNetworkType) {
  DataTypeGPRS = 0,
  DataTypeEDGE,
  DataType3G,
  DataType4G,
  DataTypeLTE,
  DataTypeWiFi,
  DataTypeWiFiAdHoc,
  DataType1x,
  DataTypeLast = 8,
};
typedef NS_ENUM(unsigned int, StatusBarBatteryState) {
  BatteryStateDepleting = 0,
  BatteryStateCharging,
  BatteryStateFullyCharged,
  BatteryStateLast,
};
typedef struct {
  struct {
    BOOL currentTimeMiddle;
    BOOL doNotDisturbIconRight;
    BOOL airModeLeft;
    BOOL gsmSignalLeft;
    BOOL carrierNameLeft;
    BOOL dataNetworkTypeLeft;
    BOOL currentTimeRight;
    BOOL batteryRightIcon;
    BOOL batteryPercentageRight;
    BOOL batteryPercentageRight2;
    BOOL smallBatteryRightIcon;
    BOOL bluetoothRightIcon;
    BOOL phoneOnKeyboardRightIcon;
    BOOL alarmClockRightIcon;
    BOOL fancyPlusRightIcon;
    BOOL unknown1;
    BOOL locationServicesRightIcon;
    BOOL rotationLockRightIcon;
    BOOL unknown2;
    BOOL airPlayRightIcon;
    BOOL microphoneRightIcon;
    BOOL vpnLeftIcon;
    BOOL icomingCallLeftIcon;
    BOOL spinningWheelLeft;
    BOOL blackSquareLeft;
  } item;
  char timeString[64];
  int gsmSignalStrengthRaw;
  int gsmSignalStrengthBars;
  char serviceString[100];
  char serviceCrossfadeString[100];
  char serviceImages[2][100];
  char operatorDirectory[1024];
  unsigned int serviceContentType;
  int wifiSignalStrengthRaw;
  int wifiSignalStrengthBars;
  StatusBarDataNetworkType dataNetworkType;
  int batteryCapacity;
  StatusBarBatteryState batteryState;
  char batteryDetailString[150];
  int bluetoothBatteryCapacity;
  int thermalColor;
  unsigned int thermalSunlightMode : 1;
  unsigned int slowActivity : 1;
  unsigned int syncActivity : 1;
  char activityDisplayId[256];
  unsigned int bluetoothConnected : 1;
  unsigned int displayRawGSMSignal : 1;
  unsigned int displayRawWifiSignal : 1;
  unsigned int locationIconType : 1;
  unsigned int quietModeInactive : 1;
  unsigned int tetheringConnectionCount;
} StatusBarData;

/// Provides rawData interface for UIStatusBarComposedData
///
/// UIStatusBarComposedData interface is not directly declared in order to not
/// create direct dependency.
@interface NSObject (CustomStatusBar)
- (StatusBarData *)rawData;
@end

/// Provides method replacement for -[UIStatusBarComposedData rawData]
@implementation NSObject (CustomStatusBar)
- (StatusBarData *)CustomStatusBar_rawData
{
  // we call original rawData method, even it seems as we were calling this
  // method again, but methods are exchanged so CustomStatusBar_rawData points
  // to original method implementation
  StatusBarData *data = [self CustomStatusBar_rawData];
  // set custom time
  strcpy(data->timeString, "10:28");
  // set custom service provider name
  strcpy(data->serviceString, "MyGSM");
  // remove all existing items from status bar
  memset(&data->item, 0, sizeof(data->item));
  // select items to be shown in status bar
  data->item.dataNetworkTypeLeft = YES;
  data->item.batteryRightIcon = YES;
  data->item.carrierNameLeft = YES;
  data->item.batteryRightIcon = YES;
  data->item.bluetoothRightIcon = YES;
  data->item.airPlayRightIcon = YES;
  data->item.gsmSignalLeft = YES;
  data->item.currentTimeMiddle = YES;
  // select icon shown by dataNetworkTypeLeft
  data->dataNetworkType = DataTypeWiFi;
  // select number of signal bars shown by gsmSignalLeft
  data->gsmSignalStrengthBars = 5;
  // select number of WiFi signal bars
  data->wifiSignalStrengthBars = 5;
  // set battery capacity and status shown by batteryRightIcon
  data->batteryCapacity = 83;
  data->batteryState = BatteryStateDepleting;
  // return modified data
  return data;
}
@end

@interface CustomStatusBar : NSObject
@end

/// Loader class replacing -[UIStatusBarComposedData rawData] implementation
@implementation CustomStatusBar
+ (void)load
{
  Class cls1 = NSClassFromString(@"UIStatusBarComposedData");
  Class cls2 = [self class];
  Method method1 = class_getInstanceMethod(cls1, @selector(rawData));
  Method method2 =
      class_getInstanceMethod(cls2, @selector(CustomStatusBar_rawData));
  method_exchangeImplementations(method1, method2);
}
@end

#endif
