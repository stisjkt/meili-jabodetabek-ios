//
//  AnnotationViewController.m
//  Mobility Collector
//
//  Created by Meili on 02/06/18.
//  Copyright © 2018 Adrian Corneliu Prelipcean. All rights reserved.
//

#import "AnnotationViewController.h"

@interface AnnotationViewController ()

@end

@implementation AnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.AnnotationWebView.delegate = self;
    
    [self requestPage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestPage {
    // Preference
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *username = [preferences valueForKey:@"session_username"];
    NSString *password = [preferences valueForKey:@"session_password"];
    
    NSString *reqBody = [NSString localizedStringWithFormat:@"username=%@&password=%@", username, password];
    
    NSString *urlString = @"http://pkks-dev.stis.ac.id/users/loginWebView/";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:[reqBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self.AnnotationWebView loadRequest:req];
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    [self.activityIndicator startAnimating];
    
    [self.prevButton setEnabled:NO];
    [self.nextButton setEnabled:NO];
    [self.annotateButton setEnabled:NO];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidesWhenStopped = YES;
    
    [self.prevButton setEnabled:YES];
    [self.nextButton setEnabled:YES];
    [self.annotateButton setEnabled:YES];
    
    [self.AnnotationWebView stringByEvaluatingJavaScriptFromString:@"hideForAndroid();"];
}

- (IBAction)annotateButtonPushed:(id)sender {
        [self.AnnotationWebView stringByEvaluatingJavaScriptFromString:@"switchNavAndroid();"];
}

- (IBAction)refreshButtonPushed:(id)sender {
    [self requestPage];
}

- (IBAction)prevButtonPushed:(id)sender {
    [self.AnnotationWebView stringByEvaluatingJavaScriptFromString:@"tempTimeline.previewPreviousTripMobility();"];
}

- (IBAction)nextButtonPushed:(id)sender {
    [self.AnnotationWebView stringByEvaluatingJavaScriptFromString:@"tempTimeline.previewNextTripMobility();"];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
