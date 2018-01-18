//
//  StoreViewController.h
//  Cops 'n Robbers
//
//  Created by John Markle on 6/27/13.
//  Copyright (c) 2013 Silver Moonfire LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoreKit/StoreKit.h"

@interface StoreViewController : UIViewController <SKProductsRequestDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *productList;
    NSString *parentName;

}
@property (retain, nonatomic) IBOutlet UITableView *tableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(NSString *)parent;
- (IBAction)returnButtonPressed:(id)sender;
@end
