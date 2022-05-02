global function InitAboutGamemodeDialog

global function UI_OpenAboutGameModeDialog
global function UI_CloseAboutGameModeDialog

global function UI_AddAboutGameModeTitle
global function UI_AddAboutGameModeDetails
global function UI_ClearAboutGameMode

global function HasGameModeDetails

struct aboutGamemodeDetailsData
{
	string          title
	string		 	description
	asset			image
}

struct {
	var menu

	string title
	array< aboutGamemodeDetailsData > details

	var contentElm
	array< var > detailElms


} file


void function InitAboutGamemodeDialog( var newMenuArg )
                                              
{
	var menu = newMenuArg
	file.menu = menu

	SetPopup( menu, true )
	SetAllowControllerFooterClick( menu, true )

	AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, AboutGamemodeDialog_OnOpen )
	AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, AboutGamemodeDialog_OnClose )

	file.contentElm = Hud_GetChild( menu, "DialogContent" )
	file.detailElms = GetElementsByClassname( menu, "AboutGameModeDetails" )


	AddMenuFooterOption( menu, LEFT, BUTTON_B, true, "#B_BUTTON_CLOSE", "#B_BUTTON_CLOSE", AboutGamemodeDialog_Cancel )
}


void function AboutGamemodeDialog_OnOpen()
{
	foreach( var elm in file.detailElms )
	{
		Hud_Hide( elm )
	}

	RuiSetString( Hud_GetRui( file.contentElm ), "messageText", file.title )

	foreach( int idx, aboutGamemodeDetailsData data in file.details)
	{
		if( file.detailElms.len() > idx )                                 
		{
			Hud_Show( file.detailElms[idx] )
			var rui = Hud_GetRui( file.detailElms[idx] )

			RuiSetString(rui, "title", data.title)
			RuiSetString(rui, "desc", data.description)
			RuiSetImage(rui, "exampleImage", data.image)
		}
	}

	                                                               
	int count = int(min(file.details.len(), 4))

	int width = count * Hud_GetWidth(file.detailElms[0])
	int offsets = int(max(count - 1, 0)) * Hud_GetX(file.detailElms[1])
	Hud_SetX( file.detailElms[0], -((width / 2) + (offsets / 2)) )
}

void function AboutGamemodeDialog_OnClose()
{

}

void function UI_OpenAboutGameModeDialog()
{
	if ( !IsFullyConnected() )
		return

	if(file.details.len() == 0)
		return

	AdvanceMenu( GetMenu( "AboutGamemodeDialog" ) )
}


void function UI_CloseAboutGameModeDialog()
{
	if ( GetActiveMenu() == file.menu )
	{
		CloseActiveMenu()
	}
	else if ( MenuStack_Contains( file.menu ) )
	{
		if( IsDialog( GetActiveMenu() ) )
		{
			                                                                                                  
			CloseAllMenus()
		}
		else
		{
			                                                                                                                                                
			MenuStack_Remove( file.menu )
		}
	}
}

void function UI_AddAboutGameModeTitle( string title )
{
	file.title = title
}

void function UI_AddAboutGameModeDetails( string title = "", string description = "", asset image = $"" )
{
	aboutGamemodeDetailsData data
	data.title = title
	data.description = description
	data.image = image

	file.details.append(data)
}

void function UI_ClearAboutGameMode()
{
	printt("UI_ClearAboutGameMode")
	file.title = ""
	file.details.clear()
}

void function AboutGamemodeDialog_Cancel( var button )
{
	CloseAllToTargetMenu( file.menu )
	CloseActiveMenu()
}

bool function HasGameModeDetails()
{
	return file.details.len() > 0
}