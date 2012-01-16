//
//  zlibExtensions.m
//
//  Created by Jeremy Olmsted-Thompson on 8/18/10.
//  Copyright 2010 JOT. All rights reserved.
//

#import "NSData+zlib.h"

#define COMPRESSION_BLOCK 65536

#define CHECK_ERR(err, msg) {\
	if(err < 0) {\
		NSLog(@"%@ error: %d", msg, err);\
		return nil;\
	}\
}

@implementation NSData (zlib)

//  Returns the zlib compressed version of the input data or nil if there was an error
+ (NSData*) dataByCompressingData:(NSData*)data{
	Byte* bytes = (Byte*)[data bytes];
	NSInteger len = [data length];
	NSMutableData *compressedData = [[NSMutableData alloc] initWithCapacity:len];
	Byte* compressedBytes = new Byte[len];
	
	z_stream stream;
	int err;
	stream.zalloc = (alloc_func)0;
	stream.zfree = (free_func)0;
	stream.opaque = (voidpf)0;
	
	err = deflateInit(&stream, Z_DEFAULT_COMPRESSION);
	CHECK_ERR(err, @"deflateInit");
	
	
	stream.next_in = bytes;
	stream.avail_in = len;
	stream.avail_out = 0;
	while (stream.avail_out == 0) {
		stream.avail_in = len - stream.total_in;
		stream.next_out = compressedBytes;
		stream.avail_out = COMPRESSION_BLOCK;
		err = deflate(&stream, Z_NO_FLUSH);
		[compressedData appendBytes:compressedBytes length:(stream.total_out-[compressedData length])];
		if (err == Z_STREAM_END)
			continue;
		CHECK_ERR(err, @"deflate");
	}
	stream.avail_out = 0;
	while (stream.avail_out == 0) {
		stream.avail_in = len - stream.total_in;
		stream.next_out = compressedBytes;
		stream.avail_out = COMPRESSION_BLOCK;
		err = deflate(&stream, Z_FINISH);
		[compressedData appendBytes:compressedBytes length:(stream.total_out-[compressedData length])];
		if (err == Z_STREAM_END)
			continue;
		CHECK_ERR(err, @"deflate");
	}
	err = deflateEnd(&stream);
	CHECK_ERR(err, @"deflateEnd");
	
	delete[] compressedBytes;
	return [compressedData autorelease];
}

//  Returns the decompressed version if the zlib compressed input data or nil if there was an error
+ (NSData*) dataByDecompressingData:(NSData*)data{
	Byte* bytes = (Byte*)[data bytes];
	NSInteger len = [data length];
	NSMutableData *decompressedData = [[NSMutableData alloc] initWithCapacity:COMPRESSION_BLOCK];
	Byte* decompressedBytes = new Byte[COMPRESSION_BLOCK];
	
	z_stream stream;
	int err;
	stream.zalloc = (alloc_func)0;
	stream.zfree = (free_func)0;
	stream.opaque = (voidpf)0;
	
	stream.next_in = bytes;	
	err = inflateInit(&stream);
	CHECK_ERR(err, @"inflateInit");
	
	while (true) {
		stream.avail_in = len - stream.total_in;
		stream.next_out = decompressedBytes;
		stream.avail_out = COMPRESSION_BLOCK;
		err = inflate(&stream, Z_NO_FLUSH);
		[decompressedData appendBytes:decompressedBytes length:(stream.total_out-[decompressedData length])];
		if(err == Z_STREAM_END)
			break;
		CHECK_ERR(err, @"inflate");
	}
	
	err = inflateEnd(&stream);
	CHECK_ERR(err, @"inflateEnd");
	
	delete[] decompressedBytes;
	return [decompressedData autorelease];
}

@end
