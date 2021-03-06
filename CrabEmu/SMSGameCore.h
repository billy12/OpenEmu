/*
 Copyright (c) 2009, OpenEmu Team
 
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the OpenEmu Team nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Cocoa/Cocoa.h>
#import <OEGameCore.h>
#import <OEHIDEvent.h>

typedef enum SMSButtons {
    SMSPad1Up      = 0,
    SMSPad1Down    = 1,
    SMSPad1Left    = 2,
    SMSPad1Right   = 3,
    SMSPad1A       = 4,
    SMSPad1B       = 5,
    SMSPad2Up      = 6,
    SMSPad2Down    = 7,
    SMSPad2Left    = 8,
    SMSPad2Right   = 9,
    SMSPad2A       = 10,
    SMSPad2B       = 11,
    SMSReset       = 12,
    GGStart        = 13,
    SMSButtonCount = 14
} SMSButtons;

extern NSString *SMSButtonNameTable[];

@class OERingBuffer;

@interface SMSGameCore : OEGameCore
{
    unsigned char *tempBuffer;
    NSLock        *soundLock;
    NSLock        *bufLock;
    UInt16        *sndBuf;
    int            oldrun;
    int            position;
    NSUInteger     buttons[SMSButtonCount];
    NSUInteger     keycodes[SMSButtonCount];
    BOOL           paused;
}

- (BOOL)shouldPauseForButton:(NSInteger)button;

@end
