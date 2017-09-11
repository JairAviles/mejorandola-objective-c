//
//  TweetViewController.m
//  MejoralondaCliente
//
//  Created by Jair Avilés on 9/10/17.
//  Copyright © 2017 Jair Avilés. All rights reserved.
//

#import "TweetViewController.h"
#import "Accounts/Accounts.h"
#import "Social/Social.h"

@interface TweetViewController ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.hashTag);
    
    self.apiURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/"];
    self.accountStore = [[ACAccountStore alloc] init];
    
    if(![self userHasAccessToTwitter]) {
        NSLog(@"No twitter connection detected...");
    } else {
        
        NSLog(@"Twitter connection detected...");
        ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:twitterAccountType options:NULL completion:^(BOOL granted, NSError *error) {
            
            NSDictionary *params = @{@"q": self.hashTag};
            
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[self.apiURL URLByAppendingPathComponent:@"search/tweets.json"] parameters:params];
            
            NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:twitterAccountType];
            request.account = twitterAccounts.lastObject;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.connection = [[NSURLConnection alloc] initWithRequest:[request preparedURLRequest] delegate:self];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            });
            
        }];
        
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) userHasAccessToTwitter {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [self.results count];
}

/** NSURLConnectionDelegate related methods **/

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response{
    self.requestData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data{
    [[self requestData] appendData:data];
}

- (void)connectionDidFinishLoading:(nonnull NSURLConnection *)connection {
    
    if (self.requestData) {
        NSError *jsonError;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:self.requestData options:NSJSONReadingAllowFragments error:&jsonError];
        
        self.results = dictionary[@"statuses"];
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell" forIndexPath:indexPath];
    
    NSDictionary *tweet = (self.results)[indexPath.row];
    
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    label.text = [NSString stringWithFormat:@"@%@", tweet[@"user"][@"screen_name"]];
    
    UILabel *tweetLabel = (UILabel*) [cell viewWithTag:2];
    tweetLabel.text = tweet[@"text"];
    
    // We may get a lot of images at once, so it's best to leverage GCD to asynchronously pull in profile images.
    // La siguiente es una técnica, es su tarea tratar de mejorarla
    // La idea es que las imagenes se queden en cache y no tener
    // Que estar cambiandolas cada vez que se hace scroll
    // Hacemos el request y le damos la prioridad 0
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSURL *profileImageURL = [NSURL URLWithString:(tweet[@"user"])[@"profile_image_url"]];
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profileImageURL]];
        // Luego en otro dispatch vámos a setear la imagen
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:3];
            imageView.image = image;
            
        });
    });
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
