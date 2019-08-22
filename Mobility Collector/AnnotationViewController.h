//
//  AnnotationViewController.h
//  Mobility Collector
//
//  Created by Meili on 02/06/18.
//  Copyright © 2018 Adrian Corneliu Prelipcean. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnotationViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *AnnotationWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *annotateButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *prevButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@end
