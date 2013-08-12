#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>
#import "MIDIMessage.h"

// Application delegate class.
@interface SimpleMIDIReceiverAppDelegate : NSObject <NSApplicationDelegate>
{
    // Core MIDI objects.
    MIDIClientRef client;
    MIDIPortRef inputPort;
    // Unique ID array used for storing MIDI source IDs.
    MIDIUniqueID idArray[256];
}

- (void)reconnectAllSources:(id)arg;
- (void)receiveMessage:(MIDIMessage *)message;
- (void)addLogLine:(NSString *)line;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextView *textView;

@end
