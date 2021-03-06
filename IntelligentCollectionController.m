
/*
 Redistribution and use in source and binary forms, with or without modification, are permitted
 provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions
 and the following disclaimer in the documentation and/or other materials provided with the
 distribution.
 
 * Neither the name of the author nor the names of its contributors may be used to endorse or
 promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Basically, you can use the code in your free, commercial, private and public projects
// as long as you include the above notice and attribute the code to Philip Dow / Sprouted
// If you use this code in an app send me a note. I'd love to know how the code is used.

// Please also note that this copyright does not supersede any other copyrights applicable to
// open source code used herein. While explicit credit has been given in the Journler about box,
// it may be lacking in some instances in the source code. I will remedy this in future commits,
// and if you notice any please point them out.

#import "IntelligentCollectionController.h"
#import "JournlerConditionController.h"

#import "NSAlert+JournlerAdditions.h"

#import "Definitions.h"

@implementation IntelligentCollectionController

- (id)init 
{
	//NSLog(@"%s - beginning", __PRETTY_FUNCTION__);
	
	if ( self = [self initWithWindowNibName:@"IntelligentCollection"] ) 
	{
		//NSLog(@"if ( self = [self initWithWindowNibName:@\"IntelligentCollection\"] ) - beginning ");
		
		//NSLog(@"[self window]");
		[self window];

		conditions = [[NSMutableArray alloc] init];
		
		// add a single condition to our view
		
		//NSLog(@"[[JournlerConditionController alloc] initWithTarget:self]");
		JournlerConditionController *initialCondition = [[JournlerConditionController alloc] initWithTarget:self];
		
		[initialCondition setSendsLiveUpdate:YES];
		[initialCondition setRemoveButtonEnabled:NO];
		[initialCondition setAllowsEmptyCondition:YES];
		[conditions addObject:initialCondition];
		
		// clean up up - okay because the array now has ownership of this guy
		[initialCondition release];
		
		//NSLog(@"if ( self = [self initWithWindowNibName:@\"IntelligentCollection\"] ) - ending ");
    }
	
	//NSLog(@"%s - ending", __PRETTY_FUNCTION__);
    return self;
}

- (void) windowDidLoad 
{
	[containerView setBordered:NO];
	
	// we automatically calculate our keyloop
	[[self window] setAutorecalculatesKeyViewLoop:NO];
}

- (void) dealloc 
{
	[conditions release];
	[_predicates release];
	[_combinationStyle release];
	[_folderTitle release];
	[tagCompletions release];
	
	[super dealloc];
}

- (void)windowWillClose:(NSNotification *)aNotification {
	
}

#pragma mark -
#pragma mark Predicates

- (void) setInitialConditions:(NSArray*)initialConditions {
	
	NSInteger i;
	NSRect contentRect;
	
	// size our window to the appropriate height
	contentRect = [[[self window] contentView] frame];
	
	NSInteger newHeight = contentRect.size.height 
			+ ( kConditionViewHeight * ([initialConditions count]-1));
	contentRect.size.height = newHeight;
	
	NSRect newFrame = [[self window] frameRectForContentRect:contentRect];
	[[self window] setFrame:newFrame display:NO];

	
	// create one less than delivered taking into account the initial condition that is visible
	for ( i = 0; i < [initialConditions count]-1; i++ )
		[self addCondition:self];
	
	// update these guys
	for ( i = 0; i < [conditions count]; i++ )
		[[conditions objectAtIndex:i] setInitialCondition:[initialConditions objectAtIndex:i]];
	
}

- (NSArray*) conditions { return _predicates; }

- (void) setConditions:(NSArray*)predvalues {
	if ( _predicates != predvalues ) {
		[_predicates release];
		_predicates = [predvalues copyWithZone:[self zone]];
	}
}

#pragma mark -
#pragma mark Combination Style

- (void) setInitialCombinationStyle:(NSNumber*)style {
	[combinationPop selectItemWithTag:[style integerValue]];
}

- (NSNumber*) combinationStyle { return _combinationStyle; }

- (void) setCombinationStyle:(NSNumber*)style {
	if ( _combinationStyle != style ) {
		[_combinationStyle release];
		_combinationStyle = [style copyWithZone:[self zone]];
	}
}

#pragma mark -
#pragma mark Title

- (void) setInitialFolderTitle:(NSString*)title {
	[folderName setStringValue:title];
}

- (NSString*) folderTitle { return _folderTitle; }

- (void) setFolderTitle:(NSString*)title {
	if ( _folderTitle != title ) {
		[_folderTitle release];
		_folderTitle = [title copyWithZone:[self zone]];
	}
}

- (NSArray*) tagCompletions
{
	return tagCompletions;
}

- (void) setTagCompletions:(NSArray*)anArray
{
	if ( tagCompletions != anArray )
	{
		[tagCompletions release];
		tagCompletions = [anArray copyWithZone:[self zone]];
	}
}

#pragma mark -
#pragma mark Other Methods

- (BOOL) cancelledChanges { return cancelledChanges; }

- (void) setCancelledChanges:(BOOL)didCancel {
	cancelledChanges = didCancel;
}

#pragma mark -
#pragma mark JournlerConditionController Delegate (NSTokenField)

- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring 
	indexOfToken:(NSInteger )tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex
{
	//NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self beginswith[cd] %@", substring];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self beginswith %@", substring];
	NSArray *completions = [[self tagCompletions] filteredArrayUsingPredicate:predicate];
	return completions;
}

#pragma mark -

- (IBAction)cancelFolder:(id)sender
{
	[self setCancelledChanges:YES];
	[NSApp abortModal];
}

- (IBAction)createFolder:(id)sender
{
	
	NSInteger i;
	BOOL valid = YES;
	
	//
	// check the available conditions
	for ( i = 0; i < [conditions count]; i++ ) {
		NSString *aPredicateString = [[conditions objectAtIndex:i] predicateString];
		if ( aPredicateString == nil ) { valid = NO; break; }
	}
	
	//
	// check to make sure that string prodcues a valid predicate
	if ( !valid ) {
		NSBeep();
		[[NSAlert badConditions] runModal];
		return;
		
	}
	
	[self setCancelledChanges:NO];
	[NSApp stopModal];
}

#pragma mark -

- (NSInteger) runAsSheetForWindow:(NSWindow*)window attached:(BOOL)sheet {
	
	NSInteger result;
	
	[self updateConditionsView];
	
	if ( sheet )
		[NSApp beginSheet: [self window] modalForWindow: window modalDelegate: nil
				didEndSelector: nil contextInfo: nil];
				
    result = [NSApp runModalForWindow: [self window]];
    
	// calculate the predicates
	
	NSInteger i;
	NSMutableArray *allPredicates = [[NSMutableArray alloc] init];
	
	for ( i = 0; i < [conditions count]; i++ ) 
	{
		NSString *aPredicateString = [[conditions objectAtIndex:i] predicateString];
		if ( aPredicateString != nil )
			[allPredicates addObject:aPredicateString];
	}
	
	// set internal copy of the values
	
	[self setConditions:[allPredicates autorelease]];
	[self setFolderTitle:[folderName stringValue]];
	[self setCombinationStyle:[NSNumber numberWithInteger:[[combinationPop selectedItem] tag]]];
	
	if ( sheet )
		[NSApp endSheet: [self window]];
		
    [self close];
	return result;
}

- (void) updateConditionsView 
{
	// updates the ui display and recalculates the key view loop
	
	// for manually building the loop
	id lastInResponderLoop = folderName;
	
	// save our responder so we don't lose track of it
	NSResponder *theResponder = [[self window] firstResponder];
	
	NSInteger i;
	
	// make sure the predicates view knows how many rows to draw
	[predicatesView setNumConditions:[conditions count]];
	
	// remove all the subview
	for ( i = 0; i < [[predicatesView subviews] count]; i++ )
		[[[predicatesView subviews] objectAtIndex:i] removeFromSuperviewWithoutNeedingDisplay];
	
	// and add what's left or more according to our internal array
	for ( i = 0; i < [conditions count]; i++ ) {
		
		JournlerConditionController *aCondition = [conditions objectAtIndex:i];
		
		// reset the tag on each of these guys
		[aCondition setTag:i];
		
		// add the condition's view to our predicates view and position it
		[predicatesView addSubview:[aCondition conditionView]];
		[[aCondition conditionView] setFrameOrigin:NSMakePoint(0,(i*kConditionViewHeight))];
		
		if ( [aCondition selectableView] != nil ) {
			//
			// insert this to the responder chain
			[lastInResponderLoop setNextKeyView:[aCondition selectableView]];
			lastInResponderLoop = [aCondition selectableView];
		}
		
	}
	
	// make sure the predicates view knows to redraw itself, love those alternating rows
	[predicatesView setNeedsDisplay:YES];
	
	//
	// close the repsonder loop
	[lastInResponderLoop setNextKeyView:folderName];
	
	// is it okay to call this even if our responder is going away?
	[[self window] makeFirstResponder:theResponder];
	
}

- (void) updateKeyViewLoop
{
	// for manually recalculating the keyview loop
	id lastInResponderLoop = folderName;
	
	// save our responder so we don't lose track of it
	NSResponder *theResponder = [[self window] firstResponder];

	NSInteger i;
	// and add what's left or more according to our internal array
	for ( i = 0; i < [conditions count]; i++ ) 
	{
		JournlerConditionController *aCondition = [conditions objectAtIndex:i];
		if ( [aCondition selectableView] != nil ) {
			// insert this to the responder chain
			[lastInResponderLoop setNextKeyView:[aCondition selectableView]];
			lastInResponderLoop = [aCondition selectableView];
		}
	}
	
	// close the repsonder loop
	[lastInResponderLoop setNextKeyView:folderName];
	
	// is it okay to call this even if our responder is going away?
	[[self window] makeFirstResponder:theResponder];
}

- (void) conditionDidChange:(id)condition 
{
	[self updateKeyViewLoop];
}

#pragma mark -

- (void) addCondition:(id)sender {
	
	//
	// resize the window positive by our condition view height
	// and add a new condition to our view
	//
	
	// add a new condition to our view
	JournlerConditionController *aCondition = [[JournlerConditionController alloc] initWithTarget:self];
	[aCondition setSendsLiveUpdate:YES];
	[aCondition setAllowsEmptyCondition:YES];
	
	if ( sender == self )
		[conditions addObject:aCondition];
	else
		[conditions insertObject:aCondition atIndex:[sender tag]+1];

	// clean up - okay because the array now has ownership of this guy
	[aCondition release];

	// update our display
	[self updateConditionsView];
	
	// and resize
	if ( sender != self ) {
	
		//NSInteger newHeight = [[self window] frame].size.height + kConditionViewHeight;

		NSRect contentRect = [[self window] contentRectForFrameRect:[[self window] frame]];
		
		NSInteger newHeight = contentRect.size.height + kConditionViewHeight;
		
		contentRect.origin.y = contentRect.origin.y + contentRect.size.height - newHeight;
		contentRect.size.height = newHeight;
		NSRect newFrame = [[self window] frameRectForContentRect:contentRect];
		[[self window] setFrame:newFrame display:YES animate:YES];
	
	}
	
}

- (void) removeCondition:(id)sender {
	
	//
	// resize the window negative by our condition view height
	// and remove the condition at the index of this tag
	//
	
	// get rid of the subview first
	[[[conditions objectAtIndex:[sender tag]] conditionView] removeFromSuperviewWithoutNeedingDisplay];
	
	// and the condition second
	[conditions removeObjectAtIndex:[sender tag]];
	
	// update the conditions view, this subview already removed
	[self updateConditionsView];
	
	// resize the window and the conditions view with it
	//NSInteger newHeight = [[self window] frame].size.height - kConditionViewHeight;

	NSRect contentRect = [[self window] contentRectForFrameRect:[[self window] frame]];
	
	NSInteger newHeight = contentRect.size.height - kConditionViewHeight;
	
	contentRect.origin.y = contentRect.origin.y + contentRect.size.height - newHeight;
	contentRect.size.height = newHeight;
	NSRect newFrame = [[self window] frameRectForContentRect:contentRect];
	[[self window] setFrame:newFrame display:YES animate:YES];
}

#pragma mark -

- (IBAction) showFoldersHelp:(id)senderp {
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"SmartFolders" inBook:@"JournlerHelp"];
}

@end
