//
//  JournlerApplicationDelegate.h
//  Journler
//
//  Created by Philip Dow on 10/24/06.
//  Copyright 2006 Sprouted, Philip Dow. All rights reserved.
//

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

#import <Cocoa/Cocoa.h>
#import <Sparkle/Sparkle.h>
#import <Pantomime/Pantomime.h>
//#import <iMediaBrowser/iMedia.h>

#import "JournlerJournal.h"
#import "JournlerResource.h"

@class JournlerJournal;
@class JournlerEntry;
@class JournlerCollection;
@class JournlerResource;
@class BlogPref;

@class JournlerWindowController;
@class JournalWindowController;
@class LockoutController;

@class JournlerKQueue;

extern NSString *JournlerDidFinishImportNotification;

@interface JournlerApplicationDelegate : NSObject {
	
	IBOutlet NSMenu *labelMenu;
	IBOutlet NSMenu *highlightMenu;
	IBOutlet NSMenu	*scriptsMenu;
	IBOutlet NSMenu *findMenu;
	IBOutlet NSMenuItem *biggerItem;
	IBOutlet NSMenuItem *smallerItem;
	
	IBOutlet NSMenuItem *shortcutsMenuItem;
	
	BOOL lockout;
	BOOL wasFirstRun;
	BOOL displayInverted;
	BOOL dropBoxIsWaiting;
	NSInteger spellDocumentTag;
	
	JournalLoadFlag journalLoadResult;
	JournlerJournal *sharedJournal;
	JournalWindowController *journalWindowController;
	
	NSDictionary *autoCorrectWordList;
	NSSpeechRecognizer *speechRecognizer;
	
	NSArray *filesToOpenAtLaunch;
	NSMutableArray *entriesToShowAtLaunch;
	NSString *waitingDropBoxPaths;
	
	LockoutController *lockoutController;
	JournlerWindowController *mainWindowIgnoringActive;
	
	NSTimer *autosaveTimer;
	
	BOOL dropBoxing;
	JournlerKQueue	*dropBoxWatcher;
	
	NSArray *labelImages;
	NSArray *highlightImages;
}

- (JournlerJournal*) journal;
- (NSInteger) spellDocumentTag;
- (BOOL) dropBoxing;
- (JournalWindowController*) journalWindowController;

- (JournlerWindowController*) mainWindowIgnoringActive;
- (void) setMainWindowIgnoringActive:(JournlerWindowController*)aWindowController;

- (NSDictionary*) autoCorrectWordList;
- (void) setAutoCorrectWordList:(NSDictionary*)aDictionary;

- (IBAction) save:(id)sender;
- (IBAction) saveJournal:(id)sender;
- (void) performAutosave:(NSTimer*)aTimer;

- (void) dayDidChange:(NSTimer*)aTimer;
- (void) computerDidWake:(NSNotification*)aNotification;
- (void) regenerateDynamicDatePredicates;

- (JournalLoadFlag) loadJournal;
- (BOOL) handleSetup:(NSString*)path;

- (BOOL) openFile:(NSString*)filename;
- (JournlerEntry*) importFile:(NSString*)filename;
- (JournlerEntry*) importFile:(NSString*)filename operation:(NewResourceCommand)operation;

- (IBAction) runFileImporter:(id)sender;
- (BOOL) importFilesWithImporter:(NSArray*)filenames folder:(JournlerCollection*)targetFolder userInteraction:(BOOL)visual;

- (IBAction) showJournal:(id)sender;
- (IBAction) showContactsBrowser:(id)sender;
- (IBAction) showMediaBrowser:(id)sender;
- (IBAction) showCorrespondenceBrowser:(id)sender;
- (IBAction) showEntryBrowser:(id)sender;
- (IBAction) showPreferences:(id)sender;
- (IBAction) showAboutBox:(id)sender;
- (IBAction) donate:(id)sender;

- (IBAction) showTermIndex:(id)sender;

- (IBAction) showPlugInHelp:(id)sender;
- (IBAction) showKeyboardShortcuts:(id)sender;
- (IBAction) reportBug:(id)sender;
- (IBAction) gotoWiki:(id)sender;
- (IBAction) gotoHelpForum:(id)sender;

- (IBAction) toggleContinuousSpellcheckingAppwide:(id)sender;
- (IBAction) toggleSpeakableItems:(id)sender;
- (IBAction) toggleLowLightDisplay:(id)sender;
- (IBAction) lockJournal:(id)sender;

- (IBAction) recordAudio:(id)sender;
- (IBAction) recordVideo:(id)sender;
- (IBAction) captureSnapshot:(id)sender;

- (IBAction) doPageSetup:(id)sender;
- (IBAction) performQuit:(id)sender;

- (IBAction) printJournal:(id)sender;
- (IBAction) exportJournal:(id)sender;

- (IBAction) toggleAutoCorrectSpelling:(id)sender;

- (NSArray*) entriesForPasteboardData:(NSPasteboard*)pboard visual:(BOOL)showDialog preferredTypes:(NSArray*)types;
- (NSArray*) _mailMessagePathsFromPasteboard:(NSPasteboard*)pboard;
- (void) serviceSelection:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;

- (void) prepareLabelMenu:(NSMenu**)aMenu;
- (void) prepareHighlightMenu:(NSMenu**)aMenu;
- (NSDictionary*) autoCorrectDictionaryForFileAtPath:(NSString*)filename;

- (void) prepareScriptsMenu:(NSMenu**)aMenu;
- (IBAction) runScript:(id)sender;
- (IBAction) aboutScripts:(id)sender;

- (void) runAppleScript:(NSAppleScript*)appleScript showErrors:(BOOL)withErrors;
- (void) runAppleScriptAtPath:(NSString*)path showErrors:(BOOL)withErrors;

- (BOOL) installPDFService;
- (BOOL) installScriptMenu;
- (BOOL) installContextualMenu;
- (BOOL) installDropBoxService;

- (IBAction) runConsole:(id)sender;
- (IBAction) showActivity:(id)sender;

- (BOOL) _importContentsOfDropBox:(NSString*)path visually:(BOOL)showDialog filesAffected:(NSInteger*)newEntryCount;
- (void) cleanupDropBox:(NSString*)path;

- (void) fadeOutAllWindows:(NSArray*)excluding;
- (void) fadeInAllWindows:(NSArray*)excluding;

- (NSString *) applicationSupportFolder;
- (NSString*) documentsFolder;
- (NSString*) libraryFolder;

@end


@interface JournlerApplicationDelegate (ApplicationUtilities)

+ (NSMenu*) menuForFolder:(NSString*)path menuTarget:(id)target targetSelector:(SEL)selector;
+ (BOOL) sendRichMail:(NSAttributedString *)richBody to:(NSString *)to subject:(NSString *)subject isMIME:(BOOL)isMIME withNSMail:(BOOL)wM;

@end

/*
@interface JournlerApplicationDelegate (FindPanelSupport)

- (IBAction) performCustomFindPanelAction:(id)sender;
- (void) setFindPanelPerformsCustomAction:(NSNumber*)perfomCustomAction;

- (IBAction) performCustomTextSizeAction:(id)sender;
- (void) setTextSizePerformsCustomAction:(NSNumber*)performCustomAction;

@end
*/

@interface JournlerApplicationDelegate (JournlerScripting)

- (BOOL)application:(NSApplication *)sender delegateHandlesKey:(NSString *)key;

- (NSWindow*) JSJournalViewer;

- (NSDate*) scriptSelectedDate;
- (void) setScriptSelectedDate:(NSDate*)aDate;

- (NSArray*) scriptSelectedFolders;
- (void) setScriptSelectedFolders:(NSArray*)anArray;

- (NSArray*) scriptSelectedEntries;
- (void) setScriptSelectedEntries:(NSArray*)anArray;

- (NSArray*) scriptSelectedResources;
- (void) setScriptSelectedResources:(NSArray*)anArray;

#pragma mark -

- (NSInteger) indexOfObjectInJSEntries:(JournlerEntry*)anEntry;
- (NSUInteger) countOfJSEntries;
- (JournlerEntry*) objectInJSEntriesAtIndex:(NSUInteger)i;
- (JournlerEntry*) valueInJSEntriesWithUniqueID:(NSNumber*)idNum;

- (void) insertObject:(JournlerEntry*)anEntry inJSEntriesAtIndex:(NSUInteger)index;
- (void) insertInJSEntries:(JournlerEntry*)anEntry;
- (void) JSAddNewEntry:(JournlerEntry*)anEntry atIndex:(NSUInteger)index;

- (void) removeObjectFromJSEntriesAtIndex:(NSUInteger)index; 
- (void) removeFromSJSEntriesAtIndex:(NSUInteger)index;
- (void) JSDeleteEntry:(JournlerEntry*)anEntry;

#pragma mark -

- (NSInteger) indexOfObjectInJSFolders:(JournlerCollection*)aFolder;
- (NSUInteger) countOfJSFolders;
- (JournlerCollection*) objectInJSFoldersAtIndex:(NSUInteger)i;
- (JournlerCollection*) valueInJSFoldersWithUniqueID:(NSNumber*)idNum;

- (void) insertObject:(JournlerCollection*)aFolders inJSFoldersAtIndex:(NSUInteger)index;
- (void) insertInJSFolders:(JournlerCollection*)aFolder;
- (void) JSAddNewFolder:(JournlerCollection*)aFolder atIndex:(NSUInteger)index;

- (void) removeObjectFromJSFoldersAtIndex:(NSUInteger)index;
- (void) removeFromJSFoldersAtIndex:(NSUInteger)index;
- (void) JSDeleteFolder:(JournlerCollection*)aFolder;

#pragma mark -

- (NSInteger) indexOfObjectInJSReferences:(JournlerResource*)aReference;
- (NSUInteger) countOfJSReferences;
- (JournlerResource*) objectInJSReferencesAtIndex:(NSUInteger)i;
- (JournlerResource*) valueInJSReferencesWithUniqueID:(NSNumber*)idNum;

- (void) insertObject:(JournlerResource*)aReference inJSReferencesAtIndex:(NSUInteger)index;
- (void) insertInJSReferences:(JournlerResource*)aReference;
- (void) JSAddNewReference:(JournlerResource*)aReference atIndex:(NSUInteger)index;

- (void) removeObjectFromJSReferencesAtIndex:(NSUInteger)index;
- (void) removeFromJSReferencesAtIndex:(NSUInteger)index;
- (void) JSDeleteReference:(JournlerResource*)aResource;

#pragma mark -

- (NSInteger) indexOfObjectInJSBlogs:(BlogPref*)aBlog;
- (NSUInteger) countOfJSBlogs;
- (BlogPref*) objectInJSBlogsAtIndex:(NSUInteger)i;
- (BlogPref*) valueInJSBlogsWithUniqueID:(NSNumber*)idNum;

- (void) insertObject:(BlogPref*)aBlog inJSBlogsAtIndex:(NSUInteger)index;
- (void) insertInJSBlogs:(BlogPref*)aBlog;
- (void) JSAddNewBlog:(BlogPref*)aBlog atIndex:(NSUInteger)index;

- (void) removeObjectFromJSBlogsAtIndex:(NSUInteger)index;
- (void) removeFromJSBlogsAtIndex:(NSUInteger)index;
- (void) JSDeleteBlog:(BlogPref*)aBlog;

@end

#pragma mark -

@interface JournlerScriptingImportCommand : NSScriptCommand

@end

@interface JourlerScriptingMakeCommand : NSCreateCommand

@end

@interface JournlerScriptingSaveChangesCommand : NSScriptCommand

@end

@interface JournlerScriptingHighlightCommand : NSScriptCommand

@end

@interface JournlerScriptingFindInJournal : NSScriptCommand

@end

@interface JournlerDropBoxCommand : NSScriptCommand

@end