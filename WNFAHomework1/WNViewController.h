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

@interface WNViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>{

    AVCaptureSession *captureSession;
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureConnection *videoConnection;
    AVCaptureDeviceInput *deviceInput;
    AVCaptureVideoPreviewLayer *previewLayer;
    
    CFTimeInterval basedTime;

}

@property (weak, nonatomic) IBOutlet UITextView *messageField;
@property (weak, nonatomic) IBOutlet UIView *videoView;

- (IBAction)startAction:(id)sender;

- (void)setCaptureInput;
- (void)setVideoOutput;
- (void)setPreviewLayer;


@end
