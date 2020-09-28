//
//  StoreViewController.m
//  PaymentSDKObjC
//
//  Created by Gustavo Sotelo on 27/11/17.
//  Copyright © 2017 Payment. All rights reserved.
//

#import "StoreViewController.h"
#import "MyBackendLib.h"
#import "UserModel.h"

@interface StoreViewController ()
@property (strong, nonatomic) PaymentDebitParameters *PaymentRequestParameters;
@property (strong, nonatomic) PaymentCard *selectedCard;
@property (strong, nonatomic) NSArray *productTitles;
@property (strong, nonatomic) NSArray *productPrices;
@end

@implementation StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.productTitles = @[@"Pozole Blanco", @"Latte"];
    self.productPrices = @[@80.0,@50.0];
    self.tableV.tableFooterView = [[UITableView alloc] init];
    [self.activityIndicator setHidesWhenStopped:YES];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)placeOrder:(id)sender {
 
    if (self.selectedCard != nil)
    {
        [self.activityIndicator startAnimating];
        double total = 0.0;
        for(int i = 0; i < [self.productPrices count]; i++)
        {
            total = [self.productPrices[i]  doubleValue] + total;
        }
        NSString *uuid = [[NSUUID UUID] UUIDString];
        NSString *sessionId = [PaymentSDKClient getSecureSessionId];
        
        [MyBackendLib debitCardWithId:USERMODEL_UID cardToken:self.selectedCard.token sessionId:sessionId devReference:uuid amount:total description:@"Buy" callback:^(PaymentSDKError *error, PaymentTransaction *transaction) {
            [self.activityIndicator stopAnimating];
            if (transaction != nil)
            {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Response" message:[NSString stringWithFormat:@" Transaction %@ , status:%@, authcode:%@, carrier_code:%@", transaction.transactionId, transaction.status, transaction.authorizationCode, transaction.carrierCode] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:FALSE];
                }];
                [alertC addAction:alertAction];
                [self presentViewController:alertC animated:NO completion:nil];
            });
            }
        }];
        
        
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [self performSegueWithIdentifier:@"listViewController" sender:self];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [self.productPrices count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"productCell"];
        cell.textLabel.text = [self.productTitles objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [NSString localizedStringWithFormat:@"$%@",[self.productPrices objectAtIndex:indexPath.row]];
        return cell;
    }
    else if (indexPath.section == 1)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardCell"];
        
        if (self.selectedCard != nil)
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"***%@" , self.selectedCard.termination];
            
            cell.imageView.image = [self.selectedCard getCardTypeAsset];
        }
        else
        {
            cell.textLabel.text = @"Forma de Pago";
            cell.detailTextLabel.text = @"Selecciona";
        }
        
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"totalCell"];
        
        double total = 0.0;
        for(int i = 0; i < [self.productPrices count]; i++)
        {
            total = [self.productPrices[i]  doubleValue] + total;
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.02f", total];
        return cell;
    }
    

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%@",segue.identifier);
    if ( [segue.identifier isEqualToString:@"listViewController"])
    {
        ListCardsViewController *lVC = (ListCardsViewController*) segue.destinationViewController;
        lVC.cardSelectedDelegate = self;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)cardSelected:(PaymentCard *)card {
    
    self.selectedCard = card;
    [self.tableV reloadData];
}


@end

