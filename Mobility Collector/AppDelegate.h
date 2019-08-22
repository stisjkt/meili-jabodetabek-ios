//
//  AppDelegate.h
//  Mobility Collector
//
//  Created by Adrian Corneliu Prelipcean on 24/07/15.
//  Copyright (c) 2015 Adrian Corneliu Prelipcean. All rights reserved.
//

#import "DatabaseHelper.h"
#import "EmbeddedLocationListener.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property BOOL isLocationServiceEnabled;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

