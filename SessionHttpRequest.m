//
//  SessionHttpRequest.m
//  NSURLSession
//
//  Created by ZC on 16/9/21.
//  Copyright © 2016年 zc. All rights reserved.
//

#import "SessionHttpRequest.h"

@interface SessionHttpRequest()<NSURLSessionDownloadDelegate>

@property(nonatomic,copy)SuccessBlock sBlock;
@property(nonatomic,copy)DownloadBlock dBlock;
@property(nonatomic,copy)ProgressBlock pBlock;
@property (strong, nonatomic) NSURLSessionDownloadTask *task;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSData *resumeData;//保存暂停时下载的数据

@end

@implementation SessionHttpRequest
/**
 GET请求数据
 **/
+(void)getSessionRequestDataWithUrlString:(NSString *)urlStr andSuccess:(SuccessBlock)successBlock{
    SessionHttpRequest *http = [[SessionHttpRequest alloc] init];
    http.sBlock= successBlock;
    
    //NSURLSession实现异步请求数据【GET】
    //不管有没有中文，最好是不要忘记这这一步
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //1.构造NSURL
    NSURL *url = [NSURL URLWithString:urlStr];
    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //3.创建NSURLSession对象
    //如果下载文件，默认会将下载的文件保存在沙盒目录中的tmp目录下
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //4.创建任务？
    //1).获取数据? NSURLSessionDataTask
    //2).下载文件？NSURLSessionDownloadTask
    //3).上传文件？NSURLSessionUploadTask
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //请求数据，返回请求的结果
        if (data) {
            //回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                http.sBlock(data);
            });
        }
    }];
    //5.启动任务【开始发起异步请求】
    [task resume];

}
/**
 POST请求数据
 **/
+(void)postSessionRequestDataWithUrlString:(NSString *)urlStr andBody:(NSData*)bodyData andSuccess:(SuccessBlock)successBlock{
    SessionHttpRequest *http = [[SessionHttpRequest alloc] init];
    http.sBlock= successBlock;
    
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //1.
    NSURL *url  = [NSURL URLWithString:urlStr];
    //2.
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:url];
    mRequest.HTTPMethod = @"POST";
    mRequest.timeoutInterval = 2;
    mRequest.HTTPBody = bodyData;
    //3.
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //4.
    NSURLSessionDataTask *task = [session dataTaskWithRequest:mRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //请求数据，返回请求的结果
        if (data) {
            //回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                http.sBlock(data);
            });
        }
    }];
    //5.
    [task resume];

}
/**
 下载文件
 **/
+(void)downloadFileWithUrlString:(NSString *)urlStr andSuccess:(DownloadBlock)downBlock{
    SessionHttpRequest *http = [[SessionHttpRequest alloc] init];
    http.dBlock = downBlock;

    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //1.构造NSURL
    NSURL *url  = [NSURL URLWithString:urlStr];
    //2.创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //3.创建NSURLSession对象
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    //4.创建【下载文件】的任务对象
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {        
        http.dBlock(location,response,error);

    }];
    //5.启动任务
    [task resume];
}

/**
 带进度条的下载文件
 **/
+(void)downloadFileWithUrlString:(NSString *)urlStr andProgress:(ProgressBlock)pBlock  andSuccess:(DownloadBlock)downBlock{
    SessionHttpRequest *http = [[SessionHttpRequest alloc] init];
    http.pBlock = pBlock;
    http.dBlock = downBlock;
    
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //1.URL
    NSURL *url = [NSURL URLWithString:urlStr];
    //2.NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //3.NSURLSession
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:http delegateQueue:nil];
    //4.创建任务
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];
    //5.启动任务
    [task resume];

}

/**断点续传**/
+(SessionHttpRequest *)startDownloadFileWithUrlString:(NSString *)urlStr andProgress:(ProgressBlock)pBlock  andSuccess:(DownloadBlock)downBlock;{

    SessionHttpRequest *http = [[SessionHttpRequest alloc] init];
    http.pBlock = pBlock;
    http.dBlock = downBlock;
    
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //1.URL
    NSURL *url = [NSURL URLWithString:urlStr];
    //2.NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //3.Session对象
    http.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:http delegateQueue:nil];
    //4.task
    http.task = [http.session downloadTaskWithRequest:request];
    //5.启动
    [http.task  resume];
    return http;
}

/**暂停**/
-(void)cancleDownloadTask{
    //暂停下载任务
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        self.resumeData = resumeData;
    }];
}
/**继续下载**/
-(void)continueDownloadTask{
    //接着上次暂停的位置开始下载
    if (self.resumeData) {
        self.task = [self.session  downloadTaskWithResumeData:self.resumeData];
        [self.task resume];//启动任务
        self.resumeData = nil;

    }
}


#pragma mark -NSURLSessionDownloadDelegate
//下载过程中，不断的调用
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    //计算当前下载的进度
    //由当前总共已经下载的大小/文件的总大小
    double progress  = totalBytesWritten*1.0/totalBytesExpectedToWrite;
    NSLog(@"当前下载的进度是:%.2lf",progress);
    //回到主线程，更新进度条的显示
    dispatch_async(dispatch_get_main_queue(), ^{
        //更新进度条
        self.pBlock(progress);
    });
}

//下载完成后，调用以下方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    //location 下载回来的文件所保存的临时目录
    //将临时文件保存到指定的目录中
    self.dBlock(location,nil,nil);
    
}



@end







