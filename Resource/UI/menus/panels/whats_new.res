"resource/ui/menus/panels/whats_new.res"
{
	PanelFrame
	{
		ControlName				RuiPanel
		xpos					0
		ypos					0
		wide					%100
		tall					%100
		labelText				""
	    bgcolor_override		"70 30 30 255"
		visible					0
		paintbackground			1
        rui					    "ui/lobby_button_small.rpak"
        proportionalToParent    1
	}

	CenterFrame
	{
		ControlName				RuiPanel
        xpos					0
        ypos					0
        wide					1826
		tall					%100
		labelText				""
	    bgcolor_override		"70 30 70 64"
		visible					0
		paintbackground			1
        rui					    "ui/basic_image.rpak"
        proportionalToParent    1

        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	TOP
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	InfoBox
	{
		ControlName				RuiPanel
        xpos					0
        ypos					0
		wide					500
	    tall					1080
		labelText				""
		visible					1
        rui					    "ui/whats_new_info_box.rpak"
        proportionalToParent    1
        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	LEFT
	}

	AboutButton
	{
	    ControlName			    RuiButton
	    classname               "MenuButton"

	    pin_corner_to_sibling	TOP_LEFT
	    pin_to_sibling			InfoBox
	    pin_to_sibling_corner	TOP_LEFT
	    xpos				    -48
	    ypos				    -265
	    wide				    405
	    tall				    50

	    visible                 1
	    rui					    "ui/themed_event_about_button.rpak"
	    cursorVelocityModifier  0.7
	    sound_focus             "UI_Menu_Focus_Large"
	    navDown                 Purchase1PackButton
	    navRight                OpenPackButton
        tabPosition				1
	}

	Purchase1PackButton
	{
	    ControlName			    RuiButton
	    classname               "MenuButton"

	    pin_corner_to_sibling	TOP_LEFT
	    pin_to_sibling			AboutButton
	    pin_to_sibling_corner	BOTTOM_LEFT
	    xpos				    0
	    ypos				    185
	    wide				    405
	    tall				    90

	    visible                 1
	    rui					    "ui/collection_event_buy_packs_button.rpak"
	    cursorVelocityModifier  0.7
	    sound_focus             "UI_Menu_Focus_Large"
	    navUp                   AboutButton
	    navDown                PurchaseNPacksButton
	    navRight                OpenPackButton

	}

	PurchaseNPacksButton
	{
	    ControlName			    RuiButton
	    classname               "MenuButton"

	    pin_corner_to_sibling	TOP_LEFT
	    pin_to_sibling			Purchase1PackButton
	    pin_to_sibling_corner	BOTTOM_LEFT
	    xpos				    0
	    ypos				    15
	    wide				    405
	    tall				    90

	    visible                 1
	    rui					    "ui/collection_event_buy_packs_button.rpak"
	    cursorVelocityModifier  0.7
	    sound_focus             "UI_Menu_Focus_Large"
	    navUp                   Purchase1PackButton
	    navRight                OpenPackButton
	}


    WhatsNewList
    {
        ControlName				GridButtonListPanel
        xpos                    520
        ypos                    55
        columns                 4
        rows                    4
        buttonSpacing           10
        scrollbarSpacing        16
        scrollbarOnLeft         0
        visible					1
        tabPosition             1
        bubbleNavEvents         1

        CategorySettings
		{
			rui                     "ui/gcard_badge_category.rpak"
			clipRui                 1
			wide					430
			tall					35
			enabled                 false
		}

        ButtonSettings
        {
            rui                     "ui/themed_list_button.rpak"
            clipRui                 1
            wide					100
            tall					150
            cursorVelocityModifier  0.7
            sound_focus             "UI_Menu_BattlePass_Level_Focus"
            rightClickEvents		1
			doubleClickEvents       1
            bubbleNavEvents         1
        }
    }

	Header
    {
        ControlName             RuiPanel
        xpos                    0
        ypos                    15
        zpos                    4
        wide                    550
        tall                    33
        rui                     "ui/character_items_header.rpak"
        pin_to_sibling			WhatsNewList
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
    }

    ToggleHideShowLocked
    {
        ControlName			RuiButton
        clipRui             0
        xpos                0
        ypos                10
        zpos			    10
        wide			    192
        tall			    45
        rui					"ui/gcard_show_hide_unlocked.rpak"

        pin_to_sibling			WhatsNewList
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	BOTTOM_RIGHT
    }

	ItemDetailsBox
	{
		ControlName				RuiPanel
	    xpos					-25
	    ypos					-550
		wide					400
		tall					200
	    rui					    "ui/themed_event_item_details.rpak"
		visible					1

	    pin_corner_to_sibling	TOP_RIGHT
	    pin_to_sibling			CenterFrame
	    pin_to_sibling_corner	TOP_RIGHT
	}

	OpenPackButton
   	{
   	    ControlName             RuiButton
   	    classname               "MenuButton"

   	    pin_corner_to_sibling   BOTTOM_LEFT
   	    pin_to_sibling          ItemDetailsBox
   	    pin_to_sibling_corner   BOTTOM_LEFT
   	    xpos                    -25
   	    ypos                    35
	    ypos_nx_handheld        -280  	[$NX || $NX_UI_PC]
   	    wide                    308
            wide_nx_handheld        350  	[$NX || $NX_UI_PC]
   	    tall                    88
            tall_nx_handheld        120  	[$NX || $NX_UI_PC]
   	    proportionalToParent    1

   	    visible                 1
   	    rui                     "ui/generic_loot_button.rpak"
   	    cursorVelocityModifier  0.7
   	    sound_focus             "UI_Menu_Focus_Large"
   	    sound_accept            "UI_Menu_OpenLootBox"
   	    navLeft                 AboutButton
   	}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//todo(tc): Implement the functionality. S13 Mythics
	MythicIndicatorButton0
    {
        ControlName             RuiButton

        pin_corner_to_sibling   BOTTOM_LEFT
        pin_to_sibling          ItemDetailsBox
        pin_to_sibling_corner   BOTTOM_LEFT

        xpos                    -30
        ypos                    60
        wide                    100
        tall                    100
        visible                 0
        rui                     "ui/mythic_skin_indicator.rpak"
        zpos                    100

        cursorVelocityModifier  0.7
        sound_focus             "UI_Menu_Focus_Small"
        navLeft                 AboutButton
        navRight                MythicIndicatorButton1
        navDown                 RewardButton01x01

        scriptID                0
    }

    MythicIndicatorButton1
    {
        ControlName             RuiButton

        pin_corner_to_sibling   TOP_LEFT
        pin_to_sibling          MythicIndicatorButton0
        pin_to_sibling_corner   TOP_RIGHT

        xpos                    10
        wide                    100
        tall                    100
        visible                 0
        rui                     "ui/mythic_skin_indicator.rpak"
        zpos                    100

        cursorVelocityModifier  0.7
        sound_focus             "UI_Menu_Focus_Small"
        navLeft                 MythicIndicatorButton0
        navRight                MythicIndicatorButton2
        navDown                 RewardButton01x01

        scriptID                1
    }

    MythicIndicatorButton2
    {
        ControlName             RuiButton

        pin_corner_to_sibling   TOP_LEFT
        pin_to_sibling          MythicIndicatorButton1
        pin_to_sibling_corner   TOP_RIGHT

        xpos                    10
        wide                    100
        tall                    100
        visible                 0
        rui                     "ui/mythic_skin_indicator.rpak"
        zpos                    100

        cursorVelocityModifier  0.7
        sound_focus             "UI_Menu_Focus_Small"
        navLeft                 MythicIndicatorButton1
        navDown                 RewardButton01x01

        scriptID                2
    }
}