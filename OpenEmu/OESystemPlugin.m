/*
 Copyright (c) 2011, OpenEmu Team
 
 
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

#import "OESystemPlugin.h"
#import "OESystemController.h"

@implementation OESystemPlugin
@dynamic controller;

static NSMutableDictionary *pluginsBySystemNames = nil;

+ (void)initialize
{
    if(self == [OESystemPlugin class])
    {
        pluginsBySystemNames = [[NSMutableDictionary alloc] init];
    }
}

+ (OESystemPlugin *)gameSystemPluginForName:(NSString *)gameSystemName;
{
    return [pluginsBySystemNames objectForKey:gameSystemName];
}

+ (void)registerGameSystemPlugin:(OESystemPlugin *)plugin forName:(NSString *)gameSystemName;
{
    [pluginsBySystemNames setObject:plugin forKey:gameSystemName];
}

@synthesize responderClass, icon, gameSystemName;

+ (OESystemPlugin *)systemPluginWithBundleAtPath:(NSString *)bundlePath;
{
    return [self pluginWithBundleAtPath:bundlePath type:self];
}

- (id)initWithBundle:(NSBundle *)aBundle
{
    if((self = [super initWithBundle:aBundle]))
    {
        gameSystemName = [[self infoDictionary] objectForKey:OESystemPluginName];
        responderClass = [[self controller] responderClass];
        
        NSString *iconPath = [[self bundle] pathForResource:[[self infoDictionary] objectForKey:@"CFIconName"] ofType:@"icns"];
        
        icon = [[NSImage alloc] initWithContentsOfFile:iconPath];
        
        [[self class] registerGameSystemPlugin:self forName:gameSystemName];
    }
    return self;
}


- (id<OEPluginController>)newPluginControllerWithClass:(Class)bundleClass
{
    if(![bundleClass isSubclassOfClass:[OESystemController class]]) return nil;
    
    return [super newPluginControllerWithClass:bundleClass];
}

@end
