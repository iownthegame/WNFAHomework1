//
//  WNViewController.h
//  WNFAHomework1
//
//  Created by apple on 2014/3/10.
//  Copyright (c) 2014年 chang-ning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "WNPreviewView.h"

int Threshold = 200;
int preambleThrshold = 100000;
double rgbDiffRatioThreshold = 0.7;

@interface WNViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>{

    AVCaptureSession *captureSession;
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureConnection *videoConnection;
    AVCaptureDeviceInput *deviceInput;
    AVCaptureVideoPreviewLayer *previewLayer;
    
    CFTimeInterval basedTime;

    CGImageRef cgImage;
    
    BOOL indexR;
    BOOL indexG;
    BOOL indexB;
    
    int hist[4];
    
    int recvBitCounter;
    unsigned char recvChar;
    
    NSMutableString *mesg;
    
    BOOL isRecvMesg;
}

@property (weak, nonatomic) IBOutlet UITextView *messageField;
@property (weak, nonatomic) IBOutlet WNPreviewView *videoView;

- (IBAction)startAction:(id)sender;

- (void)setCaptureInput;
- (void)setVideoOutput;
- (void)setPreviewLayer;


@end

