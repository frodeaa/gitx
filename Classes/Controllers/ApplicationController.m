//
//  GitTest_AppDelegate.m
//  GitTest
//
//  Created by Pieter de Bie on 13-06-08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//

#import "ApplicationController.h"
#import "PBGitRevisionCell.h"
#import "PBGitWindowController.h"
#import "PBServicesController.h"
#import "PBGitXProtocol.h"
#import "PBPrefsWindowController.h"
#import "PBNSURLPathUserDefaultsTransfomer.h"
#import "PBGitDefaults.h"
#import "PBCloneRepositoryPanel.h"
#import "OpenRecentController.h"
#import "PBGitBinary.h"


static OpenRecentController* recentsDialog = nil;

@implementation ApplicationController

- (ApplicationController*)init
{
#ifdef DEBUG_BUILD
	[NSApp activateIgnoringOtherApps:YES];
#endif

	if(!(self = [super init]))
		return nil;

	if(![[NSBundle bundleWithPath:@"/System/Library/Frameworks/Quartz.framework/Frameworks/QuickLookUI.framework"] load])
		if(![[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/QuickLookUI.framework"] load])
			NSLog(@"Could not load QuickLook");

	/* Value Transformers */
	NSValueTransformer *transformer = [[PBNSURLPathUserDefaultsTransfomer alloc] init];
	[NSValueTransformer setValueTransformer:transformer forName:@"PBNSURLPathUserDefaultsTransfomer"];
	
	// Make sure the PBGitDefaults is initialized, by calling a random method
	[PBGitDefaults class];
	
	started = NO;
	return self;
}

- (void)registerServices
{
	// Register URL
	[NSURLProtocol registerClass:[PBGitXProtocol class]];

	// Register the service class
	PBServicesController *services = [[PBServicesController alloc] init];
	[NSApp setServicesProvider:services];

	// Force update the services menu if we have a new services version
	int serviceVersion = [[NSUserDefaults standardUserDefaults] integerForKey:@"Services Version"];
	if (serviceVersion < 2)
	{
		NSLog(@"Updating services menu…");
		NSUpdateDynamicServices();
		[[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"Services Version"];
	}
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	if(!started || [[[NSDocumentController sharedDocumentController] documents] count])
		return NO;
	return YES;
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
	recentsDialog = [[OpenRecentController alloc] init];
	if ([recentsDialog.possibleResults count] > 0)
	{
		[recentsDialog show];
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{

	// Make sure Git's SSH password requests get forwarded to our little UI tool:
	setenv( "SSH_ASKPASS", [[[NSBundle mainBundle] pathForResource: @"gitx_askpasswd" ofType: @""] UTF8String], 1 );
	setenv( "DISPLAY", "localhost:0", 1 );

	[self registerServices];
	started = YES;
}

- (void) windowWillClose: sender
{
	[firstResponder terminate: sender];
}

- (IBAction)openPreferencesWindow:(id)sender
{
	[[PBPrefsWindowController sharedPrefsWindowController] showWindow:nil];
}

- (IBAction)showAboutPanel:(id)sender
{
	NSString *gitversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleGitVersion"];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	if (gitversion)
		[dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:gitversion, @"Version", nil]];

	#ifdef DEBUG_BUILD
		[dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:@"GitX-dev (DEBUG)", @"ApplicationName", nil]];
	#endif

	[dict addEntriesFromDictionary:[[NSDictionary alloc] initWithObjectsAndKeys:@"GitX-dev (rowanj fork)", @"ApplicationName", nil]];

	[NSApp orderFrontStandardAboutPanelWithOptions:dict];
}

- (IBAction) showCloneRepository:(id)sender
{
	if (!cloneRepositoryPanel)
		cloneRepositoryPanel = [PBCloneRepositoryPanel panel];

	[cloneRepositoryPanel showWindow:self];
}

- (IBAction)installCliTool:(id)sender;
{
	BOOL success               = NO;
	NSString* installationPath = @"/usr/local/bin/";
	NSString* installationName = @"gitx";
	NSString* toolPath         = [[NSBundle mainBundle] pathForResource:@"gitx" ofType:@""];
	if (toolPath) {
		AuthorizationRef auth;
		if (AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth) == errAuthorizationSuccess) {
			char const* mkdir_arg[] = { "-p", [installationPath UTF8String], NULL};
			char const* mkdir	= "/bin/mkdir";
			AuthorizationExecuteWithPrivileges(auth, mkdir, kAuthorizationFlagDefaults, (char**)mkdir_arg, NULL);
			char const* arguments[] = { "-f", "-s", [toolPath UTF8String], [[installationPath stringByAppendingString: installationName] UTF8String],  NULL };
			char const* helperTool  = "/bin/ln";
			if (AuthorizationExecuteWithPrivileges(auth, helperTool, kAuthorizationFlagDefaults, (char**)arguments, NULL) == errAuthorizationSuccess) {
				int status;
				int pid = wait(&status);
				if (pid != -1 && WIFEXITED(status) && WEXITSTATUS(status) == 0)
					success = true;
				else
					errno = WEXITSTATUS(status);
			}

			AuthorizationFree(auth, kAuthorizationFlagDefaults);
		}
	}

	if (success) {
		[[NSAlert alertWithMessageText:@"Installation Complete"
	                    defaultButton:nil
	                  alternateButton:nil
	                      otherButton:nil
	        informativeTextWithFormat:@"The gitx tool has been installed to %@", installationPath] runModal];
	} else {
		[[NSAlert alertWithMessageText:@"Installation Failed"
	                    defaultButton:nil
	                  alternateButton:nil
	                      otherButton:nil
	        informativeTextWithFormat:@"Installation to %@ failed", installationPath] runModal];
	}
}


@end
