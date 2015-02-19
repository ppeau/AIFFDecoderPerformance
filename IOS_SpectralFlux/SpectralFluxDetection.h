//
//  spectralFluxDetection.h
//  IOS_SpectralFlux
//
//
/// ===========================--------------
#pragma mark -
#pragma mark IMPORTS
/// ===========================--------------
#import <Foundation/Foundation.h>


/// ===========================--------------
#pragma mark -
#pragma mark INTERFACE
/// ===========================--------------
@interface SpectralFluxDetection : NSObject


/// ===========================--------------
#pragma mark -
#pragma mark CONSTRUCTOR
/// ===========================--------------
-(id) init;


/// ===========================--------------
#pragma mark -
#pragma mark PUBLICS FUNCTIONS
/// ===========================--------------
- (void) getPCMWithCoreAudio;
- (void) getPCMWithBass;
- (void) getPCMWithSuperPowered;

@end
