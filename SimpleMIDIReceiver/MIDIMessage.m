#import "MIDIMessage.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation MIDIMessage

- (id)initWithSource:(MIDIUniqueID)sourceID
{
    self = [super init];
    if (self) {
        self.sourceID = sourceID;
    }
    return self;
}

- (int)readPacket:(const MIDIPacket *)packet dataOffset:(int)offset
{
    // Status byte.
    self.status = packet->data[offset];
    
    if (++offset >= packet->length) return offset;
    
    // 1st data byte.
    Byte data = packet->data[offset];
    if (data & 0x80) return offset;
    self.data1 = data;
    
    if (++offset >= packet->length) return offset;
    
    // 2nd data byte.
    data = packet->data[offset];
    if (data & 0x80) return offset;
    self.data2 = data;
    
    // Simply dispose the reset of the data.
    while (++offset < packet->length && packet->data[offset] < 0x80){}
    
    return offset;
}

@end
