//
//  CRookie.h
//  CopsnRobbersTest
//
//  Created by John Markle on 9/12/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCopBase.h"

@interface CRookie : CCopBase
{

}
+(id) rookieWithParentNode:(CCNode *)parentNode;
+(id) rookieWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode;
-(void) turnSprite: (enum DIRECTION) direction;
@end
