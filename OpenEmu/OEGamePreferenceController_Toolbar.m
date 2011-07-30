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

#import "OEGamePreferenceController_Toolbar.h"
#import "OECorePlugin.h"
#import "OESystemPlugin.h"

static NSString *OEToolbarLabelKey        = @"OEToolbarLabelKey";
static NSString *OEToolbarPaletteLabelKey = @"OEToolbarPaletteLabelKey";
static NSString *OEToolbarToolTipKey      = @"OEToolbarToolTipKey";
static NSString *OEToolbarImageKey        = @"OEToolbarImageKey";
static NSString *OEToolbarNibNameKey      = @"OEToolbarNibNameKey";
static NSString *OEPluginClassKey         = @"OEPluginClassKey";
static NSString *OEPluginViewKey          = @"OEPluginViewKey";

//static NSString *OEPreferenceToolbarIdentifier     = @"OEPreferenceToolbarIdentifier";
static NSString *OEVideoSoundToolbarItemIdentifier = @"OEVideoSoundToolbarItemIdentifier";
static NSString *OEControlsToolbarItemIdentifier   = @"OEControlsToolbarItemIdentifier";
static NSString *OEAdvancedToolbarItemIdentifier   = @"OEAdvancedToolbarItemIdentifier";
static NSString *OEPluginsToolbarItemIdentifier    = @"OEPluginsToolbarItemIdentifier";

@interface OEGamePreferenceController ()
- (NSString *)itemIdentifier;
@end


@implementation OEGamePreferenceController (Toolbar)

// ============================================================
// NSToolbar Related Methods
// ============================================================
- (void)setupToolbar
{
#define CREATE_RECORD(label, paletteLabel, toolTip, image, nib, ...) \
    [NSDictionary dictionaryWithObjectsAndKeys:                       \
     label,        OEToolbarLabelKey,                                 \
     paletteLabel, OEToolbarPaletteLabelKey,                          \
     toolTip,      OEToolbarToolTipKey,                               \
     image,        OEToolbarImageKey,                                 \
     nib,          OEToolbarNibNameKey, ##__VA_ARGS__, nil]
    
    preferencePanels = [[NSDictionary alloc] initWithObjectsAndKeys:
                        CREATE_RECORD(@"Video & Sound",
                                      @"Video & Sound",
                                      @"Video & Sound Preferences",
                                      [NSImage imageNamed:NSImageNameComputer],
                                      @"VideoAndSoundPreferences"), OEVideoSoundToolbarItemIdentifier,
                        CREATE_RECORD(@"Controls",
                                      @"Controls",
                                      @"Control Preferences",
                                      [NSImage imageNamed:NSImageNamePreferencesGeneral],
                                      @"UnavailablePlugins",
                                      [OESystemPlugin class], OEPluginClassKey,
                                      OEControlsPreferenceKey, OEPluginViewKey), OEControlsToolbarItemIdentifier,
                        CREATE_RECORD(@"Advanced",
                                      @"Advanced",
                                      @"Advanced Preferences",
                                      [NSImage imageNamed:NSImageNameAdvanced],
                                      @"UnavailablePlugins",
                                      [OECorePlugin class], OEPluginClassKey,
                                      OEAdvancedPreferenceKey, OEPluginViewKey), OEAdvancedToolbarItemIdentifier,
                        CREATE_RECORD(@"Plugins",
                                      @"Plugins",
                                      @"Plugin Preferences",
                                      [NSImage imageNamed:NSImageNameEveryone],
                                      @"PluginPreferences",
                                      [OECorePlugin class], OEPluginClassKey), OEPluginsToolbarItemIdentifier,
                        nil];
#undef CREATE_RECORD
    currentViewIdentifier = OEVideoSoundToolbarItemIdentifier;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)aToolbar
{
    static NSArray *standardItems = nil;
    if(standardItems == nil)
    {
        standardItems = [NSArray arrayWithObjects:OEVideoSoundToolbarItemIdentifier, OEControlsToolbarItemIdentifier, OEAdvancedToolbarItemIdentifier, OEPluginsToolbarItemIdentifier, nil];
    }
    
    return standardItems;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)aToolbar
{
    return [self toolbarAllowedItemIdentifiers:aToolbar];    
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)aToolbar
{
    return [self toolbarAllowedItemIdentifiers:aToolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    // Required delegate method:  Given an item identifier, this method returns an item 
    // The toolbar will use this method to obtain toolbar items that can be displayed in the customization sheet, or in the toolbar itself 
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    
    NSDictionary *desc = [preferencePanels objectForKey:itemIdentifier];
    if(desc != nil)
    {
        [toolbarItem setLabel:        [desc objectForKey:OEToolbarLabelKey]];
        [toolbarItem setPaletteLabel: [desc objectForKey:OEToolbarPaletteLabelKey]];
        [toolbarItem setToolTip:      [desc objectForKey:OEToolbarToolTipKey]];
        [toolbarItem setImage:        [desc objectForKey:OEToolbarImageKey]];
        [toolbarItem setTarget:       self];
        [toolbarItem setAction:       @selector(switchView:)];
    }
    else
    {
        toolbarItem = nil;
        /*
         // itemIdent refered to a toolbar item that is not provide or supported by us or cocoa 
         // Returning nil will inform the toolbar this kind of item is not supported 
         toolbarItem = [customIcons objectForKey:itemIdent];
         */
    }
    return toolbarItem;
}

- (NSString *)itemIdentifier
{
    return OEVideoSoundToolbarItemIdentifier;
}

- (NSRect)frameForNewContentViewFrame:(NSRect)viewFrame
{
    NSWindow *window = [self window];
    NSRect newFrameRect = [window frameRectForContentRect:viewFrame];
    NSRect oldFrameRect = [window frame];
    NSSize newSize = newFrameRect.size;
    NSSize oldSize = oldFrameRect.size;
    
    NSRect frame = [window frame];
    frame.size = newSize;
    frame.origin.y -= (newSize.height - oldSize.height);
    return frame;
}

- (BOOL)selectedPanelUsesPlugins
{
    NSDictionary *desc = [preferencePanels objectForKey: currentViewIdentifier];
    return [desc objectForKey:OEPluginViewKey] != nil;
}

- (void)switchView:(id)sender
{
#if 0
        // get the current view
        if(sender != nil)
        {
            NSView* previousView = [currentViewController view];
            
            currentViewIdentifier = [sender itemIdentifier];
            [toolbar setSelectedItemIdentifier:currentViewIdentifier];
            currentViewController = [self newViewControllerForIdentifier:currentViewIdentifier];
            
            NSView* currentView = [currentViewController view];
            if(currentView != nil && previousView != nil)
            {
                NSRect currentViewRect = [currentView frame];
                NSRect previousViewRect = [previousView frame];
                
                // setup dictionaries for our animator
                NSMutableDictionary* previousViewDict = [NSMutableDictionary dictionaryWithCapacity:4]; 
                NSMutableDictionary* currentViewDict = [NSMutableDictionary dictionaryWithCapacity:3];
                
                [currentViewDict setObject:currentView forKey:NSViewAnimationTargetKey];
                // animate from the previous rect to the new
                [currentViewDict setObject:[NSValue valueWithRect:previousViewRect] forKey:NSViewAnimationStartFrameKey];
                [currentViewDict setObject:[NSValue valueWithRect:NSZeroRect] forKey:NSViewAnimationEndFrameKey];
    
#if 0
                [previousViewDict setObject:previousView forKey:NSViewAnimationTargetKey];
                // animate from the previous rect to the new
                [previousViewDict setObject:[NSValue valueWithRect:previousViewRect] forKey:NSViewAnimationStartFrameKey];
                [previousViewDict setObject:[NSValue valueWithRect:currentViewRect] forKey:NSViewAnimationEndFrameKey];
                
                [previousViewDict setObject:NSViewAnimationFadeOutEffect forKey:NSViewAnimationEffectKey];
#endif
                NSAnimation *viewSwapAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:currentViewDict, nil]];
                [viewSwapAnimation setDuration:1.0];
                [viewSwapAnimation setAnimationCurve:NSAnimationEaseInOut];
                
                [viewSwapAnimation startAnimation];
                
                [viewSwapAnimation release];
            }
        }
#endif
    
    // // Figure out the new view, the old view, and the new size of the window
    NSViewController *previousController = currentViewController;
    if(sender != nil) currentViewIdentifier = [sender itemIdentifier];
    [toolbar setSelectedItemIdentifier:currentViewIdentifier];
    
    currentViewController = [self newViewControllerForIdentifier:currentViewIdentifier];
    
    CGFloat minimumWidth = 0.0;
    
    if([self selectedPanelUsesPlugins]) minimumWidth = [pluginTableView frame].size.width;
    
    NSView *view = [currentViewController view];
    
    NSRect contentFrame = [[currentViewController view] frame];
    
    contentFrame.size.width += minimumWidth;
    
    NSRect newFrame = [self frameForNewContentViewFrame:contentFrame];
    
    NSView *pluginSplit = [[splitView subviews] objectAtIndex:0];
    NSView *content = [[splitView subviews] objectAtIndex:1];
    
    if(previousController) [content replaceSubview:[previousController view] with:view];
    else                   [content addSubview:view];
    
    NSSize splitSize = contentFrame.size;
    splitSize.width = minimumWidth;
    
    if([pluginSplit frame].size.width == minimumWidth) pluginSplit = nil;
    
    if((int)minimumWidth == 0) 
        [pluginSplit setFrameSize:splitSize];
    
    //[[[self window] animator] setFrame:newFrame display:YES];
    [[self window] setFrame:newFrame display:YES];
    
    if((int)minimumWidth != 0) 
        //[[pluginSplit animator] setFrameSize:splitSize];
        [pluginSplit setFrameSize:splitSize];
    
    //[[splitView animator] adjustSubviews];
    
    DLog(@"minimumWidth = %f", minimumWidth);
    
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSView *view = [currentViewController view];
    NSRect viewFrame = [view frame];
    viewFrame.origin = NSZeroPoint;
    [view setFrame:viewFrame];
}

- (NSViewController *)newViewControllerForIdentifier:(NSString *)identifier
{
    NSDictionary *desc = [preferencePanels objectForKey:identifier];
    
    NSString         *pluginViewName = [desc objectForKey:OEPluginViewKey];
    Class             pluginClass    = [desc objectForKey:OEPluginClassKey];
    NSViewController *ret            = nil;
    
    if(pluginViewName != nil && pluginClass != Nil)
    {
        self.availablePluginsPredicate = [NSPredicate predicateWithFormat:@"%@ IN availablePreferenceViewControllerKeys && class == %@", pluginViewName, pluginClass];
        //[pluginDrawer open:self];
        if(currentPlugin == nil) ret = [[NSViewController alloc] initWithNibName:@"SelectPluginPreferences" bundle:[NSBundle mainBundle]];
        else ret = [[currentPlugin controller] preferenceViewControllerForKey:pluginViewName];
    }
    else if(pluginClass != Nil)
        self.availablePluginsPredicate = [NSPredicate predicateWithFormat:@"class == %@", pluginClass];
    
    if(ret == nil)
    {
        //[pluginDrawer close:self];
        NSString *viewNibName = [desc objectForKey:OEToolbarNibNameKey];
        ret = [[NSViewController alloc] initWithNibName:viewNibName bundle:[NSBundle mainBundle]];
    }
    
    // FIXME: this is bad
    //[ret loadView];
    
    return ret;
}

@end
