//
//  WNPreviewView.h
//  WNFAHomework1
//
//  Created by apple on 2014/3/13.
//  Copyright (c) 2014年 chang-ning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraFocusSquare : UIView

@end


@interface WNPreviewView : UIView{

    CameraFocusSquare *camFocus;
}

- (void) focus:(CGPoint) aPoint;

@end
