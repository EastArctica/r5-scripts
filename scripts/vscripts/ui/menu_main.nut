global function InitMainMenu
global function LaunchMP
global function AttemptLaunch
global function GetUserSignInState
global function UpdateSignedInState
global function SetLaunchingState
global function GetLaunchingState
global function CanAutoRetryConnect
global function EnableAutoRetryConnect

struct
{
	var menu
	var titleArt
	var versionDisplay
	var signedInDisplay
	bool canAutoRetryConnect = true
	#if PLAYSTATION_PROG
		bool chatRestrictionNoticeJustHandled = false
	#endif                    
	#if NX_PROG
		var LangAOCNeeded
	#endif
	int launching = eLaunching.FALSE
} file


void function InitMainMenu( var newMenuArg )                                               
{
	var menu = GetMenu( "MainMenu" )
	file.menu = menu

	SetGamepadCursorEnabled( menu, false )

	AddMenuEventHandler( menu, eUIEvent.MENU_SHOW, OnMainMenu_Show )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, OnMainMenu_Close )
	AddMenuEventHandler( menu, eUIEvent.MENU_NAVIGATE_BACK, OnMainMenu_NavigateBack )

	file.titleArt = Hud_GetChild( file.menu, "TitleArt" )
	var titleArtRui = Hud_GetRui( file.titleArt )
	RuiSetImage( titleArtRui, "basicImage", $"ui/menu/title_screen/title_art" )

	var subtitleRui = Hud_GetRui( Hud_GetChild( file.menu, "Subtitle" ) )
	RuiSetString( subtitleRui, "subtitleText", Localize( "#BP_S12_NAME").toupper() )

	file.versionDisplay = Hud_GetChild( menu, "VersionDisplay" )
	file.signedInDisplay = Hud_GetChild( menu, "SignInDisplay" )
	
	#if NX_PROG
		file.LangAOCNeeded = GetConVarInt( "AoCLanguageNeeded" )
	#endif

	file.canAutoRetryConnect = true
}


void function OnMainMenu_Show()
{
	                             
	                                        
	float aspectRatio = 2.4             
	int width = int( Hud_GetHeight( file.titleArt ) * aspectRatio )
	Hud_SetWidth( file.titleArt, width )

	Hud_SetText( file.versionDisplay, GetPublicGameVersion() )
	Hud_Show( file.versionDisplay )

	ActivatePanel( GetPanel( "MainMenuPanel" ) )

	Chroma_MainMenu()
	
	#if NX_PROG
		if ( file.LangAOCNeeded > 0 )
		{
			if ( GetActiveMenu() == GetMenu( "EULADialog" ) )
				return
			
			OpenLangAoCDialog(false)
		}
	#endif

	SetMenuNavigationDisabled( true )
}


void function OnMainMenu_Close()
{
	HidePanel( GetPanel( "MainMenuPanel" ) )
	SetMenuNavigationDisabled( false )
}


void function ActivatePanel( var panel )
{
	Assert( panel != null )

	array<var> elems = GetElementsByClassname( file.menu, "MainMenuPanelClass" )
	foreach ( elem in elems )
	{
		if ( elem != panel && Hud_IsVisible( elem ) )
			HidePanel( elem )
	}

	ShowPanel( panel )
}


void function OnMainMenu_NavigateBack()
{
	if ( IsSearchingForPartyServer() )
	{
		StopSearchForPartyServer( "", Localize( "#MAINMENU_CONTINUE" ) )
		return
	}

	#if PC_PROG
		OpenConfirmExitToDesktopDialog()
	#endif           
}


int function GetUserSignInState()
{
	#if DURANGO_PROG
		if ( Durango_InErrorScreen() )
		{
			return userSignInState.ERROR
		}
		else if ( Durango_IsSigningIn() )
		{
			return userSignInState.SIGNING_IN
		}
		else if ( !Console_IsSignedIn() && !Console_SkippedSignIn() )
		{
			                                                                                                            
			return userSignInState.SIGNED_OUT
		}

		Assert( Console_IsSignedIn() || Console_SkippedSignIn() )
	#endif
	return userSignInState.SIGNED_IN
}


void function UpdateSignedInState()
{	
	#if XBOX_PROG
		if ( Console_IsSignedIn() )
		{		
			Hud_SetText( file.signedInDisplay, Localize( "#SIGNED_IN_AS_N", Xbox_GetGameDisplayName() ) )
			return
		}
	#endif
	Hud_SetText( file.signedInDisplay, "" )
}


void function SetLaunchingState( int val )
{
	file.launching = val
}


int function GetLaunchingState()
{
	return file.launching
}


void function LaunchMP()
{
	SetLaunchingState( eLaunching.MULTIPLAYER )
	AttemptLaunch()
}


void function AttemptLaunch()
{
	int launching = GetLaunchingState()
	if ( launching == eLaunching.FALSE )
		return

	Assert( launching == eLaunching.MULTIPLAYER || launching == eLaunching.MULTIPLAYER_INVITE )

	#if CONSOLE_PROG
		if ( !IsEULAAccepted() )
		{
			if ( GetActiveMenu() == GetMenu( "EULADialog" ) )
				return

			if ( IsDialog( GetActiveMenu() ) )
				CloseActiveMenu()

			if ( GetUserSignInState() != userSignInState.SIGNED_IN )
				return

			var mmp = GetPanel( "MainMenuPanel" )
            var launchButton = Hud_GetChild( mmp, "LaunchButton" )
			OpenEULADialog( false, null, launchButton )

			return
		}
	#endif                

	#if PLAYSTATION_PROG
		                                                      
		                                                                                                                                       
		if ( !file.chatRestrictionNoticeJustHandled )
		{
			thread PS4_ChatRestrictionNotice()
			return
		}
	#endif                    

	const int CURRENT_INTRO_VIDEO_VERSION = 12
	if ( (GetIntroViewedVersion() < CURRENT_INTRO_VIDEO_VERSION) || (InputIsButtonDown( KEY_LSHIFT ) && InputIsButtonDown( KEY_LCONTROL ))  || (InputIsButtonDown( BUTTON_TRIGGER_LEFT_FULL ) && InputIsButtonDown( BUTTON_TRIGGER_RIGHT_FULL )) )
	{
		if ( GetActiveMenu() == GetMenu( "PlayVideoMenu" ) )
			return

		if ( IsDialog( GetActiveMenu() ) )
			CloseActiveMenu()

		SetIntroViewedVersion( CURRENT_INTRO_VIDEO_VERSION )

	#if NX_PROG
		string videoName = "intro_720p"
	#else
		string videoName = "intro"
	#endif
		PlayVideoMenu( true, videoName, "Apex_Opening_Movie", eVideoSkipRule.HOLD, PrelaunchValidateAndLaunch )
		return
	}

	if ( CanAutoRetryConnect() && TryLoadReconnectFromLocalStorage() )
	{
		file.canAutoRetryConnect = false
		thread DelayedReconnect()
	}
	else
	{
		StartSearchForPartyServer()
	}

	SetLaunchingState( eLaunching.FALSE )

	#if PLAYSTATION_PROG
		file.chatRestrictionNoticeJustHandled = false
	#endif                    
}

void function EnableAutoRetryConnect()
{
	file.canAutoRetryConnect = true
}

bool function CanAutoRetryConnect()
{
	return file.canAutoRetryConnect
}

void function DelayedReconnect()
{
	float delay = GetReconnectDelay()
	printt( FUNC_NAME(), delay )

	Wait( delay )

	if ( Reconnect_IsLiveSpectateLoaded() )
		EmitUISound( "diag_mp_crypto_bc_droneviewstart_calm_1p" )

	StartReconnectFromParameters()
}

#if PLAYSTATION_PROG
void function PS4_ChatRestrictionNotice()
{
	Plat_ShowChatRestrictionNotice()
	while ( Plat_IsSystemMessageDialogOpen() )
		WaitFrame()

	file.chatRestrictionNoticeJustHandled = true
	PrelaunchValidateAndLaunch()
}
#endif                    
