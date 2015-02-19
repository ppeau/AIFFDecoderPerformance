//
//  AppDelegate.m
//  IOS_SpectralFlux
//
//
/// ===========================--------------
#pragma mark -
#pragma mark IMPORTS
/// ===========================--------------
#import "AppDelegate.h"
#import "SpectralFluxDetection.h"

/// ===========================--------------
#pragma mark -
#pragma mark INTERFACE
/// ===========================--------------
@interface AppDelegate ()
@end


/// ===========================--------------
#pragma mark -
#pragma mark IMPLEMENTATION
/// ===========================--------------
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    SpectralFluxDetection *spectralFlux = [[SpectralFluxDetection alloc] init];
    [spectralFlux getPCMWithBass];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {}
- (void)applicationDidEnterBackground:(UIApplication *)application {}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationWillTerminate:(UIApplication *)application {}

@end
