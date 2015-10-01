//
//  PuLogger.m
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 22/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#import "PuLogger.h"
#import "SynthesizeSingleton.h"

@interface PuLogger ()

@end

@implementation PuLogger

SYNTHESIZE_SINGLETON_FOR_CLASS(PuLogger);

#if (TARGET_IPHONE_SIMULATOR)
#define LOG_TO_FILE FALSE
#else
#define LOG_TO_FILE TRUE
#endif

- (void)log:(NSObject *)object
{
    if (!object)
        return;
    
	NSString *logString = [NSString stringWithFormat:@"%@", object];
    
    if (!logString)
        return;
    
    NSLog(@"%@", logString);
}

- (void) redirectConsoleLogToDocumentFolder
{	
	PU_METHOD_LOG
	NSString *fileSize = @"0";
	if(LOG_TO_FILE)
	{		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *logPath = [documentsDirectory stringByAppendingPathComponent:LOGFILE_NAME];
		
		//if file size > threshold, then recycle it
		if([[NSFileManager defaultManager] fileExistsAtPath:logPath])
		{
			NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:logPath error:nil];
			NSNumber *theFileSize = [attributes objectForKey:NSFileSize];
			if(theFileSize)
			{
				int _fileSize = [theFileSize intValue];
				fileSize = [NSString stringWithFormat:@"%d", _fileSize];
                int fileSizeMultiplicityFactor = 1;
				if(_fileSize > 2*fileSizeMultiplicityFactor*1024*1024)
				{
					PU_LOG(@"File size is %@; hence recycling", fileSize);
					//[self removeLogFile:logPath];
				}
			}
		}
	
		freopen([logPath cStringUsingEncoding:NSUTF8StringEncoding],"a+",stderr);
	}
	
	PU_LOG(@"\n\n\n\n\nLOG INIT, START OF NEW SESSION");
	PU_LOG(@"File size was %@", fileSize);
}

- (void) removeLogFile:(NSString *)filePath
{
    PU_METHOD_LOG
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

@end
