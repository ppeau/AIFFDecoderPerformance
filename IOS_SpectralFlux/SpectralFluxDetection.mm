//
//  spectralFluxDetection.m
//  IOS_SpectralFlux
//
//
/// ===========================--------------
#pragma mark -
#pragma mark IMPORTS
/// ===========================--------------
#import "SpectralFluxDetection.h"
#import <Accelerate/Accelerate.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Bass.h"
#import "SuperpoweredDecoder.h"
#import "SuperpoweredAudioBuffers.h"
#import "SuperpoweredMixer.h"


/// ===========================--------------
#pragma mark -
#pragma mark VARIABLES
/// ===========================--------------

int nBitsPerFrame = 32; // 32 floating-point
int nChannel = 2; // Number of channel recieved from the stream
double sampleRate = 44100.0f; // Sample rate of audio

QWORD pos = 0;
QWORD currentPercent = 0;
float buf[1000];


NSDate* timeInterval_;


/// ===========================--------------
#pragma mark -
#pragma mark IMPLEMENTATION
/// ===========================--------------
@implementation SpectralFluxDetection

/// ===========================--------------
#pragma mark -
#pragma mark CONSTRUCTOR
/// ===========================--------------
-(id) init {
    
    if(self = [super init])
    {
        NSURL* url = [NSURL fileURLWithPath:[[SpectralFluxDetection getUrlFilePath] path]];
        
        UInt64 fileDataSize;
        [self getAudioFileDataSizeWithUrl:url DataSize:&fileDataSize];
    }
    
    return self;
}


// Get the ressource in char
+ (const char *)getFileOrigin {return [[[NSBundle mainBundle] pathForResource:@"OriginalFile" ofType:@"aiff"] UTF8String];}
+ (const char *)getFileExported {return [[[NSBundle mainBundle] pathForResource:@"ExportedFile" ofType:@"aif"] UTF8String];}
+ (NSURL*) getUrlFilePath {
    return [NSURL fileURLWithPath:[NSString stringWithUTF8String:[SpectralFluxDetection getFileExported]]];
}


/// ===========================--------------
#pragma mark -
#pragma mark PRIVATES FUNCTIONS
/// ===========================--------------
- (void) getPCMWithSuperPowered {

    printf("--------------------------------------------\n");
    printf("Started getPCMWithSuperPowered\n");
    printf("--------------------------------------------\n");

    SuperpoweredDecoder *decoder = new SuperpoweredDecoder(false);
    const char *openError = decoder->open([[[SpectralFluxDetection getUrlFilePath] path] UTF8String], false, 0, 0);
    if (openError) {
        delete decoder;
        return;
    };
    
    int16_t progress_;
    int16_t progressEx_ = 0;
    
    short int *intBuffer = (short int *)malloc(decoder->samplesPerFrame * 2 * sizeof(short int) + 16384);
    float *floatBuffer = (float *)malloc(decoder->samplesPerFrame * 2 * sizeof(float) + 16384);
    
    timeInterval_ = [NSDate date];
    
    while (true)
    {
        unsigned int samplesDecoded = decoder->samplesPerFrame;
        if (decoder->decode(intBuffer, &samplesDecoded) != SUPERPOWEREDDECODER_OK) break;
        
        SuperpoweredStereoMixer::shortIntToFloat(intBuffer, floatBuffer, samplesDecoded);

        progress_ = (int)(((float)decoder->samplePosition/(float)decoder->durationSamples)*100);
        
        if(progress_ > progressEx_) { // Send progress to main thread
            printf("Progress : %hd\n", progress_);
            progressEx_ = progress_;
        }
    }
    
    delete decoder;
    free(intBuffer);
    free(floatBuffer);
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:timeInterval_];
    printf("--------------------------------------------\n");
    printf("Finished getPCMWithBass in : %f for %f min(s)\n", interval, interval);
    printf("--------------------------------------------\n");
}

- (void) getPCMWithBass {

    printf("--------------------------------------------\n");
    printf("Started getPCMWithBass\n");
    printf("--------------------------------------------\n");
    
    BASS_SetConfig(BASS_CONFIG_IOS_MIXAUDIO, 2);
    BASS_Init(-1, 44100, 0, 0, NULL);
    
    HSTREAM decoder = BASS_StreamCreateFile(FALSE, [[[SpectralFluxDetection getUrlFilePath] path] UTF8String], 0, 0, BASS_SAMPLE_FLOAT|BASS_STREAM_PRESCAN|BASS_STREAM_DECODE);
    BASS_CHANNELINFO bassInformation;
    BASS_ChannelGetInfo(decoder, &bassInformation);
    
    timeInterval_ = [NSDate date];
    pos = 0;
    currentPercent = 0;
    
    uint64_t length = BASS_ChannelGetLength(decoder, BASS_POS_BYTE);
    
    while (BASS_ChannelIsActive(decoder))
    {
        size_t c = BASS_ChannelGetData(decoder, buf, sizeof(buf)|BASS_DATA_FLOAT);
        
        if(c==(DWORD)-1) break;
        pos += c;
        
        QWORD percent = (pos * 100) / length;
        
        if(currentPercent != percent)
        {
            currentPercent = percent;
            printf("Progress : %llu\n", percent);
        }
    }
    
    BASS_StreamFree(decoder);
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:timeInterval_];
    printf("--------------------------------------------\n");
    printf("Finished getPCMWithBass in : %f for %f min(s)\n", interval, interval);
    printf("--------------------------------------------\n");
    // ================------------------

}

- (void) getPCMWithCoreAudio {
    
    printf("--------------------------------------------\n");
    printf("Started getPCMWithCoreAudio\n");
    printf("--------------------------------------------\n");
    
    timeInterval_ = [NSDate date];
    
    NSURL *outputURL = [NSURL fileURLWithPath:[[SpectralFluxDetection getUrlFilePath] path]];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:outputURL options:nil];
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
    AVAssetTrack *songTrack = [asset.tracks objectAtIndex:0];
    
    NSDictionary *outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                                        [NSNumber numberWithInt:sampleRate],AVSampleRateKey,
                                        [NSNumber numberWithInt:nChannel],AVNumberOfChannelsKey,
                                        [NSNumber numberWithInt:nBitsPerFrame],AVLinearPCMBitDepthKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                        [NSNumber numberWithBool:YES],AVLinearPCMIsFloatKey,
                                        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
                                        nil];
    
    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];
    output = nil;
    [reader startReading];
    

    int percentFrameCount = -1;
    
    while (reader.status == AVAssetReaderStatusReading)
    {
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        
        if (sampleBufferRef)
        {
            CMTime progressTime = CMSampleBufferGetPresentationTimeStamp(sampleBufferRef);
            CMTime sampleDuration = CMSampleBufferGetDuration(sampleBufferRef);
            
            if (CMTIME_IS_NUMERIC(sampleDuration)) progressTime= CMTimeAdd(progressTime, sampleDuration);
            __block int percent = (CMTimeGetSeconds(progressTime) / CMTimeGetSeconds(asset.duration)*100);
            
            if(percentFrameCount < percent)
            {
                printf("Progress : %i\n", percent);
                percentFrameCount++;
            }

            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        }
    }
    
    if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown){
        printf("Something went wrong...");
        return;
    }
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:timeInterval_];
    
    printf("--------------------------------------------\n");
    printf("Finished getPCMWithCoreAudio in : %f for %f min(s)\n", interval, CMTimeGetSeconds(asset.duration)/60);
    printf("--------------------------------------------\n");
    
    return;
}


/// ===========================--------------
#pragma mark -
#pragma mark + FUNCTIONS
/// ===========================--------------
/** get the size of the file with core audio */
- (OSStatus) getAudioFileDataSizeWithUrl:(NSURL*)url DataSize:(UInt64*)dataSize {
    
    OSStatus errcode = noErr;
    UInt32 propertySize;
    AudioFileID fileId = 0;
    
    errcode = AudioFileOpenURL((__bridge CFURLRef) url, kAudioFileReadPermission, 0, &fileId);
    if (errcode)
    {
        NSLog(@"Cannot open file for reading...");
        AudioFileClose(fileId);
        return errcode;
    }
    
    propertySize = sizeof(*dataSize);
    errcode = AudioFileGetProperty(fileId, kAudioFilePropertyAudioDataByteCount, &propertySize, &*dataSize);
    
    if (errcode)
    {
        NSLog(@"Cannot get the file data size ...");
        AudioFileClose(fileId);
        return errcode;
    }
    
    AudioFileClose(fileId);
    return errcode;
}

@end
