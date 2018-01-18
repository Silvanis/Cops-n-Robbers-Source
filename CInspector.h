//
//  CInspector.h
//  CopsnRobbersTest
//
//  Created by John Markle on 10/21/12.
//  Copyright 2012 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCopBase.h"

@interface CInspector : CCopBase
{
    
}

+(id) inspectorWithParentNode:(CCNode *)parentNode;
+(id) inspectorWithSaveState:(NSMutableDictionary *)saveData parentNode:(CCNode *)parentNode;
-(void) turnSprite: (enum DIRECTION) direction;
@end
