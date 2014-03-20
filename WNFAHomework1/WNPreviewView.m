//
//  WNPreviewView.m
//  WNFAHomework1
//
//  Created by apple on 2014/3/13.
//  Copyright (c) 2014年 chang-ning. All rights reserved.
//

#import "WNPreviewView.h"

@implementation CameraFocusSquare

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self){
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBorderWidth:2.0];
        [self.layer setCornerRadius:4.0];
        [self.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        CABasicAnimation* selectionAnimation = [CABasicAnimation
                                                animationWithKeyPath:@"borderColor"];
        selectionAnimation.toValue = (id)[UIColor orangeColor].CGColor;
        selectionAnimation.repeatCount = 8;
        [self.layer addAnimation:selectionAnimation
                          forKey:@"selectionAnimation"];
    }
    return self;
}

@end


@implementation WNPreviewView

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//
//
//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint touchPoint = [touch locationInView:touch.view];
//    
//    [self focus:touchPoint];
//    
//    if(camFocus){
//        [camFocus removeFromSuperview];
//    }
//    
//    if([[touch view] isKindOfClass:[WNPreviewView class]]){
//    
//        camFocus = [[CameraFocusSquare alloc]initWithFrame:CGRectMake(touchPoint.x-40,
//                                                                      touchPoint.y-40,
//                                                                      80,
//                                                                      80)];
//        [camFocus setBackgroundColor:[UIColor clearColor]];
//        [self addSubview:camFocus];
//        [camFocus setNeedsDisplay];
//        
//        [UIView animateWithDuration:1.5 animations:^{
//            [camFocus setAlpha:0.0];
//        
//        }];
//        //[UIView beginAnimations:nil context:NULL];
//        //[UIView setAnimationDuration:1.5];
//        //[camFocus setAlpha:0.0];
//        //[UIView commitAnimations];
//    }
//    NSLog(@"touch");
//    
//}

- (void) focus:(CGPoint) aPoint{


    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [self getBackCamera];
        if([device isFocusPointOfInterestSupported] &&
           [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            double screenWidth = screenRect.size.width;
            double screenHeight = screenRect.size.height;
            double focus_x = aPoint.x/screenWidth;
            double focus_y = aPoint.y/screenHeight;
            if([device lockForConfiguration:nil]) {
                [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
                //[device setFocusMode:AVCaptureFocusModeAutoFocus];
                [device setFocusMode:AVCaptureFocusModeLocked];
                if ([device isExposureModeSupported:AVCaptureExposureModeLocked]){
                    //[device setExposureMode:AVCaptureExposureModeAutoExpose];
                     [device setExposureMode:AVCaptureExposureModeLocked];
                }
                [device unlockForConfiguration];
            }
        }
        
        
    }
    
}

- (AVCaptureDevice *)getBackCamera{

    NSArray *devices = [AVCaptureDevice devices];
    
    for(AVCaptureDevice *device in devices){
        
        if([device position] == AVCaptureDevicePositionBack){
            return device;
        }
    }
    return nil;
}


@end
