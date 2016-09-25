//
//  SessionHttpRequest.h
//  NSURLSession
//
//  Created by ZC on 16/9/21.
//  Copyright © 2016年 zc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessBlock)(NSData *downloadData);
typedef void(^DownloadBlock)(NSURL  *location, NSURLResponse  *response, NSError *error);
typedef void(^ProgressBlock)(double progress);

@interface SessionHttpRequest : NSObject
/**
 GET请求数据
 **/
+(void)getSessionRequestDataWithUrlString:(NSString *)urlStr andSuccess:(SuccessBlock)successBlock;
/**
 POST请求数据
 **/
+(void)postSessionRequestDataWithUrlString:(NSString *)urlStr andBody:(NSData*)bodyData andSuccess:(SuccessBlock)successBlock;
/**
 下载文件
 **/
+(void)downloadFileWithUrlString:(NSString *)urlStr andSuccess:(DownloadBlock)downBlock;

/**
 带进度条的下载文件
 **/
+(void)downloadFileWithUrlString:(NSString *)urlStr andProgress:(ProgressBlock)pBlock  andSuccess:(DownloadBlock)downBlock;

/**
 断点续传
 **/
/**1.开始下载**/
+(SessionHttpRequest *)startDownloadFileWithUrlString:(NSString *)urlStr andProgress:(ProgressBlock)pBlock  andSuccess:(DownloadBlock)downBlock;
/**2.暂停**/
-(void)cancleDownloadTask;
/**3.继续下载**/
-(void)continueDownloadTask;

@end











