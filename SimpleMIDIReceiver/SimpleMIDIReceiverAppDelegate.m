#import "SimpleMIDIReceiverAppDelegate.h"

#pragma mark Core MIDI callbacks

static void MyMIDIStateChangedHander(const MIDINotification *message, void *refCon)
{
    SimpleMIDIReceiverAppDelegate *delegate = (__bridge SimpleMIDIReceiverAppDelegate *)(refCon);
    
    // Only process additions and removals.
    if (message->messageID != kMIDIMsgObjectAdded && message->messageID != kMIDIMsgObjectRemoved) return;

    // Only process source operations.
    const MIDIObjectAddRemoveNotification *addRemoveDetail = (const MIDIObjectAddRemoveNotification*)message;
    if (addRemoveDetail->childType != kMIDIObjectType_Source) return;
    
    // Send update messages to the application delegate (on the main thread).
    [delegate performSelectorOnMainThread:@selector(addLogLine:) withObject:@"Changes to MIDI state were detected" waitUntilDone:NO];
    [delegate performSelectorOnMainThread:@selector(reconnectAllSources:) withObject:nil waitUntilDone:NO];
}

static void MyMIDIReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon)
{
    SimpleMIDIReceiverAppDelegate *delegate = (__bridge SimpleMIDIReceiverAppDelegate *)(readProcRefCon);
    MIDIUniqueID sourceID = *(MIDIUniqueID *)srcConnRefCon;
    
    // Process the all incoming packets.
    for (int i = 0; i < pktlist->numPackets; i++) {
        // Push this packet onto the main thread.
        MIDIMessage *message = [[MIDIMessage alloc] initWithPacket:&pktlist->packet[i] sourceID:sourceID];
        [delegate performSelectorOnMainThread:@selector(receiveMessage:) withObject:message waitUntilDone:NO];
    }
}

@implementation SimpleMIDIReceiverAppDelegate

- (void)addLogLine:(NSString *)line
{
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[line stringByAppendingString:@"\n"]];
    [self.textView.textStorage beginEditing];
    [self.textView.textStorage appendAttributedString:string];
    [self.textView.textStorage endEditing];
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.string.length, 0)];
}

- (void)receiveMessage:(MIDIMessage *)message
{
    [self addLogLine:[NSString stringWithFormat:@"(%08X) %02X %02X %02X", message.sourceID, message.status, message.data1, message.data2]];
}

- (void)reconnectAllSources:(id)arg
{
    // Dispose the old MIDI client if exists.
    if (client != (MIDIObjectRef)NULL) MIDIClientDispose(client);
    
    // Create a MIDI client.
    MIDIClientCreate(CFSTR("SimpleMIDIReceiver Client"), MyMIDIStateChangedHander, (__bridge void *)(self), &client);
    
    // Create a MIDI port which covers all MIDI sources.
    MIDIInputPortCreate(client, CFSTR("SimpleMIDIReceiver Input Port"), MyMIDIReadProc, (__bridge void *)(self), &inputPort);
    
    // Enumerate the all MIDI sources.
    ItemCount sourceCount = MIDIGetNumberOfSources();
    NSAssert(sourceCount < sizeof(idArray), @"ID buffer size is smaller than the nuber of MIDI sources.");

    for (int i = 0; i < sourceCount; i++) {
        // Connect the MIDI source to the input port.
        MIDIEndpointRef source = MIDIGetSource(i);
        MIDIObjectGetIntegerProperty(source, kMIDIPropertyUniqueID, &idArray[i]);
        MIDIPortConnectSource(inputPort, source, &idArray[i]);
        
        // Retrieve the information from the MIDI source.
        CFStringRef name;
        MIDIObjectGetStringProperty(source, kMIDIPropertyDisplayName, &name);
        [self addLogLine:[NSString stringWithFormat:@"A MIDI source was found (%08X) %@", idArray[i], name]];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self reconnectAllSources:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    MIDIClientDispose(client);
}

@end
