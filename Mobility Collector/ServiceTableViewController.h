//
//  ServiceTableViewController.h
//  Mobility Collector
//
//  Created by Meili on 04/06/18.
//  Copyright © 2018 Adrian Corneliu Prelipcean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmbeddedLocationListener.h"

@interface ServiceTableViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic) EmbeddedLocationListener *listener;
@property (weak, nonatomic) IBOutlet UILabel *usernameInfo;
@property (weak, nonatomic) IBOutlet UILabel *statusInfo;
@property (weak, nonatomic) IBOutlet UILabel *locationInfo;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIRefreshControl *refreshControl;

-(void) refreshData;

@end
