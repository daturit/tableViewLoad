# tableViewLoad
Loading, Caching Images And Update UI Asynchronously on UITableView

You may have faced with the times you have some pictures that needs to be shown on UITableView. Today, I’m going to demonstrate a pattern(pretty good one actually) that you may use while creating TableViews. I have been using this pattern for months and it improves the responsiveness of the table view. What you will learn in this post are how to use UITableViewDelegate and UITableViewDataSource in UIViewController, how to fetch the image from the specified URL using GCD(General Central Dispatch), a little caching tricks, and update UI.

Now let’s get started.

1. Create a new Single View Project. In main.storyboard add one table view object.
And link the delegate and datasource property of your UITableView to File’s owner like below.

2- Go to header file of your ViewController, add new NSMutableDictionary property and add UITableViewDelegate, UITableViewDataSource protocols.

@property(strong) NSDictionary *data; @property(strong, nonatomic) NSNumber *count; 
@property (strong, nonatomic) NSArray *results; 
@property (strong, nonatomic) NSMutableDictionary *cachedImages;

3- Now go to main file of your ViewController, and initialize cacheImages dictionary on viewDidLoad:

self.cachedImages = [[NSMutableDictionary alloc] init]; 
self.results = [[NSMutableArray alloc] init]; 
self.tableview.delegate = self;

You might have a hint about what we are going to do. We are going to give unique name for each image and store them in cacheImages dictionary, so that, It will be cached on application until application gets killed / terminated. As TableView scrolls down, we check if the image for specified cell is cached previously, and if it is, we retrieve image from cache instead of making a request again. It will be all done with using GCD in TableViewDataSource methods with just a few lines of code! To make it clear, I will start pasting methods to ViewController we use, and explain each one of them.

// // 
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
