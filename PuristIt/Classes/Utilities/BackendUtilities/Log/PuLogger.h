//
//  PuLogger.h
//  PuristIt
//
//  Created by Ramakrishnan Naidu on 22/02/15.
//  Copyright (c) 2015 PuristSoft Corp. All rights reserved.
//

#define PU_DEBUG_ALERT(...)  { UIAlertView *__alert = [[[UIAlertView alloc] initWithTitle:@"Debug Alert" \
message:[NSString stringWithFormat:__VA_ARGS__] delegate:self \
cancelButtonTitle:@"Done" otherButtonTitles:nil] autorelease]; \
[__alert show]; } \

#define PU_METHOD_LOG { ([PuLogger.shared log:[NSString stringWithFormat:@"%@::%@", self.class, NSStringFromSelector(_cmd)]]); }
#define PU_LOG(...) ([PuLogger.shared log:[NSString stringWithFormat:@"%@::%@: %@", self.class, NSStringFromSelector(_cmd), [NSString stringWithFormat:__VA_ARGS__]]])

#define LOGFILE_NAME @"pu.log.bin"
#define LOGFILE_MIMETYPE @"application/x-gzip"

@interface PuLogger : NSObject

+ (PuLogger *)shared;

- (void)log:(NSObject *)object;
- (void) redirectConsoleLogToDocumentFolder;

@end
