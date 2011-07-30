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

#import "OEGamePreferenceController.h"
#import "OEGameDocumentController.h"
#import "OEGamePreferenceController_Toolbar.h"
#import "OEPlugin.h"
#import "OECorePlugin.h"
#import "OEGameCoreController.h"

@implementation OEGamePreferenceController

@dynamic plugins;
@synthesize selectedPlugins, availablePluginsPredicate, splitView, pluginTableView, pluginController, allPluginController, toolbar;

- (id)init
{
    return [self initWithWindowNibName:@"GamePreferences"];
}

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if(self != nil)
    {
        [self setupToolbar];
        
        [OEPlugin addObserver:self forKeyPath:@"allPlugins" options:NSKeyValueObservingOptionPrior context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [OEPlugin removeObserver:self forKeyPath:@"allPlugins"];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([object isEqual:[OEPlugin class]] && [keyPath isEqualToString:@"allPlugins"])
    {
        if([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue])
            [self willChangeValueForKey:@"plugins"];
        else
            [self didChangeValueForKey:@"plugins"];
    }
}

- (IBAction)openPreferenceWindow:(id)sender
{
    [self close];
}

- (NSArray *)plugins
{
    return [OEPlugin allPlugins];
}

- (void)awakeFromNib
{
    [self switchView:self];
    //[splitView setPosition:0.0 ofDividerAtIndex:0];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    return YES;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    return NO;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return [self selectedPanelUsesPlugins] ? [pluginTableView frame].size.width : 0.0;
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
    return [self splitView:sender constrainSplitPosition:proposedMin ofSubviewAt:dividerIndex];
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
    return [self splitView:sender constrainSplitPosition:proposedMax ofSubviewAt:dividerIndex];
}

- (void)setSelectedPlugins:(NSIndexSet *)indexes
{
    NSUInteger index = [indexes firstIndex];
    
    if(indexes != nil && index < [[pluginController arrangedObjects] count] && index != NSNotFound)
    {
        currentPlugin = [[pluginController selectedObjects] objectAtIndex:0];
        selectedPlugins = [[NSIndexSet alloc] initWithIndex:index];
    }
    else
    {
        selectedPlugins = [[NSIndexSet alloc] init];
        currentPlugin = nil;
    }
    
    [self switchView:nil];
}

@end
