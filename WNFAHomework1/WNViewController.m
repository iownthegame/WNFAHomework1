//
//  WNViewController.m
//  WNFAHomework1
//
//  Created by apple on 2014/3/10.
//  Copyright (c) 2014年 chang-ning. All rights reserved.
//

#import "WNViewController.h"

@interface WNViewController ()

@end

@implementation WNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setCaptureInput];
    [self setVideoOutput];
    [self setPreviewLayer];
    
    [captureSession startRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCaptureInput{


    captureSession = [[AVCaptureSession alloc]init];
    NSArray *devices = [AVCaptureDevice devices];
    
    NSError *error;
    
    for(AVCaptureDevice *device in devices){
    
        if([device position] == AVCaptureDevicePositionBack){
            deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if(error){
                NSLog(@"error message = %@",[error localizedDescription]);
            }
            else{
                
                [captureSession addInput:deviceInput];
            }
            break;
        }
    }
    
    
}

- (void)setVideoOutput{
    
    videoDataOutput = [[AVCaptureVideoDataOutput alloc]init];
    [videoDataOutput setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:
                                       //[NSNumber numberWithFloat:640.0], (id)kCVPixelBufferWidthKey,
                                       //[NSNumber numberWithFloat:480.0], (id)kCVPixelBufferHeightKey,
                                       [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],(id)kCVPixelBufferPixelFormatTypeKey,
                                       nil]];
    
    videoConnection = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    dispatch_queue_t queue = dispatch_queue_create("videoGetQueue", NULL);
    [videoDataOutput setSampleBufferDelegate:self queue:queue];
    [captureSession addOutput:videoDataOutput];

}

- (void)setPreviewLayer{
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSession];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    previewLayer.frame = self.videoView.bounds;

    [self.videoView.layer addSublayer:previewLayer];

}

- (IBAction)startAction:(id)sender {
    
    
}

# pragma mark- AVCaptureVideoSampleBufferOutputDelegate

- (void) captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{


}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

    //NSLog(@"capture Video");

}
@end


