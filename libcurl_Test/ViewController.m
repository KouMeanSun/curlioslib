//
//  ViewController.m
//  libcurl_Test
//
//  Created by      on 16/3/10.
//  Copyright © 2016年     . All rights reserved.
//

#import "ViewController.h"
#import "curl/curl.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *curlImageView;
@property(nonatomic, strong)NSMutableData *imageData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.curlImageView.backgroundColor = [UIColor blueColor];
    self.imageData = [[NSMutableData alloc]init];
    
    [NSThread detachNewThreadSelector:@selector(callCurl) toTarget:self withObject:nil];
    
}


- (void)callCurl
{
    _curl = curl_easy_init();
    curl_easy_setopt(_curl, CURLOPT_URL, "http://img.ptcms.csdn.net/article/201506/25/558bbe1baed6e.jpg");
    curl_easy_setopt(_curl, CURLOPT_HTTPAUTH, CURLAUTH_ANY);
    curl_easy_setopt(_curl, CURLOPT_WRITEFUNCTION, imageViewCallback);
    curl_easy_setopt(_curl, CURLOPT_WRITEDATA, self);
    CURLcode errorCode = curl_easy_perform(_curl);
    
    
    //NSLog(@"-->imageData:%@", self.imageData);
    UIImage *image = [UIImage imageWithData:_imageData];
    //NSLog(@"---image:%@", image);
    if (image != nil) {
        [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    }
    
}


/**
 * 设置imageview的图片
 */
- (void)setImage:(UIImage *)image
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imagePath = [documentPath stringByAppendingPathComponent:@"test.jpg"];
    //NSLog(@"--line:%d---Path:%@------imagePath:%@", __LINE__, documentPath, imagePath);
    [self.imageData writeToFile:imagePath atomically:YES];
    self.curlImageView.image = image;
}

size_t imageViewCallback(char *ptr, size_t size, size_t nmemb, void *userdata)
{
    const size_t sizeInBytes = size*nmemb;
    ViewController *vc = (__bridge ViewController *)userdata;
    NSData *data = [[NSData alloc]initWithBytes:ptr length:sizeInBytes];
    NSLog(@"--->>line:%d,data:%@", __LINE__, data);
    [vc.imageData appendData:data];
    return sizeInBytes;
}


- (void)dealloc
{
    curl_easy_cleanup(_curl);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
