//
//  ViewController.m
//  PhotoCollageView
//
//  Created by soleaf on 14. 2. 17..
//  Copyright (c) 2014년 soleaf. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSMutableString *data = [[NSMutableString alloc] init];
    [data appendString:@"aroundtheplate.org/wp-content/uploads/2013/04/mint.jpg|2916|1939"];
    [data appendString:@",www.mydailyfind.com/wp-content/uploads/2010/04/mint-main-m-m.jpg|300|300"];
    [data appendString:@",4.bp.blogspot.com/-ggV92zp6Bo0/TgSyw0f7kWI/AAAAAAAAC_o/-f6d5F_2Zxs/s1600/Mint-Cacao-Brownies.jpg|1400|960"];
    [data appendString:@",upload.wikimedia.org/wikipedia/commons/c/c1/Scotch_mints.JPG|1600|1200"];
//    [data appendString:@",blogs.babble.com/family-kitchen/files/2011/03/cucumber-mint-sandwich-2-large.jpg|800|548"];

    self.collageView.padding = 5;
    [self.collageView prepareWithPhotoURLs:data];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
