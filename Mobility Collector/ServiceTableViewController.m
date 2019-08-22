//
//  ServiceTableViewController.m
//  Mobility Collector
//
//  Created by Meili on 04/06/18.
//  Copyright © 2018 Adrian Corneliu Prelipcean. All rights reserved.
//


#import "ServiceTableViewController.h"
#import "AppDelegate.h"

@interface ServiceTableViewController ()
@property BOOL serviceStarted;
@end

@implementation ServiceTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceStarted = false;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.serviceStarted = [[DatabaseHelper getInstance] getIsServiceRunning];
    NSLog(@"Is service running: %d", (int)self.serviceStarted);
    
    self.listener = [EmbeddedLocationListener getInstance];
    if (!self.serviceStarted) {
        [self startService];
        //        [self.serviceHandlingButton setTitle:@"Start" forState:UIControlStateNormal];
        //    } else {
        //        [self.serviceHandlingButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
    
    [self refreshData];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
//    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshData {
    [self.usernameInfo setText:[[NSUserDefaults standardUserDefaults] valueForKey:@"session_username"]];
    [self.statusInfo setText:[(AppDelegate *)[[UIApplication sharedApplication] delegate] isLocationServiceEnabled] ? @"Running" : @"Stopped"];
    
    NSString *pointStatus = [NSString stringWithFormat:@"%d recorded", [[DatabaseHelper getInstance] getLocationCount]];
    
    int toUpload = [[DatabaseHelper getInstance] getToUploadLocationCount];
    if(toUpload > 0) {
        pointStatus =  [NSString stringWithFormat:@"%d recorded, %d to upload",
                        [[DatabaseHelper getInstance] getLocationCount],
                        [[DatabaseHelper getInstance] getToUploadLocationCount]];
    }
    
    [self.locationInfo setText:pointStatus];
    
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 3;
    } else if(section == 1) {
        return 2;
    }
    return 0;
}

- (void) startService {
    [[DatabaseHelper getInstance] updateIsServiceRunning:true];
    [self.listener startListeningService];
    self.serviceStarted=true;
    
    //    [self.serviceHandlingButton setTitle:@"Stop"
    //                                forState:UIControlStateNormal];
    
    [self sendLogs];
    [self sendUploadURLRequest:nil];
}

- (void) stopService {
    [[DatabaseHelper getInstance] updateIsServiceRunning:false];
    
    //    [self.serviceHandlingButton setTitle:@"Start" forState:UIControlStateNormal];
    
    [self.listener stopListeningService];
    self.serviceStarted = false;
}



-(void) sendLogs{
    DatabaseHelper* dbHelper = [DatabaseHelper getInstance];
    
    NSString *dataToUpload = [dbHelper getAllMessages];
    [[DatabaseHelper getInstance] deleteUploadedLogs];
    
    // everything was commented out because the background listening was fixed for the tested version
    // THIS MIGHT NEED TO BE REOPENNED FOR TESTING THE NEW VERSIONS DUE TO CODE AND FLAGS MODIFICATIONS
    //   NSLog(@"%@",dataToUpload);
    /*
     if ([dataToUpload length]!=0)
     {
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@http://pkks-dev.stis.ac.id/users/insertLog"]];
     
     [request setHTTPMethod:@"POST"];
     
     NSString *postString = [NSString stringWithFormat:@"userId=%u&dataToUpload=%@",[dbHelper getUserId], dataToUpload];
     
     [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
     
     [NSURLConnection sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
     id str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     NSLog(@"%@",str);
     
     if ([str isEqual:@"success"]){
     [[DatabaseHelper getInstance] deleteUploadedLogs];
     }
     }];
     }
     */
}

-(void) sendUploadURLRequest: (UITableViewCell *)cell {
    
    DatabaseHelper* dbHelper = [DatabaseHelper getInstance];
    NSString *dataToUpload = [dbHelper getLocationsForUpload];
    
    if(cell != nil) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorView startAnimating];
        cell.accessoryView = activityIndicatorView;
    }
    
    NSLog(@"Data To Upload: %@",dataToUpload);
    
    if ([dataToUpload length]!=0) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://pkks-dev.stis.ac.id/users/insertLocationsIOS"]];
        [request setHTTPMethod:@"POST"];
        
        NSString *postString = [NSString stringWithFormat:@"dataToUpload=%@", dataToUpload];
    
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   id str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"%@",str);
                                   
                                   NSString *message = @"Upload Failed";
                                   
                                   if([[DatabaseHelper getInstance] getToUploadLocationCount] == 0) {
                                       message = @"No Data to Upload";
                                   }
                                   
                                   if ([str isEqual:@"success"]){
                                       [[DatabaseHelper getInstance] updateUploadedLocations];
                                       message = @"Upload Success";
                                   }
                                   
                                   if(cell != nil) {
                                       cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                                       cell.accessoryView = nil;
                                       
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Status" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                       [alert show];
                                   }
                               }];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 && indexPath.row == 1) {
        [self sendUploadURLRequest:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self refreshData];
}

@end
