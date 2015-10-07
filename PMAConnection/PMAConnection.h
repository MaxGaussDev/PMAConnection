//
//  PMAConnection.h
//  PMAConnection
//
//  Created by Poslovanje Kvadrat on 10.04.2015..
//  Copyright (c) 2015. Poslovanje Kvadrat. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PMAConnectionDelegate <NSObject>

@optional
- (void) PMADidRecieveResponse: (NSDictionary *)responseData;

@optional
- (void) PMADidDownloadFile: (NSDictionary *)fileData;

@end


@interface PMAConnection : NSObject <NSURLConnectionDelegate>{
    id <PMAConnectionDelegate> delegate;
}

@property (retain) id delegate;

// connection settings
@property (nonatomic, strong) NSURL *connectionURL;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSDictionary *dataDictionary;
@property (nonatomic, strong) NSString *dataString;

// response handling

@property (nonatomic, strong) NSURLResponse *responseData;
@property (nonatomic, strong) NSString *connectionStatus;
@property (nonatomic, strong) NSString *responseType;
@property long long responseLength;
@property (nonatomic, strong) NSData *remoteData;

@property (nonatomic, strong) NSDictionary *responseDictionary;
@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) NSArray *responseArray;
@property (nonatomic, strong) id responseObject;

// error handling
@property (nonatomic, strong) NSString *errorLog;

-(void)sendRequestWithDictionary:(NSDictionary *)dict withMethod:(NSString *)method forURLWithString:(NSString *)urlString;
-(void)downloadFilewithURL:(NSString *)downloadURL toDocumentsAs:(NSString *)fileName andType:(NSString *)fileType;

@end


