//
//  FileSupport.h
//  bykeMe
//
//  Created by Riccardo Rizzo on 19/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MainClassDelegate

-(void)loadSessions;
-(void)loadSessions:(BOOL)iCloudSupport;
-(void)saveSessions;
-(void)updateFilesFromiCloud:(NSMutableArray *) _title_ ar2:(NSMutableArray*)_creation ar3:(NSMutableArray*) _descriptions ar4:(NSMutableArray*)_checked ar5:(NSMutableArray*)_notifications_;

@end

@interface FileSupport : NSObject {
    NSString *fileName;
    NSMutableArray *readArray;
}

@property (strong) NSString *fileName;

-(NSString *) saveFilePath;
-(void) writeStringToFile:(NSString *) strToWrite;
-(void) writeDataToFile:(NSMutableArray *) arrToWrite;
-(void) writeDataToFile:(NSMutableArray *) arrToWrite fileToWrite:(NSString *)fname;
-(BOOL) writeObjectToFile:(NSMutableArray*) arrToWrite fileToWrite:(NSString *)fname;

-(NSMutableArray *) readObjectFromFile:(NSString *)fName;
-(NSMutableArray *) readDataFromFile;
-(NSMutableArray *) readDataFromFile:(NSString *)fName;
-(NSString *) readStringFromFile;
-(BOOL) fileExist;


//Added for icloud support
@property (nonatomic) id<MainClassDelegate> delegate;  //For call main method

@property(strong,nonatomic) NSURL *dURL;
@property(strong,nonatomic) NSURL *ubURL;
@property(strong,nonatomic) NSMetadataQuery *metaDQ;
//@property(strong,nonatomic) myDoc *documento;
-(void)saveFile:(NSMutableArray*) dataToSave;
-(void)initiCloudFile:(NSString*)fName;
    
@end
