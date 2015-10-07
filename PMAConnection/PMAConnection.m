//
//  PMAConnection.m
//  PMAConnection
//
//  Created by Poslovanje Kvadrat on 10.04.2015..
//  Copyright (c) 2015. Poslovanje Kvadrat. All rights reserved.
//

#import "PMAConnection.h"
#import "XMLReader.h"

@implementation PMAConnection
@synthesize delegate;


-(void)sendRequestWithDictionary:(NSDictionary *)dict withMethod:(NSString *)method forURLWithString:(NSString *)urlString{

    self.method = method;
    self.connectionURL = [NSURL URLWithString:urlString];
    self.dataString = [self setRequestStringFromDataDictionary:dict];
    
    [self startRequest];
}

-(void)startRequest{

    NSString *post = self.dataString;
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:self.connectionURL];
    [request setHTTPMethod:self.method];
    [request setCachePolicy:NSURLRequestReloadRevalidatingCacheData];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];

}

-(NSString *)setRequestStringFromDataDictionary:(NSDictionary *)dataDict{

    NSString *recheckForPlusFilter = [[NSString alloc] init];
    NSArray * parameterKeys = [[NSMutableArray alloc] init];
    NSArray * parameterValues = [[NSMutableArray alloc] init];
    
    parameterKeys = [dataDict allKeys];
    parameterValues = [dataDict allValues];
    
    NSMutableString *preRequestString = [NSMutableString stringWithFormat:@""];
    
    for (int i=0; i< [parameterKeys count]; i++) {
        
        if ([[parameterValues objectAtIndex:i] isKindOfClass:[NSString class]]){
            recheckForPlusFilter = [[parameterValues objectAtIndex:i] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            NSString *keyAndValue = [NSString stringWithFormat:@"%@=%@", [parameterKeys objectAtIndex:i], recheckForPlusFilter];
            if (i==0) {
                [preRequestString appendString:keyAndValue];
            }else{
                [preRequestString appendString:[NSString stringWithFormat:@"&%@", keyAndValue]];
            }
            
        }else{
            NSString *keyAndValue = [NSString stringWithFormat:@"%@=%@", [parameterKeys objectAtIndex:i], [parameterValues objectAtIndex:i]];
            if (i==0) {
                [preRequestString appendString:keyAndValue];
            }else{
                [preRequestString appendString:[NSString stringWithFormat:@"&%@", keyAndValue]];
            }
        }
    }
    //NSLog(@"request string: %@", preRequestString);
    return preRequestString;
}



#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    self.responseType = response.MIMEType;
    self.responseLength = response.expectedContentLength;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //NSLog(@"Data recieved -> %@", data.description);
    
    self.connectionStatus = @"OK";
    self.remoteData = data;
    
    [self processComplete];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // NSLog(@"Error with connecting: %@", error);
    
    self.connectionStatus = @"ERROR";
    self.remoteData = nil;
    self.errorLog = error.description;
    
    [self processComplete];
}


-(void)downloadFilewithURL:(NSString *)downloadURL toDocumentsAs:(NSString *)fileName andType:(NSString *)fileType;{

    NSString *fullFileName = [NSString stringWithFormat:@"%@.%@", fileName, fileType];
    
    if(![self checkForFileWithName:fullFileName]){
        NSLog(@"Download started.");
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSURL  *url = [NSURL URLWithString:downloadURL];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                
                NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString  *documentsDirectory = [paths objectAtIndex:0];
                NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fullFileName];
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    [urlData writeToFile:filePath atomically:YES];
                    
                    NSMutableDictionary *dwnRespMutable = [[NSMutableDictionary alloc] init];
                    [dwnRespMutable setObject:filePath forKey:@"filePath"];
                    [dwnRespMutable setObject:fileName forKey:@"fileName"];
                    [dwnRespMutable setObject:fileType forKey:@"fileType"];
                    [dwnRespMutable setObject:[NSString stringWithFormat:@"%f",[self getFileSizeForFile:filePath]] forKey:@"fileSize"];
                    
                    NSDictionary *dwn = dwnRespMutable;
                    
                    [[self delegate] PMADidDownloadFile:dwn];
                });
            }
        });
        
    }else{
        NSLog(@"File %@ is already downloaded", fullFileName);
    }
}


-(BOOL)checkForFileWithName: (NSString *)filename{
    
    NSLog(@"Checking for file: %@", filename);
    
    NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSLog(@"File (%f KB) found: %@", [self getFileSizeForFile:filePath],filePath);
        return TRUE;
    }else{
         NSLog(@"File not found locally.");
        return FALSE;
    }
}

-(float)getFileSizeForFile:(NSString *)filePath{

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    unsigned long long sizeFull = 0;
    
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath error:nil];
    
    if (fileAttributes != nil) {
        NSNumber *fileSize;
        if ((fileSize = [fileAttributes objectForKey:NSFileSize])) {
            sizeFull = sizeFull + [fileSize unsignedLongLongValue];
        }else{
            NSLog(@"Path (%@) is invalid.", filePath);
        }
    }
    return (float)sizeFull/1024;
}

#pragma mark response parse

-(void)manageXMLResponse{
    NSData * data = self.remoteData;
    NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLData:data error:nil];
    self.responseDictionary = xmlDictionary;
    self.responseString = self.responseDictionary.description;
    //NSLog(@"parseded string: %@", self.responseString);
}
-(void)manageJSONResponse{
   
    NSError* error = nil;
    self.responseObject = [NSJSONSerialization
                           JSONObjectWithData:self.remoteData
                           options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                           error:&error];
    if ([self.responseObject isKindOfClass:[NSArray class]]) {
        self.responseArray = (NSArray *)self.responseObject;
        self.responseString = self.responseArray.description;

    }
    else {
        self.responseDictionary = (NSDictionary *)self.responseObject;
        self.responseString = self.responseDictionary.description;
    }
}

#pragma mark process complete


- (void)processComplete
{
    
    if ([self.connectionStatus isEqualToString:@"OK"]) {
        
        // handle response
        if ([self.responseType hasPrefix:@"application/xml"]) {
            
            //NSLog(@"XML Response type");
            [self manageXMLResponse];
            
        }else if ([self.responseType hasPrefix:@"application/json"]){
            //NSLog(@"JSON Response type");
            [self manageJSONResponse];
            
        }else{
            NSLog(@"Wrong document header = %@", self.responseType);
        }
        
        [self prepareResponseObjectForDelegate];
        
    }else{
        // handle error
        NSLog(@"Connection ERROR: %@", self.errorLog);
        
        NSMutableDictionary *reponseMutableDict = [[NSMutableDictionary alloc] init];
        [reponseMutableDict setObject:self.errorLog forKey:@"error"];
        self.responseDictionary = reponseMutableDict;
    }
    
    
}

-(void)prepareResponseObjectForDelegate{
    
    NSMutableDictionary *reponseMutableDict = [[NSMutableDictionary alloc] init];
    //setting other response data
    [reponseMutableDict setObject:self.responseType forKey:@"type"];
    
    if (self.responseDictionary) {
        //NSLog(@"response is a dictionary");
        
        [reponseMutableDict setObject:self.responseDictionary forKey:@"response"];
       
    }
    
    if (self.responseArray) {
        //NSLog(@"response is an array");
        
        [reponseMutableDict setObject:self.responseArray forKey:@"response"];
        
    }
    
    //NSLog(@"test dict: %@", reponseMutableDict.description);
    self.responseDictionary = reponseMutableDict;
    
    [[self delegate] PMADidRecieveResponse:self.responseDictionary];
}

@end
