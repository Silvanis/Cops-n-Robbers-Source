//
//  CCAnimationHelper.m
//  CopsnRobbersTest
//
//  Created by John Markle on 11/3/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import "CCAnimationHelper.h"


@implementation CCAnimation (Helper)
+(CCAnimation *)animationWithFile:(NSString *)name
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:2];
    NSString *frame1 = [NSString stringWithFormat:@"%@.png", name];
    NSString *frame2 = [NSString stringWithFormat:@"%@-2.png", name];
    CCTexture2D *texture1 = [[CCTextureCache sharedTextureCache] addImage:frame1];
    CGSize texSize1 = texture1.contentSize;
    CGRect texRect1 = CGRectMake(0, 0, texSize1.width, texSize1.height);
    CCSpriteFrame *spriteFrame1 = [CCSpriteFrame frameWithTexture:texture1 rect:texRect1];
    
    [frames addObject:spriteFrame1];
    
    CCTexture2D *texture2 = [[CCTextureCache sharedTextureCache] addImage:frame2];
    CGSize texSize2 = texture2.contentSize;
    CGRect texRect2 = CGRectMake(0, 0, texSize2.width, texSize2.height);
    CCSpriteFrame *spriteFrame2 = [CCSpriteFrame frameWithTexture:texture2 rect:texRect2];
    
    [frames addObject:spriteFrame2];
    
    return [CCAnimation animationWithFrames:frames delay:.3];
}

+(CCAnimation *)animationWithFile4Frames:(NSString *)name
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:2];
    NSString *frame1 = [NSString stringWithFormat:@"%@.png", name];
    NSString *frame2 = [NSString stringWithFormat:@"%@-2.png", name];
    NSString *frame3 = [NSString stringWithFormat:@"%@-3.png", name];
    NSString *frame4 = [NSString stringWithFormat:@"%@-4.png", name];
    CCTexture2D *texture1 = [[CCTextureCache sharedTextureCache] addImage:frame1];
    CGSize texSize1 = texture1.contentSize;
    CGRect texRect1 = CGRectMake(0, 0, texSize1.width, texSize1.height);
    CCSpriteFrame *spriteFrame1 = [CCSpriteFrame frameWithTexture:texture1 rect:texRect1];
    
    [frames addObject:spriteFrame1];
    
    CCTexture2D *texture2 = [[CCTextureCache sharedTextureCache] addImage:frame2];
    CGSize texSize2 = texture2.contentSize;
    CGRect texRect2 = CGRectMake(0, 0, texSize2.width, texSize2.height);
    CCSpriteFrame *spriteFrame2 = [CCSpriteFrame frameWithTexture:texture2 rect:texRect2];
    
    [frames addObject:spriteFrame2];
    
    CCTexture2D *texture3 = [[CCTextureCache sharedTextureCache] addImage:frame3];
    CGSize texSize3 = texture3.contentSize;
    CGRect texRect3 = CGRectMake(0, 0, texSize3.width, texSize3.height);
    CCSpriteFrame *spriteFrame3 = [CCSpriteFrame frameWithTexture:texture3 rect:texRect3];
    
    [frames addObject:spriteFrame3];
    
    CCTexture2D *texture4 = [[CCTextureCache sharedTextureCache] addImage:frame4];
    CGSize texSize4 = texture4.contentSize;
    CGRect texRect4 = CGRectMake(0, 0, texSize4.width, texSize4.height);
    CCSpriteFrame *spriteFrame4 = [CCSpriteFrame frameWithTexture:texture4 rect:texRect4];
    
    [frames addObject:spriteFrame4];
    
    return [CCAnimation animationWithFrames:frames delay:.3];
}
@end
