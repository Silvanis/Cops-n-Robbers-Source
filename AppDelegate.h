//
//  AppDelegate.h
//  CopsnRobbersTest
//
//  Created by John Markle on 5/24/12.
//  Copyright Silver Moonfire LLC 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreKit/StoreKit.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, SKPaymentTransactionObserver> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) RootViewController	*viewController;
@end
