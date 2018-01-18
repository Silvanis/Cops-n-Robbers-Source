//
//  StoreViewController.m
//  Cops 'n Robbers
//
//  Created by John Markle on 6/27/13.
//  Copyright (c) 2013 Silver Moonfire LLC. All rights reserved.
//

#import "StoreViewController.h"

@interface StoreViewController ()

@end

@implementation StoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil parent:(NSString *)parent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        parentName = parent;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    productList = [[NSMutableArray alloc] initWithCapacity:5];
    [self requestProductData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [productList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *mainLabel, *secondLabel;
    UITextView *descriptionView;
    UITableViewCell *cell;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        static NSString *CellIdentifier = @"StoreCell";
        
        // Configure the cell...
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            
            mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 130.0, 12.0)];
            mainLabel.tag = 1;
            mainLabel.font = [UIFont fontWithName:@"Chalkboard SE" size:14.0];
            mainLabel.textAlignment = UITextAlignmentLeft;
            mainLabel.textColor = [UIColor blackColor];
            mainLabel.backgroundColor = [UIColor lightGrayColor];
            mainLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin /*| UIViewAutoresizingFlexibleHeight*/;
            [cell.contentView addSubview:mainLabel];
            
            secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(200.0, 00.0, 50.0, 12.0)];
            secondLabel.tag = 2;
            secondLabel.font = [UIFont fontWithName:@"Chalkboard SE" size:14.0];
            secondLabel.textAlignment = UITextAlignmentRight;
            secondLabel.textColor = [UIColor blackColor];
            secondLabel.backgroundColor = [UIColor lightGrayColor];
            secondLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin /*| UIViewAutoresizingFlexibleHeight*/;
            [cell.contentView addSubview:secondLabel];
            
            descriptionView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 12.0, 300, 40)];
            descriptionView.tag = 3;
            descriptionView.font = [UIFont fontWithName:@"Chalkboard SE" size:10.0];
            descriptionView.textAlignment = UITextAlignmentCenter;
            descriptionView.textColor = [UIColor blackColor];
            descriptionView.backgroundColor = [UIColor lightGrayColor];
            descriptionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin /*| UIViewAutoresizingFlexibleHeight*/;
            descriptionView.userInteractionEnabled = NO;
            [cell.contentView addSubview:descriptionView];
            
        }
        else
        {
            mainLabel = (UILabel *)[cell.contentView viewWithTag:1];
            secondLabel = (UILabel *)[cell.contentView viewWithTag:2];
            descriptionView = (UITextView *)[cell.contentView viewWithTag:3];
        }

    }
    else
    {
        static NSString *CellIdentifier = @"StoreCell-iPad";
        
        // Configure the cell...
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            CGRect frame = cell.frame;
            frame.size.width = 748.0f;
            cell.frame = frame;
            mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 24.0)];
            mainLabel.tag = 1;
            mainLabel.font = [UIFont fontWithName:@"Chalkboard SE" size:28.0];
            mainLabel.textAlignment = UITextAlignmentLeft;
            mainLabel.textColor = [UIColor blackColor];
            mainLabel.backgroundColor = [UIColor lightGrayColor];
            mainLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin /*| UIViewAutoresizingFlexibleHeight*/;
            [cell.contentView addSubview:mainLabel];
            
            secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(600.0, 00.0, 75.0, 24.0)];
            secondLabel.tag = 2;
            secondLabel.font = [UIFont fontWithName:@"Chalkboard SE" size:28.0];
            secondLabel.textAlignment = UITextAlignmentRight;
            secondLabel.textColor = [UIColor blackColor];
            secondLabel.backgroundColor = [UIColor lightGrayColor];
            secondLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin /*| UIViewAutoresizingFlexibleHeight*/;
            [cell.contentView addSubview:secondLabel];
            
            descriptionView = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 24.0, 600, 70)];
            descriptionView.tag = 3;
            descriptionView.font = [UIFont fontWithName:@"Chalkboard SE" size:20.0];
            descriptionView.textAlignment = UITextAlignmentCenter;
            descriptionView.textColor = [UIColor blackColor];
            descriptionView.backgroundColor = [UIColor lightGrayColor];
            descriptionView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin /*| UIViewAutoresizingFlexibleHeight*/;
            descriptionView.userInteractionEnabled = NO;
            [cell.contentView addSubview:descriptionView];
            
        }
        else
        {
            mainLabel = (UILabel *)[cell.contentView viewWithTag:1];
            secondLabel = (UILabel *)[cell.contentView viewWithTag:2];
            descriptionView = (UITextView *)[cell.contentView viewWithTag:3];
        }
    }
    
    mainLabel.text = [[productList objectAtIndex:indexPath.row] localizedTitle];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    NSLocale *locale = [[productList objectAtIndex:indexPath.row] priceLocale];
    [formatter setLocale:locale];
    NSDecimalNumber *decimalPrice = [[productList objectAtIndex:indexPath.row] price];
    NSString *str = [formatter stringFromNumber:decimalPrice];
    [formatter release];
    secondLabel.text = str;
    descriptionView.text = [[productList objectAtIndex:indexPath.row] localizedDescription];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKProduct *selectedProduct = [productList objectAtIndex:indexPath.row];
    SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void) requestProductData
{
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:@"CnR5Lives", @"CnR15Lives", @"CnR30Lives",
                                                                                       @"CnR50Lives", @"CnR96Lives", nil]];
    request.delegate = self;
    [request start];
}
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    //NSArray *myProducts = response.products;
    // Populate your UI from the products list.
    // Save a reference to the products list.
    
    NSArray *products = [response.products sortedArrayUsingComparator:^(id a, id b) {
        NSDecimalNumber *first = [(SKProduct*)a price];
        NSDecimalNumber *second = [(SKProduct*)b price];
        return [first compare:second];
    }];
    [productList addObjectsFromArray:products];
    [_tableView reloadData];
}

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
- (IBAction)returnButtonPressed:(id)sender
{
    //if called from Title Screen, we used presentViewControllerAnimated:
    //if called from the Game Over Screen, we use addSubview:
    if ([parentName isEqualToString:@"Title"])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.view removeFromSuperview];
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Lives"]intValue] > 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetLives" object:nil];
    }

}
@end
