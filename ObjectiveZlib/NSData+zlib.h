//
//  zlibExtensions.h
//
//  Created by Jeremy Olmsted-Thompson on 8/18/10.
//  Copyright 2010 JOT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (zlib)

+ (NSData*) dataByCompressingData:(NSData*)data;
+ (NSData*) dataByDecompressingData:(NSData*)data;

@end
