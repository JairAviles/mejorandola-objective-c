//
//  ViewController.h
//  MejoralondaCliente
//
//  Created by Jair Avilés on 9/10/17.
//  Copyright © 2017 Jair Avilés. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *someCollectionView;
@property (strong, nonatomic) NSMutableArray *menuItems;

@end

