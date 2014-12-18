//
//  FileSupport.m
//  bykeMe
//
//  Created by Riccardo Rizzo on 19/05/14.
//  Copyright (c) 2014 Riccardo Rizzo. All rights reserved.
//

#import "FileSupport.h"

@implementation FileSupport

@synthesize fileName;

-(NSString *) saveFilePath
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *fname = [NSString stringWithFormat:@"%@%@",@"/",fileName];
    
    NSLog(@"%@",[[path objectAtIndex:0] stringByAppendingPathComponent:fname]);
    
    return  [[path objectAtIndex:0] stringByAppendingPathComponent:fname];
}

-(void) writeStringToFile:(NSString *) strToWrite {
    [strToWrite writeToFile:[self saveFilePath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"String to file written");
}


-(void) writeDataToFile:(NSMutableArray *) arrToWrite fileToWrite:(NSString *)fname {
    fileName = fname;
    [arrToWrite writeToFile:[self saveFilePath] atomically:YES];
    NSLog(@"Data to file written");
}


-(BOOL) writeObjectToFile:(NSMutableArray*) arrToWrite fileToWrite:(NSString *)fname {
    //UIApplication* app = [UIApplication sharedApplication];
    //NSArray *existingNotifications = [app scheduledLocalNotifications];
    //NSString *path = [self getSavedNotifsPath];
    fileName = fname;
    BOOL success = [NSKeyedArchiver archiveRootObject:arrToWrite toFile:[self saveFilePath]];
    if (! success ) {
        // alert
        return NO;
    }
    return YES;
}

-(NSMutableArray *) readObjectFromFile:(NSString *)fName {
    fileName = fName;
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self saveFilePath]];
}

-(void) writeDataToFile:(NSMutableArray *) arrToWrite {
    [arrToWrite writeToFile:[self saveFilePath] atomically:YES];
    NSLog(@"Data to file written");
}


-(NSMutableArray *) readDataFromFile:(NSString *)fName {
    
    fileName = fName;
    
    NSString *myPath = [self saveFilePath];
    
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
    
	if (fileExists)
	{
        
		NSMutableArray *values = [[NSMutableArray alloc] initWithContentsOfFile:myPath];
        return values;
    }
    return nil;
}

-(NSMutableArray *) readDataFromFile {
    NSString *myPath = [self saveFilePath];
    
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
    
	if (fileExists)
	{
        
		NSMutableArray *values = [[NSMutableArray alloc] initWithContentsOfFile:myPath];
        return values;
    }
    return nil;
}

-(NSString *) readStringFromFile {
    NSString *myPath = [self saveFilePath];
    
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
    
	if (fileExists)
	{
        
		NSString *values = [[NSString alloc] initWithContentsOfFile:myPath encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"Readed: %@",values);
        return values;
    }
    return @"";
}

-(BOOL) fileExist {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *fname_tmp = [NSString stringWithFormat:@"%@%@",@"/",fileName];

    NSString *fname = [[path objectAtIndex:0] stringByAppendingPathComponent:fname_tmp];
    
    if (![fileManager fileExistsAtPath:fname]) {
        return true;
        //[fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:&error];
    }
    return false;
}

-(void)initiCloudFile:(NSString*)fName {
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString  *docsDir = [dirPaths objectAtIndex:0];
    NSString *dataFile = [docsDir stringByAppendingPathComponent:fName];
    self.dURL = [NSURL fileURLWithPath:dataFile];
    NSLog(@"dURL=%@",self.dURL);
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtURL:self.dURL error:nil];
    self.ubURL = [[fileMgr URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"]; //Documents
    if(self.ubURL != nil)
    {
        if([fileMgr fileExistsAtPath:[self.ubURL path]] == NO)
            [fileMgr createDirectoryAtURL:self.ubURL withIntermediateDirectories:YES attributes:nil error:nil];
        self.ubURL = [self.ubURL URLByAppendingPathComponent:fName];
        NSLog(@"ubURL = %@",self.ubURL);
        self.metaDQ = [[NSMetadataQuery alloc] init];
        NSString *format = [NSString stringWithFormat:@" like '%@'",fName];
        NSString *initFormat = @"%K";
        NSString *f2 = [initFormat stringByAppendingString:format];
        [self.metaDQ setPredicate:[NSPredicate predicateWithFormat:f2 ,NSMetadataItemFSNameKey]];
        [self.metaDQ setSearchScopes:[NSArray arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope, nil]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metaDQFinita:) name:NSMetadataQueryDidFinishGatheringNotification object:self.metaDQ];
        [self.metaDQ startQuery];
    }
    else { //Icloud not present. SImulator??
        [self.delegate loadSessions:NO];
        
    }
}

/*
-(void)metaDQFinita:(NSNotification *)notification {
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
    [query stopQuery];
    
    NSArray *results = [[NSArray alloc] initWithArray:[query results]];
    if([results count] == 1)
    {
        //The file exist on iCloud
        self.ubURL = [[results objectAtIndex:0] valueForAttribute:NSMetadataItemURLKey];
        self.documento = [[myDoc alloc] initWithFileURL:self.ubURL];
        [self.documento openWithCompletionHandler:
         ^(BOOL success){
             if(success) {
                 NSLog(@"OPEN iCloud Document");
                 //read the file on self.documento.text
                 readArray = [[NSMutableArray alloc] init];
                 readArray = self.documento.data;
                 
                 if([readArray count] > 0)
                 {
                     //**Load temp mutable array and send to maind elegate
                     NSMutableArray *sessDate = [readArray objectAtIndex:0];
                     NSMutableArray *sessDistance = [readArray objectAtIndex:1];
                     NSMutableArray *sessMaxSpeed = [readArray objectAtIndex:2];
                     NSMutableArray *sessAvgSpeed = [readArray objectAtIndex:3];
                     NSMutableArray *sessAltitude = [readArray objectAtIndex:4];
                     [self.delegate updateFilesFromiCloud:sessDate ar2:sessDistance ar3:sessMaxSpeed ar4:sessAvgSpeed ar5:sessAltitude];
                 }
                 else //Ops problem with icloud document - open the saved one if there
                 {
                     [self.delegate loadSessions];
                 }
             }
             else {
                 NSLog(@"Error to open iCloud document");
                 [self.delegate loadSessions];
             }
          //   [self.delegate stopActivityIndicator];
         }];
    }
    else {
        //The file non exixt on iCloud
        self.documento = [[myDoc alloc] initWithFileURL:self.ubURL];
        [self.documento saveToURL:self.ubURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             if(success) {
                 NSLog(@"Document saved to iCloud");
             }
             else{
                 NSLog(@"Error to write on iCLoud");
             }
         }];
    }
}

-(void)saveFile:(NSMutableArray*) dataToSave{
    self.documento.data = dataToSave;
    [self.documento saveToURL:self.ubURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if(success){
            NSLog(@"Saved to iCloud");
        }
        else {
            NSLog(@"Error saving to iCloud");
        }

    }];
}
*/
@end
