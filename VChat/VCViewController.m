//
//  VCViewController.m
//  VChat
//
//  Created by mihata on 11/27/13.
//  Copyright (c) 2013 mihata. All rights reserved.
//

#import "VCViewController.h"
#import "VCConfig.h"

@interface VCViewController ()
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation VCViewController

@synthesize usernameFld;
@synthesize passwordFld;

@synthesize responseData;
@synthesize preloadingImg;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 380.0f, 40.0f, 40.0f)];
    self.progressView.roundedCorners = YES;
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    self.progressView.hidden = NO;
    [self.view addSubview:self.progressView];
    

    usernameFld.delegate = self;
    passwordFld.delegate = self;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBtn:(id)sender {
    
    [self.view endEditing:YES];

    [self startAnimation];
    
    @try {
        [NSURLConnection connectionWithRequest:[VCHelper sendSimpleRequestForUser:usernameFld.text withPassword: passwordFld.text] delegate:self];
        
//        UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        
//        UITableViewController* channelsViewController = [storyboard instantiateViewControllerWithIdentifier:@"channelsView"];
//        
//        [self.navigationController pushViewController:channelsViewController animated:YES];
//        [self dismissViewControllerAnimated:@"loginFormView" completion:nil];]

    } @catch (NSException* e) {
        [VCHelper showAlertMessageWithTitle:@"Invalid Credentials" andText:@"Please provide a valid username and password"];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
   responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [responseData appendData:data];
    NSError* error;
    NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    int success = [[jsonData objectForKey:@"success"] intValue];
    if (success == 1) {
        NSLog(@"Logged");
        VCUser* userObj = [VCUser sharedUser];
        [userObj setUsername:usernameFld.text];
        [userObj setPassword:[jsonData objectForKey:@"pass"]];
        [userObj setLoggedin:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [VCHelper showAlertMessageWithTitle:@"Invalid User" andText:@"There is no user with such username and password"];
    }
    [self stopAnimation];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self stopAnimation];
}

- (void)progressChange
{
    NSArray *progressViews = @[self.progressView];
    for (DACircularProgressView *progressView in progressViews) {
        CGFloat progress = ![self.timer isValid] ? 0.5 / 10.0f : progressView.progress + 0.01f;
        [progressView setProgress:progress animated:YES];
        
        if (progressView.progress >= 1.0f && [self.timer isValid]) {
            [progressView setProgress:0.f animated:YES];
        }
        
    }
}

- (void)startAnimation
{
    self.progressView.hidden = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                  target:self
                                                selector:@selector(progressChange)
                                                userInfo:nil
                                                 repeats:YES];
//    self.continuousSwitch.on = YES;
}

- (void)stopAnimation
{
    [self.timer invalidate];
    self.timer = nil;
    self.progressView.hidden = YES;
//    self.continuousSwitch.on = NO;
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"showChannelsList"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDate *object = _filteredData[indexPath.row];
//        [[segue destinationViewController] setDetailItem:object];
//    }
//}

@end
