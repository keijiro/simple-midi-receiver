#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

// MIDI message class used for storing message data and source ID.
@interface MIDIMessage : NSObject

- (id)initWithPacket:(const MIDIPacket *)packet sourceID:(MIDIUniqueID)sourceID;

@property (assign) MIDIUniqueID sourceID;
@property (assign) Byte status;
@property (assign) Byte data1;
@property (assign) Byte data2;

@end
