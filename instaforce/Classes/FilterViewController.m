//
//  FilterViewController.m
//  instaforce
//
//  Created by Raja Rao DV on 2/9/14.
//  Copyright (c) 2014 Salesforce. All rights reserved.
//

#import "FilterViewController.h"
#import "GPUImagePolkaDotFilter.h"


@interface FilterViewController ()

@end

@implementation FilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.filtersArray = [[NSMutableArray alloc] initWithObjects:@"Gray", @"Sepia", @"Color Invert", @"Emboss", @"Polka Dot",  @"Toon", @"Hue", @"Stretch", @"Pinch", @"Sphear", @"None", nil];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.modifiedImage == nil) {
        self.imageView.image = self.originalImage;
        self.modifiedImage = self.originalImage;
    } else {
        self.imageView.image = self.modifiedImage;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    GPUImageFilter *selectedFilter;

    GPUImagePolkaDotFilter *pdFilter;


    switch ((int) indexPath.row) {
        case 0:
            selectedFilter = [[GPUImageGrayscaleFilter alloc] init];
            break;
        case 1:
            selectedFilter = [[GPUImageSepiaFilter alloc] init];
            break;
        case 3:
            selectedFilter = [[GPUImageColorInvertFilter alloc] init];
            break;
        case 4:
            selectedFilter = [[GPUImageEmbossFilter alloc] init];
        case 5:
            pdFilter = [[GPUImagePolkaDotFilter  alloc] init];
            pdFilter.fractionalWidthOfAPixel = 0.03f;
            pdFilter.dotScaling = 1.0f;
            selectedFilter = pdFilter;
            break;
        case 6:
            selectedFilter = [[GPUImageToonFilter alloc] init];
            break;
        case 7:
            selectedFilter = [[GPUImageHueFilter alloc] init];
            break;
         
        case 8:
            selectedFilter = [[GPUImageStretchDistortionFilter alloc] init];
            break;

        case 9:
            selectedFilter = [[GPUImagePinchDistortionFilter alloc] init];
            break;

        case 10:
            selectedFilter = [[GPUImageSphereRefractionFilter alloc] init];
            break;
            
        case 11:
            selectedFilter = [[GPUImageFilter alloc] init];
            break;


        default:
            break;
    }

    self.modifiedImage = [selectedFilter imageByFilteringImage:self.originalImage];
    [self.imageView setImage:self.modifiedImage];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    // If You have only one(1) section, return 1, otherwise you must handle sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.filtersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tblView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tblView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    cell.textLabel.text = [self.filtersArray objectAtIndex:indexPath.row];

    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowPostViewSegue"]) {
        [[segue destinationViewController] setModifiedImage:self.modifiedImage];
    }
}

#pragma mark - buttons
- (IBAction)cancelBtn:(id)sender {
    self.modifiedImage = nil;
    self.originalImage = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
