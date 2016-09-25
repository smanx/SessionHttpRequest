# SessionHttpRequest

##网络请求的简单封装

###功能及用法
####1.GET请求数据
```
+(void)getSessionRequestDataWithUrlString:(NSString *)urlStr andSuccess:(SuccessBlock)successBlock;
```
####2. POST请求数据
```
+(void)postSessionRequestDataWithUrlString:(NSString *)urlStr andBody:(NSData*)bodyData andSuccess:(SuccessBlock)successBlock;
```
####3.下载文件
```
+(void)downloadFileWithUrlString:(NSString *)urlStr andSuccess:(DownloadBlock)downBlock;
```
####4.带进度条的下载文件
```
+(void)downloadFileWithUrlString:(NSString *)urlStr andProgress:(ProgressBlock)pBlock  andSuccess:(DownloadBlock)downBlock;
```
####5.断点续传
#####5.1 开始下载
```
+(SessionHttpRequest *)startDownloadFileWithUrlString:(NSString *)urlStr andProgress:(ProgressBlock)pBlock  andSuccess:(DownloadBlock)downBlock;

```
#####5.2 暂停
```
-(void)cancleDownloadTask;
```
#####5.3 继续下载
```
-(void)continueDownloadTask;
```
