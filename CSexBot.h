//
//  CSexBot.h
//  Cops 'n Robbers
//
//  Created by John Markle on 5/27/13.
//  Copyright 2013 Silver Moonfire LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCharacter.h"
#import "Constants.h"

@interface CSexBot : CCharacter
{
    
}
@property enum SEXBOT_STATE currentState;
- (id) initWithParentNode:(CCNode *)parentNode;
+(id) sexbotWithParentNode:(CCNode *)parentNode;
-(void) turnSprite:(enum DIRECTION)direction;
@end
