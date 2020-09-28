//
//  ListCardsViewController.m
//  PaymentSDKObjC
//
//  Created by Gustavo Sotelo on 27/11/17.
//  Copyright © 2017 Payment. All rights reserved.
//

#import "ListCardsViewController.h"
#import <PaymentSDK/PaymentSDK-Swift.h>
#import "MyBackendLib.h"
#import "UserModel.h"

@interface ListCardsViewController ()

@end

@implementation ListCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cardList = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) refreshTable
{
    [self.cardList removeAllObjects];
    
    [MyBackendLib listCardWithId:USERMODEL_UID callback:^(NSMutableArray *cardList) {
        
        self.cardList = cardList;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cardCell"];
    
    PaymentCard *card = (PaymentCard*) self.cardList[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"****%@", card.termination];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", card.expiryMonth, card.expiryYear];
    cell.imageView.image = [card getCardTypeAsset];
    
    return cell;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cardList count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaymentCard *card = [self.cardList objectAtIndex:indexPath.row];
    [self.cardSelectedDelegate cardSelected:card];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaymentCard *card = [self.cardList objectAtIndex:indexPath.row];
    
    UITableViewRowAction *tableViewRow = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"DELETE" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [MyBackendLib deleteCardWithId:USERMODEL_UID cardToken:card.token callback:^(BOOL *deleted) {
            if (deleted)
                [self refreshTable];
        }];
        
    }];
    tableViewRow.backgroundColor = [UIColor redColor];
    NSArray *actions = @[tableViewRow];
    return actions;
}
- (IBAction)addCard:(id)sender {
    
    PaymentAddNativeViewController *PaymentNative  = [[PaymentAddNativeViewController alloc] initWithIsWidget:YES isModal:NO];
    
    PaymentNative.addDelegate = self;
    
    [self.navigationController pushViewController:PaymentNative animated:TRUE];
    
    [self.navigationController pushPaymentViewControllerWithDelegate:self uid:@"myuid" email:@"mymail@mail.com"];
    
    
    
    
    
    
    
}
- (void)cardAdded:(PaymentSDKError *)error :(PaymentCard *)cardAdded
{
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
