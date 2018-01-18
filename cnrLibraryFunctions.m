//
//  cnrLibraryFunctions.m
//  CopsnRobbersTest
//
//  Created by John Markle on 9/12/12.
//  Copyright (c) 2012 Silver Moonfire LLC. All rights reserved.
//

#import "cnrLibraryFunctions.h"
#import "cocos2d.h"
int getTileSize()
{
    int tileSize = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) 
    {
        tileSize = 16;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        tileSize = 32;
    }
 
    return tileSize;
}