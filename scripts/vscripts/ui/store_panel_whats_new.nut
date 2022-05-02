global function WhatsNewPanel_Init

#if UI
struct {
	var				panel
	var				headerRui
	var				listPanel
	var 			aboutButton
	var 			openPackButton
	var 			infoBox
	var 			itemDetailsBox
	var 			purchaseSinglePackButton
	var 			purchaseMultiplePacksButton
	bool			hideUnlocked

	array<int>		itemCategoryIndices
	table<int,int>  itemCategoryCount
	table<int,int>  itemCategoryUnlockCount


	ItemFlavor ornull activeItem
	table<var, ItemFlavor> activeItemButtons = {}
	bool isXButtonRegistered
	bool isUnlockOperationActive
	array<ItemFlavor> whatsNewList
	string associatedPackName
	string itemSourceIcon

	int purchaseMultiplePacksButton_currentQty = -1
	int numOwnedItems
} file

table< int, string > previewSoundMap = {
	[eItemType.character_skin] 				= "UI_Menu_LegendSkin_Preview",
	[eItemType.character_execution] 		= "UI_Menu_Finisher_Preview",
	[eItemType.gladiator_card_frame] 		= "UI_Menu_Banner_Preview",
	[eItemType.gladiator_card_stance] 		= "UI_Menu_Banner_Preview",
	[eItemType.gladiator_card_badge] 		= "UI_Menu_Banner_Preview",
	[eItemType.gladiator_card_stat_tracker] = "UI_Menu_Banner_Preview",
	[eItemType.gladiator_card_intro_quip] 	= "UI_Menu_Quip_Preview",
	[eItemType.gladiator_card_kill_quip] 	= "UI_Menu_Quip_Preview",
	[eItemType.weapon_skin] 				= "UI_Menu_WeaponSkin_Preview"
}
#endif
const TOTAL_THEMED_ITEMS = 40
const PACK_BULK_PURCHASE_COUNT = 10
const MYTHIC_INIDICATOR_COUNT = 3
const MYTHIC_INDICATOR_NAME = "MythicIndicatorButton"

void function WhatsNewPanel_Init( var panel )
{
	file.panel = panel

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, WhatsNewPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, WhatsNewPanel_OnHide )

	SetPanelTabTitle( panel, Localize( "MENU_STORE_PANEL_THEMATIC_EVENT" ) )
	file.headerRui = Hud_GetRui( Hud_GetChild( panel, "Header" ) )
	RuiSetString( file.headerRui, "title", Localize( "#OWNED" ).toupper() )

	file.listPanel = Hud_GetChild( panel, "WhatsNewList" )
	file.aboutButton = Hud_GetChild( panel, "AboutButton" )
	file.itemDetailsBox = Hud_GetChild( panel, "ItemDetailsBox" )
	file.infoBox = Hud_GetChild( panel, "InfoBox" )
	file.openPackButton = Hud_GetChild( panel, "OpenPackButton" )
	file.purchaseSinglePackButton = Hud_GetChild( panel, "Purchase1PackButton" )
	file.purchaseMultiplePacksButton = Hud_GetChild( panel, "PurchaseNPacksButton" )

	file.hideUnlocked = false
	var hideLockedButton = Hud_GetChild( file.panel, "ToggleHideShowLocked" )
	HudElem_SetRuiArg( hideLockedButton, "showAll", true )
	Hud_AddEventHandler( hideLockedButton, UIE_CLICK, ToggleHideShowLockedItems )

	Hud_AddEventHandler( file.purchaseSinglePackButton, UIE_CLICK, void function( var button ) {
		PurchasePackButton_OnClick( button, 1 )
	} )

	Hud_AddEventHandler( file.purchaseMultiplePacksButton, UIE_CLICK, void function( var button ) {
		PurchasePackButton_OnClick( button, file.purchaseMultiplePacksButton_currentQty )
	} )

	Hud_AddEventHandler( file.openPackButton, UIE_CLICK, OpenPackButton_OnClick )

	Hud_AddEventHandler( file.aboutButton, UIE_CLICK, AdvanceMenuEventHandler( GetMenu( "ThematicEventAboutPage" ) ) )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_A, false, "#A_BUTTON_SELECT", "", null, WhatsNew_IsFocusedItem )
	AddPanelFooterOption( panel, LEFT, BUTTON_X, false, "#X_BUTTON_UNLOCK", "#X_BUTTON_UNLOCK", null, WhatsNew_IsFocusedItemLocked )

	file.itemCategoryCount.clear()
	file.itemCategoryUnlockCount.clear()
}

void function WhatsNewPanel_OnShow( var panel )
{
	SetCurrentTabForPIN( Hud_GetHudName( panel ) )
	UI_SetPresentationType( ePresentationType.BATTLE_PASS_3 )
	WhatsNewPanel_Update( panel )
	PreviewThematicLootBox()

	AddCallbackAndCallNow_OnGRXInventoryStateChanged( ThemedShop_UpdateGRXDependantElements )
	AddCallbackAndCallNow_OnGRXOffersRefreshed( ThemedShop_UpdateGRXDependantElements )
}

void function WhatsNewPanel_OnHide( var panel )
{
	WhatsNewPanel_Update( panel )
	RemoveCallback_OnGRXInventoryStateChanged( ThemedShop_UpdateGRXDependantElements )
	RemoveCallback_OnGRXOffersRefreshed( ThemedShop_UpdateGRXDependantElements )
}

void function ToggleHideShowLockedItems( var button )
{
	if( file.numOwnedItems >= TOTAL_THEMED_ITEMS )
		return

	file.hideUnlocked = !file.hideUnlocked
	WhatsNewPanel_Update( Hud_GetParent( button ) )
}

int function SortItemFlavByGUID_Callback( ItemFlavor lhs, ItemFlavor rhs )
{
	SettingsAssetGUID lhsGUID = ItemFlavor_GetGUID( lhs )
	SettingsAssetGUID rhsGUID = ItemFlavor_GetGUID( rhs )

	if ( lhsGUID < rhsGUID )
		return -1
	else if ( lhsGUID > rhsGUID )
		return 1

	return 0
}

void function WhatsNewPanel_Update( var panel )
{
	var scrollPanel = Hud_GetChild( file.listPanel, "ScrollPanel" )

	         
	foreach ( int flavIdx, ItemFlavor unused in file.whatsNewList )
	{
		var button = Hud_GetChild( scrollPanel, "GridButton" + flavIdx )
		WhatsNewRemoveItemButton( button )
	}
	file.whatsNewList.clear()
	file.itemCategoryIndices.clear()
	file.activeItem = null

	if ( IsValid( file.panel ) && IsPanelActive( file.panel ) )
	{
		ItemFlavor ornull activeThemedShopEvent = GetActiveThemedShopEvent( GetUnixTimestamp() )

		if ( activeThemedShopEvent == null )
			return

		if ( !ThemedShopEvent_HasWhatsNew( expect ItemFlavor( activeThemedShopEvent ) ) )
			return

		ItemFlavor associatedEventPack = GetItemFlavorByAsset( ThemedShopEvent_GetAssociatedPack( expect ItemFlavor( activeThemedShopEvent ) ) )

		file.whatsNewList = GRXPack_GetPackContents( associatedEventPack )
		file.associatedPackName = Localize( ItemFlavor_GetLongName( associatedEventPack ) )
		file.itemSourceIcon = "%$" + string( ItemFlavor_GetSourceIcon( associatedEventPack ) ) + "%"                                                                          

		file.numOwnedItems	= FilterOwnedItems( file.whatsNewList )

		var hideLockedButton = Hud_GetChild( file.panel, "ToggleHideShowLocked" )
		if ( file.numOwnedItems >= TOTAL_THEMED_ITEMS )
		{
			Hud_SetLocked( hideLockedButton, true )
			file.hideUnlocked = false
			file.whatsNewList = GRXPack_GetPackContents( associatedEventPack )
			Hud_ScrollToTop( file.listPanel )
		}

		CategorizeWhatsNewList( file.whatsNewList )

		int totalItems 		= file.hideUnlocked ? file.whatsNewList.len() + file.numOwnedItems : file.whatsNewList.len()
		HudElem_SetRuiArg( hideLockedButton, "showAll", !file.hideUnlocked )

		Hud_InitGridButtons( file.listPanel, file.whatsNewList.len() )
		Hud_InitGridButtonsCategories( file.listPanel, file.itemCategoryIndices )

		foreach ( int flavIdx, ItemFlavor flav in file.whatsNewList )
		{
			var button = Hud_GetChild( scrollPanel, "GridButton" + flavIdx )

			var rui = Hud_GetRui( button )
			int itemType = ItemFlavor_GetType( flav )
			if ( itemType != eItemType.character_skin && itemType!= eItemType.weapon_skin )
			{
				asset icon = GetCharacterIconToDisplay( flav )
				RuiSetImage( rui, "characterIcon", icon )
				RuiSetBool( rui, "showCharacterIcon", icon != $"" )
				RuiSetBool( rui, "isLarge", false )
			}
			else
			{
				RuiSetBool( rui, "isLarge", true )
				RuiSetImage( rui, "characterIcon", $"" )
				RuiSetBool( rui, "showCharacterIcon", false )
			}

			RuiSetBool( rui, "isLocked", !IsItemOwned( flav ) )
			RuiSetImage( rui, "itemThumbnail", CustomizeMenu_GetRewardButtonImage( flav ) )
			RuiSetInt( rui, "quality", ItemFlavor_HasQuality( flav ) ? ItemFlavor_GetQuality( flav ) : 0 )
			RuiSetBool( rui, "isLocked", !IsItemOwned( flav ) )

			WhatsNewSetupItemButton( button, flav)

			for ( int i = 0; i < file.itemCategoryIndices.len(); ++i )
			{
				if ( file.itemCategoryIndices[i] == flavIdx )
				{
					int rarity = ItemFlavor_GetQuality( flav )
					string rarityName = ItemFlavor_GetQualityName( flav )
					string unlockedItemsRatio = " "+file.itemCategoryUnlockCount[rarity]+" / "+file.itemCategoryCount[rarity]
					var category = Hud_GetChild( scrollPanel, "GridCategory" + i )

					HudElem_SetRuiArg( category, "label", rarityName )
					HudElem_SetRuiArg( category, "display", unlockedItemsRatio )
					HudElem_SetRuiArg( category, "darkColorOverride", <1,1,1> )
				}
			}
		}

		UpdateLootBoxButton( file.openPackButton, [associatedEventPack] )

		DisplayTime dt = SecondsToDHMS( maxint( 0, CalEvent_GetFinishUnixTime( expect ItemFlavor( activeThemedShopEvent ) ) - GetUnixTimestamp() ) )

		RuiSetString( file.headerRui, "collected", Localize( "#COLLECTED_ITEMS", file.numOwnedItems, totalItems ) )
		HudElem_SetRuiArg( file.infoBox, "timeRemainingText", Localize( "#DAYS_REMAINING", string( dt.days ), string( dt.hours ) ) )
		HudElem_SetRuiArg( file.infoBox, "title", ItemFlavor_GetShortName( associatedEventPack ) )
		HudElem_SetRuiArg( file.infoBox, "isOfferRestricted", GRX_IsOfferRestricted() )
	}
}

void function ThemedShop_UpdateGRXDependantElements()
{
	bool isInventoryReady                   = GRX_IsInventoryReady()
	bool offersReady                        = GRX_AreOffersReady()
	ItemFlavor ornull activeThemedShopEvent = GetActiveThemedShopEvent( GetUnixTimestamp() )
	bool haveActiveCollectionEvent          = activeThemedShopEvent != null
	bool menuIsUsable                       = isInventoryReady && haveActiveCollectionEvent
	int currentMaxEventPackPurchaseCount    = 0
	int remainingPacksAvailable = 40

	if ( offersReady )
		currentMaxEventPackPurchaseCount = GetCurrentMaxEventPackPurchaseCount( GetLocalClientPlayer() )

	Hud_SetVisible( file.purchaseSinglePackButton, !GRX_IsOfferRestricted() )
	HudElem_SetRuiArg( file.purchaseSinglePackButton, "numPacks", 1 )

	int packBulkPurchaseCount = currentMaxEventPackPurchaseCount < 2 ? PACK_BULK_PURCHASE_COUNT : ClampInt( currentMaxEventPackPurchaseCount, 2, PACK_BULK_PURCHASE_COUNT )
	Hud_SetVisible( file.purchaseMultiplePacksButton, !GRX_IsOfferRestricted() )
	HudElem_SetRuiArg( file.purchaseMultiplePacksButton, "numPacks", packBulkPurchaseCount )
	file.purchaseMultiplePacksButton_currentQty = packBulkPurchaseCount

	remainingPacksAvailable = GetCurrentMaxEventPackPurchaseCount( GetLocalClientPlayer() )
	Hud_SetLocked( file.purchaseSinglePackButton, remainingPacksAvailable < 1  )
	Hud_SetLocked( file.purchaseMultiplePacksButton, remainingPacksAvailable < 2  )
}

#if UI
void function WhatsNewSetupItemButton( var button, ItemFlavor itemFlavor )
{
	Assert( !( button in file.activeItemButtons ) )

	file.activeItemButtons[button] <- itemFlavor

	Hud_AddEventHandler( button, UIE_GET_FOCUS, WhatsNewItemButton_OnFocus )
	Hud_AddEventHandler( button, UIE_LOSE_FOCUS, WhatsNewItemButton_OnLoseFocus )
	Hud_AddEventHandler( button, UIE_CLICKRIGHT, InspectButton_OnActivate )
	Hud_AddEventHandler( button, UIE_CLICK, InspectButton_OnActivate )
}

void function WhatsNewRemoveItemButton( var button )
{
	Assert( button in file.activeItemButtons )

	delete file.activeItemButtons[button]

	Hud_RemoveEventHandler( button, UIE_GET_FOCUS, WhatsNewItemButton_OnFocus )
	Hud_RemoveEventHandler( button, UIE_LOSE_FOCUS, WhatsNewItemButton_OnLoseFocus )
	Hud_RemoveEventHandler( button, UIE_CLICKRIGHT, InspectButton_OnActivate )
	Hud_RemoveEventHandler( button, UIE_CLICK, InspectButton_OnActivate )
}

void function WhatsNewItemButton_OnFocus( var button )
{
	ItemFlavor flavor = file.activeItemButtons[button]
	PreviewItem( flavor )
	WhatsNewInfoItem_Update( flavor )

	Hud_Hide( file.openPackButton )
}

void function WhatsNewItemButton_OnLoseFocus( var button )
{
	PreviewThematicLootBox()
	Hud_Show( file.openPackButton )
}

void function PreviewThematicLootBox()
{
	ItemFlavor ornull activeThemedShopEvent = GetActiveThemedShopEvent( GetUnixTimestamp() )
	ItemFlavor associatedEventPack = GetItemFlavorByAsset( ThemedShopEvent_GetAssociatedPack( expect ItemFlavor( activeThemedShopEvent ) ) )

	PreviewItem( associatedEventPack )
	WhatsNewInfoItem_Update( associatedEventPack )
}

void function WhatsNewInfoItem_Update( ItemFlavor focusFlav )
{
	vector rarityCol
	string rarityText
	string nameText
	string descText
	bool showUnlockWithPack = false
	int premiumPrice        = -1
	int craftingPrice       = -1
	bool isCompletionReward = false
	bool isOwned = false
	bool isPack = ( ItemFlavor_GetType( focusFlav ) == eItemType.account_pack )

	ItemFlavor ornull activeThemedShopEvent = GetActiveThemedShopEvent( GetUnixTimestamp() )
	expect ItemFlavor( activeThemedShopEvent )

	if ( isPack )
	{
		nameText = ItemFlavor_GetShortName( focusFlav )
		rarityCol = <1,1,1>
		rarityText = "#PACK"
		descText = "#THEMED_EVENT_PACK_DESCRIPTION"

		ItemFlavor associatedPack = GetItemFlavorByAsset ( ThemedShopEvent_GetAssociatedPack( activeThemedShopEvent ) )
	}
	else if ( isCompletionReward )                                                           
	{
		rarityCol  = SrgbToLinear( GetKeyColor( COLORID_TEXT_LOOT_TIER0, ItemFlavor_GetQuality( focusFlav ) + 1 ) / 255.0 )
		rarityText = ItemFlavor_GetQualityName( focusFlav )
	}
	else                    
	{
		nameText = ItemFlavor_GetLongName( focusFlav )
		rarityCol = SrgbToLinear( GetKeyColor( COLORID_TEXT_LOOT_TIER0, ItemFlavor_GetQuality( focusFlav ) + 1 ) / 255.0 )
		rarityText = ItemFlavor_GetQualityName( focusFlav )
		descText = GetLocalizedItemFlavorDescriptionForOfferButton( focusFlav, false )
		descText += " - "
		descText += Localize( GRX_IsInventoryReady() ? (GRX_IsItemOwnedByPlayer( focusFlav ) ? "#OWNED" : "#LOCKED") : "" )

		isOwned = GRX_IsItemOwnedByPlayer( focusFlav )
		if ( !isOwned )
		{
			if ( GRX_AreOffersReady() && GRX_IsInventoryReady() )
			{
				string offerLocation = ThemedShopEvent_GetGRXOfferLocation( activeThemedShopEvent )
				array<GRXScriptOffer> offers = GRX_GetItemDedicatedStoreOffers( focusFlav, offerLocation )

				if ( offers.len() > 0 )
				{
					GRXScriptOffer offer = offers[0]
					foreach ( ItemFlavorBag price in offer.prices )
					{
						                                                                                                   
						if ( price.flavors[0] == GRX_CURRENCIES[GRX_CURRENCY_PREMIUM] )
						{
							Assert( premiumPrice == -1, "Inherited existing (NOT -1) Apex Coins price for ItemFlavor bag in GRX offer." )
							premiumPrice = price.quantities[0]
						}
						else if ( price.flavors[0] == GRX_CURRENCIES[GRX_CURRENCY_CRAFTING] )
						{
							Assert( craftingPrice == -1, "Inherited existing (NOT -1) Crafting Materials price for ItemFlavor bag in GRX offer." )
							craftingPrice = price.quantities[0]
						}
						else
						{
							Assert( false, "Invalid currency - something that is *NOT* AC or CM - price for ItemFlavor bag in GRX offer." )
						}
					}
				}
			}

			if ( ThemedShopEvent_GetPackOffer( activeThemedShopEvent ) != null && !Mythics_IsItemFlavorMythicSkin( focusFlav ) )
				showUnlockWithPack = true
		}
	}

	ItemFlavor associatedEventPack = GetItemFlavorByAsset( ThemedShopEvent_GetAssociatedPack( activeThemedShopEvent ) )

	RuiSetColorAlpha( Hud_GetRui( file.itemDetailsBox ), "rarityCol", rarityCol, 1.0 )
	HudElem_SetRuiArg( file.itemDetailsBox, "itemRarityText", rarityText )
	HudElem_SetRuiArg( file.itemDetailsBox, "itemNameText", nameText )
	HudElem_SetRuiArg( file.itemDetailsBox, "itemDescText", descText )
	HudElem_SetRuiArg( file.itemDetailsBox, "showUnlockWithPack", showUnlockWithPack )
	HudElem_SetRuiArg( file.itemDetailsBox, "premiumPrice", premiumPrice )
	HudElem_SetRuiArg( file.itemDetailsBox, "craftingPrice", craftingPrice )
	HudElem_SetRuiArg( file.itemDetailsBox, "packName", file.associatedPackName )
	HudElem_SetRuiArg( file.itemDetailsBox, "packImage", ItemFlavor_GetIcon( associatedEventPack ), eRuiArgType.IMAGE )
	HudElem_SetRuiArg( file.itemDetailsBox, "isPack", isPack )
}

void function SetSelectedButton( var selectedButton )
{
	foreach ( var button, ItemFlavor unused in file.activeItemButtons )
	{
		Hud_SetSelected( button, selectedButton == button )
	}
}

bool function WhatsNew_IsFocusedItem()
{
	foreach ( var button, ItemFlavor unused in file.activeItemButtons )
	{
		if ( Hud_IsFocused( button ) )
			return true
	}

	return false
}

bool function WhatsNew_IsFocusedItemLocked()
{
	if ( !GRX_IsInventoryReady() )
		return false

	foreach ( var button, ItemFlavor flavor in file.activeItemButtons )
	{
		if ( Hud_IsFocused( button ) )
			return !GRX_IsItemOwnedByPlayer( flavor )
	}

	return false
}


#endif

void function PreviewItem( ItemFlavor flav )
{
	float scale = 1.0
	bool showLow = true

	switch ( ItemFlavor_GetType( flav ) )
	{
		case eItemType.weapon_charm:
			scale = 1.35
			showLow = false
			break
		case eItemType.weapon_skin:
			string weaponRef = ItemFlavor_GetHumanReadableRef( WeaponSkin_GetWeaponFlavor( flav ) )
			if ( weaponRef == "loot_main_weapon_car" )
				scale = 0.7
			showLow = false
			break
		case eItemType.gladiator_card_frame:
			scale = 0.85
			break
		case eItemType.gladiator_card_intro_quip:
			scale = 1.1
			break
		case eItemType.gladiator_card_stance:
			scale = 0.9
			break
		case eItemType.character_skin:
			scale = 1.10
			break
		case eItemType.gladiator_card_stat_tracker:
			showLow = false
			break
		case eItemType.emote_icon:
			scale = 0.1
			break
	}
	
	bool isNxHH = false
#if NX_PROG || PC_PROG_NX_UI
	isNxHH = IsNxHandheldMode()
#endif
	
	RunClientScript( "UIToClient_ItemPresentation", ItemFlavor_GetGUID( flav ), -1, scale, showLow, null, true, "battlepass_right_ref", isNxHH, true )
}

                                                           
void function SortWhatsNewList( array<ItemFlavor> whatsNewList )
{
	whatsNewList.sort( int function( ItemFlavor a, ItemFlavor b ) : () {

		int aQuality = ItemFlavor_HasQuality( a ) ? ItemFlavor_GetQuality( a ) : -1
		int bQuality = ItemFlavor_HasQuality( b ) ? ItemFlavor_GetQuality( b ) : -1
		if ( aQuality > bQuality )
			return -1
		else if ( aQuality < bQuality )
			return 1

		if ( ItemFlavor_GetType( a ) != ItemFlavor_GetType( b ) )
		{
			int diff = ItemFlavor_GetType( a ) - ItemFlavor_GetType( b )
			return diff / abs( diff )
		}

		return SortStringAlphabetize( Localize( ItemFlavor_GetLongName( a ) ), Localize( ItemFlavor_GetLongName( b ) ) )
	} )
}

                                     
void function CategorizeWhatsNewList( array<ItemFlavor> whatsNewList )
{
	whatsNewList.sort( int function( ItemFlavor a, ItemFlavor b ) : () {

		int aQuality = ItemFlavor_HasQuality( a ) ? ItemFlavor_GetQuality( a ) : -1
		int bQuality = ItemFlavor_HasQuality( b ) ? ItemFlavor_GetQuality( b ) : -1
		if ( aQuality > bQuality )
			return -1
		else if ( aQuality < bQuality )
			return 1

		if ( ItemFlavor_GetType( a ) != ItemFlavor_GetType( b ) )
		{
			int diff = ItemFlavor_GetType( a ) - ItemFlavor_GetType( b )
			Assert( diff != 0, "Difference between types is 0" )
			return diff / abs( diff )
		}

		return SortStringAlphabetize( Localize( ItemFlavor_GetLongName( a ) ), Localize( ItemFlavor_GetLongName( b ) ) )
	} )

	                                                
	for ( int i = 0; i < 4; i++ )                                                                       
	{
		if ( !( i in file.itemCategoryCount ) )
			file.itemCategoryCount[i] <- 0
		else
			file.itemCategoryCount[i] = 0

		if ( !( i in file.itemCategoryUnlockCount ) )
			file.itemCategoryUnlockCount[i] <- 0
		else
			file.itemCategoryUnlockCount[i] = 0
	}

	int prevCatIndex = -1
	foreach (int i, ItemFlavor flav in whatsNewList )
	{
		int curCatIndex = ItemFlavor_GetQuality( flav )

		if ( curCatIndex in file.itemCategoryCount )
			file.itemCategoryCount[curCatIndex]++

		if ( GRX_IsItemOwnedByPlayer( flav ) )
		{
			if ( curCatIndex in file.itemCategoryUnlockCount )
				file.itemCategoryUnlockCount[curCatIndex]++
		}

		if ( curCatIndex != prevCatIndex )
		{
			file.itemCategoryIndices.append( i )
			prevCatIndex = curCatIndex
		}
	}
}

int function FilterOwnedItems( array<ItemFlavor> whatsNewList )
{
	int owned = 0
	for ( int i = whatsNewList.len() - 1; i >= 0; i-- )
	{
		if( IsItemOwned( whatsNewList[i] ) )
		{
			owned++
			if( file.hideUnlocked )
				whatsNewList.remove( i )
		}
	}
	return owned
}

bool function IsItemOwned( ItemFlavor flavor )
{
	if( ItemFlavor_GetGRXMode( flavor ) == eItemFlavorGRXMode.REGULAR )
		return GRX_IsItemOwnedByPlayer( flavor )

	return true
}

void function PurchasePackButton_OnClick( var btn, int count )
{
	if ( Hud_IsLocked( btn ) )
	{
		EmitUISound( "menu_deny" )
		return
	}

	ItemFlavor activeThemedShopEvent = expect ItemFlavor( GetActiveThemedShopEvent( GetUnixTimestamp() ) )
	ItemFlavor packFlav              = GetItemFlavorByAsset( ThemedShopEvent_GetAssociatedPack( activeThemedShopEvent ) )

	GRXScriptOffer ornull offer = ThemedShopEvent_GetPackOffer( activeThemedShopEvent )

	if ( offer == null )
		return

	expect GRXScriptOffer( offer )

	PurchaseDialogConfig pdc
	pdc.offer = offer
	pdc.quantity = count
	pdc.markAsNew = false
	PurchaseDialog( pdc )
}

void function InspectButton_OnActivate( var btn )
{
	if ( !Hud_IsEnabled( btn ) )
		return

	ItemFlavor itemFlav = file.activeItemButtons[btn]
	if ( !IsItemFlavorInspectable( itemFlav ) )
		return

	if ( !GRX_AreOffersReady() )
		return

	ItemFlavor activeThemedShopEvent = expect ItemFlavor( GetActiveThemedShopEvent( GetUnixTimestamp() ) )
	string offerLocation = ThemedShopEvent_GetGRXOfferLocation( activeThemedShopEvent )
	array<GRXScriptOffer> offers     = GRX_GetItemDedicatedStoreOffers( itemFlav, offerLocation )

	if ( offers.len() > 0 )
		StoreInspectMenu_AttemptOpenWithOffer( offers[0] )
}

void function OpenPackButton_OnClick( var btn )
{
	if ( Hud_IsLocked( btn ) )
		return

	ItemFlavor activeThemedShopEvent = expect ItemFlavor( GetActiveThemedShopEvent( GetUnixTimestamp() ) )
	ItemFlavor packFlav              = GetItemFlavorByAsset( ThemedShopEvent_GetAssociatedPack( activeThemedShopEvent ) )
	if ( GRX_GetPackCount( ItemFlavor_GetGRXIndex( packFlav ) ) > 0 )
		OnLobbyOpenLootBoxMenu_ButtonPress( packFlav )
}

const int MAX_PURCHASE_PACK_COUNT = 40
int function GetCurrentMaxEventPackPurchaseCount( entity player )
{
	#if SERVER
		                                      
			        
	#endif

	ItemFlavor activeThemedShopEvent = expect ItemFlavor( GetActiveThemedShopEvent( GetUnixTimestamp() ) )
	ItemFlavor packFlav              = GetItemFlavorByAsset( ThemedShopEvent_GetAssociatedPack( activeThemedShopEvent ) )
	#if SERVER
		                                                                                   
	#elseif UI
		int ownedPackCount = GRX_GetPackCount( ItemFlavor_GetGRXIndex( packFlav ) )
	#endif

	return MAX_PURCHASE_PACK_COUNT - ( FilterOwnedItems( file.whatsNewList ) + ownedPackCount )
}