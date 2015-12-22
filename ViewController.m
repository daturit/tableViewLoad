//
//  ViewController.m
//  tableViewLoadBackground
//
//  Created by ivs on 12/21/15.
//  Copyright © 2015 ivs. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking/AFNetworking.h"
#import "NSDictionary+itunes.h"
#import "NSDictionary+itunes_package.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property(strong) NSDictionary *data;
@property(strong, nonatomic) NSNumber *count;
@property (strong, nonatomic) NSArray *results;
@property (strong, nonatomic) NSMutableDictionary *cachedImages;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // data json itunes https://itunes.apple.com/search?term=flappy%20bird
    
    self.cachedImages = [[NSMutableDictionary alloc] init];
    self.results = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableview.delegate = self;
    
    
    NSString *string = @"https://itunes.apple.com/search?term=flappy%20bird";
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        // 3
        self.data = (NSDictionary *) responseObject;
        self.count = [self.data resultCount];
        self.results = [self.data results];
        // NSArray *arrayTemp = [self.weather results];
        NSLog(@"this is result counts: %@", self.count);
        // NSLog(@"this is array: %@", arrayTemp);
        [self.tableview reloadData];
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"My Title"
                                      message:@"Enter User Credentials"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }];
    
    // 5
    [operation start];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.count intValue];
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ItunesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // // Configure the cell...
    NSDictionary *result = self.results[indexPath.row];
    
    NSString *identifier = [NSString stringWithFormat:@"Cell%ld", (long)indexPath.row];
    if([self.cachedImages objectForKey:identifier] != nil) {
        cell.imageView.image = [self.cachedImages valueForKey:identifier];
    } else {
        char const *s = [identifier UTF8String];
        dispatch_queue_t queue = dispatch_queue_create(s, 0);
        
        dispatch_async(queue, ^{
            NSURL *url = [NSURL URLWithString:[result artworkUrl30]];
            UIImage *img = nil;
            NSData *data = [[NSData alloc] initWithContentsOfURL:url];
            img = [[UIImage alloc] initWithData:data];
            
            
            // Update UI
            __weak UITableViewCell *weakCell = cell;
            dispatch_async(dispatch_get_main_queue(), ^{
                if([tableView indexPathForCell:cell].row == indexPath.row) {
                    [self.cachedImages setValue:img forKey:identifier];
                    cell.imageView.image = [self.cachedImages valueForKey:identifier];
                    weakCell.imageView.image = [self.cachedImages valueForKey:identifier];
                    [weakCell setNeedsLayout];
                }
            });
        });
        
        
    }
    
    cell.textLabel.text = [result trackName];
    return cell;
}

@end
