"resource/ui/menus/panels/character_stickers.res"
{
    PanelFrame
    {
		ControlName				Label
		wide					%100
		tall					%100
		labelText				""
        bgcolor_override        "0 0 0 0"
		visible				    0
        paintbackground         1
    }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //Header
    //{
    //    ControlName             RuiPanel
    //    xpos                    163 //22
    //    ypos                    64
    //    zpos                    4
    //    wide                    550
    //    tall                    33
    //    rui                     "ui/character_items_header.rpak"
    //}

	SectionButton0
	{
		ControlName			    RuiButton
        xpos				    123
        xpos_nx_handheld	    0			[$NX || $NX_UI_PC]
        ypos				    96
        ypos_nx_handheld	    55			[$NX || $NX_UI_PC]
		zpos			        3
		wide			        296
		wide_nx_handheld        376			[$NX || $NX_UI_PC]
		tall			        56
		tall_nx_handheld        73			[$NX || $NX_UI_PC]
		visible			        0
		labelText               ""
        rui					    "ui/character_section_button.rpak"
        cursorVelocityModifier  0.7

        navDown                 SectionButton1
	}

	SectionButton1
	{
		ControlName			    RuiButton
		xpos			        0
		ypos			        3
		zpos			        3
		wide			        296
		wide_nx_handheld        376			[$NX || $NX_UI_PC]
		tall			        56
		tall_nx_handheld        73			[$NX || $NX_UI_PC]
		visible			        0
		labelText               ""
        rui					    "ui/character_section_button.rpak"
        cursorVelocityModifier  0.7

        pin_to_sibling			SectionButton0
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT

        navUp                   SectionButton0
        navDown                 SectionButton2
	}

	SectionButton2
	{
		ControlName			    RuiButton
		xpos			        0
		ypos			        3
		zpos			        3
		wide			        296
		wide_nx_handheld        376			[$NX || $NX_UI_PC]
		tall			        56
		tall_nx_handheld        73			[$NX || $NX_UI_PC]
		visible			        0
		labelText               ""
        rui					    "ui/character_section_button.rpak"
        cursorVelocityModifier  0.7

        pin_to_sibling			SectionButton1
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT

        navUp                   SectionButton1
        navDown                 SectionButton3
	}

	SectionButton3
	{
		ControlName			    RuiButton
		xpos			        0
		ypos			        3
		zpos			        3
		wide			        296
		wide_nx_handheld        376			[$NX || $NX_UI_PC]
		tall			        56
		tall_nx_handheld        73			[$NX || $NX_UI_PC]
		visible			        0
		labelText               ""
        rui					    "ui/character_section_button.rpak"
        cursorVelocityModifier  0.7

        pin_to_sibling			SectionButton2
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT

        navUp                   SectionButton2
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	StickersPanel
	{
        ControlName				CNestedPanel
        xpos					491
        xpos_nx_handheld		36			[$NX || $NX_UI_PC]
        ypos					96
        ypos_nx_handheld		0			[$NX || $NX_UI_PC]
        wide					550
		wide_nx_handheld		800			[$NX || $NX_UI_PC]
        tall					840
        visible					0
        tabPosition             1
        controlSettingsFile		"resource/ui/menus/panels/stickers.res"
        zpos                    100

        pin_to_sibling_nx_handheld			SectionButton0		[$NX || $NX_UI_PC]
        pin_corner_to_sibling_nx_handheld	TOP_LEFT			[$NX || $NX_UI_PC]
        pin_to_sibling_corner_nx_handheld	TOP_RIGHT			[$NX || $NX_UI_PC]
	}

    ModelRotateMouseCapture
    {
        ControlName				CMouseMovementCapturePanel
        xpos                    700
        ypos                    0
        wide                    1340
        tall                    %100
    }
}
