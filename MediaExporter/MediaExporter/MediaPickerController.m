//
//  MediaPickerController.m
//  MediaExporter
//
//  Created by Jack Wu on 13-06-14.
//  Copyright (c) 2013 Jack Wu. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

#import "MediaPickerController.h"
#import "AppDelegate.h"

@interface MediaPickerController() <MPMediaPickerControllerDelegate>
@end

@implementation MediaPickerController


- (id)init
{
    self = [super initWithMediaTypes:MPMediaTypeAnyAudio];
    
    if(self)
    {
        self.delegate = self;
        self.allowsPickingMultipleItems = NO;
    }
    
    return self;
}

- (void)start
{
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleBlackOpaque animated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.viewController;
    [vc presentViewController:self animated:YES completion:nil];
}


#pragma mark MPMediaPickerControllerDelegate
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)theCollection
{
    // hide the mpmediapickercontroller
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.viewController;
    [vc dismissViewControllerAnimated:YES completion:nil];

    // get metadata for chosen media item
    NSArray *ArrItems=theCollection.items;
    MPMediaItem *selectedItem = [ArrItems objectAtIndex:0];
    MPMediaItemArtwork *selectedItemThumbnail = [selectedItem valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *mediaThumbnail = nil;
    
    // get album art
    if (selectedItemThumbnail != nil)
    {
        mediaThumbnail = [selectedItemThumbnail imageWithSize:CGSizeMake(250.0, 250.0)];
        
        if(mediaThumbnail)
        {
            /*
             
                Upload media thumbnail to any server
             
             */
        }
    }

    /*
        a NSMutableAsset object is created based on the metadata from the nsmediaitem, where the AVAssetExportSession object copies the data to a specified location, allowing the data to be sent
     */
    NSString *songTitle = [selectedItem valueForProperty:MPMediaItemPropertyTitle];
    NSURL *assetURL = [selectedItem valueForProperty: MPMediaItemPropertyAssetURL];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL: assetURL options:nil];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:songAsset presetName:AVAssetExportPresetPassthrough];
    NSArray *tracks = [songAsset tracksWithMediaType:AVMediaTypeAudio];
    AVAssetTrack *track = [tracks objectAtIndex:0];
    CMFormatDescriptionRef desc = (__bridge CMFormatDescriptionRef)([track.formatDescriptions objectAtIndex:0]);
    const AudioStreamBasicDescription *audioDesc = CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)desc);
    FourCharCode formatID = audioDesc->mFormatID;
    NSString *fileType = nil;
    NSString *ex = nil;
     
    // at this time, only mp3 song files are enabled to be sent
    if(formatID == kAudioFormatMPEGLayer3)
    {
        fileType = @"com.apple.quicktime-movie";
        ex = @"mov";
     
        exporter.outputFileType = fileType;
        
        // exports the mp3 file
        NSError *error = nil;
        NSString *mp3DirectoryPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"MP3"];
        [[NSFileManager defaultManager] createDirectoryAtPath:mp3DirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
     
        NSString *exportFile = [mp3DirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", songTitle, ex]];
     
        NSURL *exportURL = [NSURL fileURLWithPath:exportFile];
        exporter.outputURL = exportURL;
     
        exporter.shouldOptimizeForNetworkUse = YES;
        [exporter exportAsynchronouslyWithCompletionHandler:
         ^{
             // get the exported nsdata object of the chosen media item
             NSData *mediaData = [NSData dataWithContentsOfFile:[mp3DirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", songTitle, ex]]];

             // file cleanup after exporting
             if ([[NSFileManager defaultManager] fileExistsAtPath:exportFile])
             {
                 NSError *error = nil;
                 if ([[NSFileManager defaultManager] removeItemAtPath:exportFile error:&error] == NO)
                     NSLog(@"removeItemAtPath %@ error:%@", exportFile, error);
             }

             /*
              
                Upload media thumbnail to any server
              
              */
         }];
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *vc = (UIViewController *) appDelegate.viewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}


@end
