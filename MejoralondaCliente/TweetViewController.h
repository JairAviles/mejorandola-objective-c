//
//  TweetViewController.h
//  MejoralondaCliente
//
//  Created by Jair Avilés on 9/10/17.
//  Copyright © 2017 Jair Avilés. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Accounts/Accounts.h"
#import "Social/Social.h"

@interface TweetViewController : UITableViewController<NSURLConnectionDelegate>

@property (nonatomic, strong) NSString *hashTag;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *requestData;
@property (nonatomic, strong) NSURL *apiURL;

-(BOOL) userHasAccessToTwitter;

@end
