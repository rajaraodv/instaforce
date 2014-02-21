//
//  SettingsViewController.m
//  instaforce
//
//  Created by Raja Rao DV on 2/21/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

//outlet from storyboard. We can define it here in .m (instead of .h)
@property (strong, nonatomic) IBOutlet UITableView *tableView;



@end

@implementation SettingsViewController


#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //allocate groups mutable array
    self.groups = [[NSMutableArray alloc] init];
    
    //make this controller delegate (to receive calls)
    self.tableView.delegate = self;
    
    //make this controller dataSource to set rows of info to cells.
    self.tableView.dataSource = self;
	
    [self getChatterGroups];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getChatterGroups {
    
    
    SFRestAPI *api = [SFRestAPI sharedInstance];
    
    
    NSString *path = [NSString stringWithFormat:@"/%@/chatter/groups", [api apiVersion]];
    SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodGET path:path queryParams:nil];
    [[SFRestAPI sharedInstance] send:request delegate:self];
}

#pragma mark - UITableViewDelegate

-   (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return [self.groups count];
}

//select new one
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *group = [self.groups objectAtIndex:indexPath.row];
    self.selectedGroupId = [group objectForKey:@"id"];
    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GroupsCell";
    
    UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    //[cell.textLabel setTextColor:[UIColor whiteColor]];
    NSDictionary *group = [self.groups objectAtIndex:indexPath.row];
    cell.textLabel.text = [group objectForKey:@"name"];
   // NSLog(@"%@ %@", [group objectForKey:@"id"], self.selectedGroupId);
    
    if([[group objectForKey:@"id"] isEqualToString: self.selectedGroupId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - SFRestDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    //important to remove all groups before adding them back in (coz it's mutable array.. so stuff keeps getting added).
    [self.groups removeAllObjects];
    
    self.groups  = jsonResponse[@"groups"];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (void)request:(SFRestRequest *)request didFailLoadWithError:(NSError *)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}


@end
