#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

// MIDI message class used for storing message data and source ID.
@interface MIDIMessage : NSObject

- (id)initWithSource:(MIDIUniqueID)sourceID;
- (int)readPacket:(const MIDIPacket *)packet dataOffset:(int)offset;

@property (assign) MIDIUniqueID sourceID;
@property (assign) Byte status;
@property (assign) Byte data1;
@property (assign) Byte data2;

@end
