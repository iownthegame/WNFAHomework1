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

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

@implementation WNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setCaptureInput];
    [self setVideoOutput];
    [self setPreviewLayer];
    
    indexR = NO;
    indexG = NO;
    indexB = NO;
    isRecvMesg = NO;
    
    hist[RED] = 0;
    hist[GREEN] = 0;
    hist[BLUE] = 0;
    
    recvBitCounter = 0;
    recvChar = 0;
    mesg = [[NSMutableString alloc]init];
    [mesg appendString:@">>> "];
    
    UIView *boundView = [[UIView alloc]init];
    boundView.backgroundColor = [UIColor clearColor];
    boundView.layer.borderWidth = 2.0;
    boundView.layer.cornerRadius = 8.0;
    boundView.frame = CGRectMake(self.view.bounds.size.height/4+self.view.frame.size.width/4,
                                 self.view.frame.size.width/4,
                                 self.view.frame.size.width/2,
                                 self.view.frame.size.width/2);
    [boundView.layer setBorderColor:[UIColor orangeColor].CGColor];
    [self.view addSubview:boundView];
    
    
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
    previewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    
    previewLayer.frame = self.videoView.bounds;

    [self.videoView.layer addSublayer:previewLayer];
    
    
}

- (IBAction)startAction:(id)sender {
    
    indexR = NO;
    indexG = NO;
    indexB = NO;
    UIButton *startBtn = (UIButton *)sender;
    
    if(isRecvMesg){
        isRecvMesg = NO;
        [startBtn setImage:[UIImage imageNamed:@"play-button.png"] forState:UIControlStateNormal];
    }
    else{
        isRecvMesg = YES;
        [startBtn setImage:[UIImage imageNamed:@"pause-button.png"] forState:UIControlStateNormal];
        recvChar = 0;
        recvBitCounter = 0;
        NSLog(@"start");
    }
    
}

# pragma mark- AVCaptureVideoSampleBufferOutputDelegate

- (void) captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{


}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

    //NSLog(@"capture Video");
    
    if(isRecvMesg){
        
        // 1. Get Image Buffer
        CVImageBufferRef imageBuffer= CMSampleBufferGetImageBuffer(sampleBuffer);
        // Lock Image to avoid sync problem
        CVPixelBufferLockBaseAddress(imageBuffer,0);
        
        // 2. Get imageBuffer information
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        
        // 3. Create color space
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        // 4. Draw sampleBuffer on context
        CGContextRef context = CGBitmapContextCreate(baseAddress,
                                                     width,
                                                     height,
                                                     8,
                                                     bytesPerRow,
                                                     colorSpace,
                                                     kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        
        if(!context){
            CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
            return;
        }
        CGColorSpaceRelease(colorSpace);
        
        // 5. Create CGImage from context
        cgImage = CGBitmapContextCreateImage(context);
        [self decodeImage:cgImage];
        CGImageRelease(cgImage);
    }
    

}

- (void)decodeImage:(CGImageRef)cgimage{

    CGSize size;
    // Get cgimage width and height
    size.width = CGImageGetWidth(cgimage);
    size.height = CGImageGetHeight(cgimage);
    
    // Alloc pixels value's Array(using to image processing)
    uint32_t *pixels = (uint32_t *)malloc(size.width*size.height*sizeof(uint32_t));
    
    // Create colorSpace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create bitmap context
    // here we can get pixels value by this function, notice "pixels" parameter
    CGContextRef context = CGBitmapContextCreate(pixels,
                                                 size.width,
                                                 size.height,
                                                 8,
                                                 size.width*sizeof(uint32_t),
                                                 colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    // Draw image to context
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), cgimage);
    
    
    int y = 0;
    int x = 0;
    
    //NSLog(@"photo size = %f, %f",size.width,size.height);
    
    for(y=floor(size.height/4);y<floor(size.height/4*3);y++){
        for(x=floor(size.width/2-size.height/8-150);x<floor(size.width/2 + size.height/8-150);x++){
            uint8_t *rgbaPixel = (uint8_t *)&pixels[y * (int)size.width + x];
            //uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            //rgbaPixel[RED] = gray;
            //rgbaPixel[GREEN] = gray;
            //rgbaPixel[BLUE] = gray;
            if(rgbaPixel[RED]>Threshold){
                hist[RED] ++;
            }
            if(rgbaPixel[GREEN]>Threshold){
                hist[GREEN] ++;
            }
            
            if(rgbaPixel[BLUE]>Threshold){
                hist[BLUE] ++;
            }
            
        }
    }
    
    double histSum = hist[RED] + hist[GREEN] + hist[BLUE];
    double redRatio, greenRatio, blueRatio;
    redRatio = hist[RED]/histSum;
    greenRatio = hist[GREEN]/histSum;
    blueRatio = hist[BLUE]/histSum;
    
    if((hist[RED]> preambleThrshold ||
        hist[GREEN] > preambleThrshold ||
        hist[BLUE]>preambleThrshold) && (!indexR && !indexG && !indexB)){
        
        if(hist[RED] > hist[GREEN] && hist[RED] > hist[BLUE] && redRatio>rgbDiffRatioThreshold){
            indexR = YES;
            recvChar = recvChar | (1<<recvBitCounter);
            recvBitCounter ++;
            NSLog(@"current recv = %d, bitConter = %d",recvChar,recvBitCounter);
            
        }
        else if(hist[GREEN] > hist[RED] && hist[GREEN] > hist[BLUE] && greenRatio > rgbDiffRatioThreshold){
            indexG = YES;
            recvBitCounter ++;
             NSLog(@"current recv = %d, bitCounter = %d",recvChar,recvBitCounter);
        }
        else if(hist[BLUE] > hist[RED] && hist[BLUE] > hist[GREEN] && blueRatio > rgbDiffRatioThreshold){
            indexB = YES;
        }
        
    }
    else if((hist[RED]> preambleThrshold ||
             hist[GREEN] > preambleThrshold ||
             hist[BLUE]>preambleThrshold)){
        
        //NSLog(@"continue receive current color current recv = %d",recvChar);
    }
    else{
        indexR = NO;
        indexG = NO;
        indexB = NO;
    }
    //NSLog(@"histR = %d, histG = %d, histB = %d",hist[RED],hist[GREEN],hist[BLUE]);
    //NSLog(@"indexR = %d, indexG = %d, indexB = %d",indexR,indexG,indexB);
    //NSLog(@"rationR = %lf, ratioG = %lf, ratioB = %lf",redRatio,greenRatio,blueRatio);
    
    if(recvBitCounter == 8){
        
        //NSLog(@" recv char = %d",recvChar);
        [mesg appendFormat:@"%c",recvChar];
        NSLog(@"mesg = %@",mesg);
        if(recvChar == 10){
            dispatch_async(dispatch_get_main_queue(), ^{
                [mesg appendString:@">>> "];
                self.messageField.text = mesg;
            });
            isRecvMesg = NO;
        }
        recvBitCounter = 0;
        recvChar = 0;
    }
    
    hist[RED] = 0;
    hist[GREEN] = 0;
    hist[BLUE] = 0;
    // Release memory
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
}
@end


