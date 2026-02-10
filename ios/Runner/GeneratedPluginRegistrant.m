//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<environment_sensors/EnvironmentSensorsPlugin.h>)
#import <environment_sensors/EnvironmentSensorsPlugin.h>
#else
@import environment_sensors;
#endif

#if __has_include(<geolocator_apple/GeolocatorPlugin.h>)
#import <geolocator_apple/GeolocatorPlugin.h>
#else
@import geolocator_apple;
#endif

#if __has_include(<sensors_plus/FPPSensorsPlusPlugin.h>)
#import <sensors_plus/FPPSensorsPlusPlugin.h>
#else
@import sensors_plus;
#endif

#if __has_include(<sqlite3_flutter_libs/Sqlite3FlutterLibsPlugin.h>)
#import <sqlite3_flutter_libs/Sqlite3FlutterLibsPlugin.h>
#else
@import sqlite3_flutter_libs;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [EnvironmentSensorsPlugin registerWithRegistrar:[registry registrarForPlugin:@"EnvironmentSensorsPlugin"]];
  [GeolocatorPlugin registerWithRegistrar:[registry registrarForPlugin:@"GeolocatorPlugin"]];
  [FPPSensorsPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FPPSensorsPlusPlugin"]];
  [Sqlite3FlutterLibsPlugin registerWithRegistrar:[registry registrarForPlugin:@"Sqlite3FlutterLibsPlugin"]];
}

@end
