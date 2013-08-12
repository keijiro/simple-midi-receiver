#import "MIDIMessage.h"
#import <CoreFoundation/CoreFoundation.h>

@implementation MIDIMessage

- (id)initWithPacket:(const MIDIPacket *)packet sourceID:(MIDIUniqueID)sourceID
{
    self = [super init];
    if (self) {
        self.sourceID = sourceID;
        self.status = packet->data[0];
        self.data1 = packet->data[1];
        self.data2 = packet->data[2];
    }
    return self;
}

@end
