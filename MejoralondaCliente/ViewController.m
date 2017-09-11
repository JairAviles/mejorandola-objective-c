//
//  ViewController.m
//  MejoralondaCliente
//
//  Created by Jair Avilés on 9/10/17.
//  Copyright © 2017 Jair Avilés. All rights reserved.
//

#import "ViewController.h"
#import "TweetViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionConfiguration *sessionConfiguration;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.menuItems = [[NSMutableArray alloc] init];
    
    NSURL *url = [NSURL URLWithString:@"http://mejorandoios.herokuapp.com/api/courses/all"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest: request completionHandler:^(NSData * data, NSURLResponse * response, NSError * _Nullable error) {
        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *)response;
        if(urlResponse.statusCode == 200) {
            NSLog(@"It came to 200 status code");
            [self handleResults:data];
        }
    }];
    
    [task resume];
    
}

-(void)handleResults:(NSData *)data {
    NSError *jsonError;
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
    
    if(response) {
        NSLog(@"%@", response[@"data"]);
        
        for (NSDictionary *dataDictionary in response[@"data"]) {
            [self.menuItems addObject:dataDictionary];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.someCollectionView reloadData];
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.menuItems count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:(@"Cell") forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:10];
    
    if([self.menuItems count] > 0) {
        NSDictionary *cellDictionary = [self.menuItems objectAtIndex:indexPath.row];
        NSString *imageUrlString = [cellDictionary objectForKey:@"image_url"];
        NSURL *imageUrl = [NSURL URLWithString:imageUrlString];
        NSURLRequest * imageUrlRequest = [NSURLRequest requestWithURL:imageUrl];
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:imageUrlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse *) response;
            
            if (urlResponse.statusCode == 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = [UIImage imageWithData:data];
                });
            } else {
                NSLog(@"Not able to retrieve the information");
            }
            
        }];
        [task resume];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *menuItemDictionary = [self.menuItems objectAtIndex:indexPath.row];
    TweetViewController *tweetViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"tweetView"];
    tweetViewController.hashTag = [menuItemDictionary objectForKey:@"hashtag"];
    [self.navigationController pushViewController:tweetViewController animated:YES];
    
    
}


@end
