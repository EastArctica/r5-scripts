global function MpWeaponBubbleBunker_Init

global function OnWeaponTossReleaseAnimEvent_WeaponBubbleBunker
global function OnWeaponTossPrep_WeaponBubbleBunker
#if CLIENT
global function GetBubbleBunkerRui
#endif
global function GibraltarIsInDome
global function InDomeShield

global const string GIBRALTAR_DOME_SCRIPTNAME = "gibraltar_dome_shield"

const float BUBBLE_BUNKER_DEPLOY_DELAY = 1.0
const float BUBBLE_BUNKER_DURATION_WARNING = 5.0

const bool BUBBLE_BUNKER_DAMAGE_ENEMIES = false

const float BUBBLE_BUNKER_ANGLE_LIMIT = 0.55

const asset BUBBLE_BUNKER_BEAM_FX = $"P_wpn_BBunker_beam"
const asset BUBBLE_BUNKER_BEAM_END_FX = $"P_wpn_BBunker_beam_end"
const asset BUBBLE_BUNKER_SHIELD_FX = $"P_wpn_BBunker_shield"
const asset BUBBLE_BUNKER_SHIELD_COLLISION_MODEL = $"mdl/fx/bb_shield.rmdl"
const asset BUBBLE_BUNKER_SHIELD_PROJECTILE = $"mdl/props/gibraltar_bubbleshield/gibraltar_bubbleshield.rmdl"

const string BUBBLE_BUNKER_SOUND_ENDING = "Gibraltar_BubbleShield_Ending"
const string BUBBLE_BUNKER_SOUND_FINISH = "Gibraltar_BubbleShield_Deactivate"

const BUBBLE_BUNKER_THROW_POWER = 800.0
const BUBBLE_BUNKER_RADIUS = 240                                                  

struct
{
	#if CLIENT
	var bubbleBunkerRui
	#endif
} file


void function MpWeaponBubbleBunker_Init()
{
	PrecacheParticleSystem( BUBBLE_BUNKER_BEAM_END_FX )
	PrecacheParticleSystem( BUBBLE_BUNKER_BEAM_FX )
	PrecacheParticleSystem( BUBBLE_BUNKER_SHIELD_FX )
	PrecacheModel( BUBBLE_BUNKER_SHIELD_COLLISION_MODEL )
	PrecacheModel( BUBBLE_BUNKER_SHIELD_PROJECTILE )

	#if SERVER
	                                     
	                                      
	                                     
	#else
	StatusEffect_RegisterEnabledCallback( eStatusEffect.bubble_bunker, BubbleBunker_EnterDome )
	StatusEffect_RegisterDisabledCallback( eStatusEffect.bubble_bunker, BubbleBunker_ExitDome )
	#endif
}

var function OnWeaponTossReleaseAnimEvent_WeaponBubbleBunker( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoReq = weapon.GetAmmoPerShot()
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	entity deployable = ThrowDeployable( weapon, attackParams, BUBBLE_BUNKER_THROW_POWER, OnBubbleBunkerPlanted, null, null )
	if ( deployable )
	{
		entity player = weapon.GetWeaponOwner()
		PlayerUsedOffhand( player, weapon, true, deployable )

		#if SERVER
			                                      
			                                 

			                                                            
			                            
				                                                

			                                         

			                                                              
		#endif

	}

	return ammoReq
}

void function OnWeaponTossPrep_WeaponBubbleBunker( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )
}

void function OnBubbleBunkerPlanted( entity projectile, DeployableCollisionParams collisionParams )
{
	#if SERVER
		                               

		                                    
		                        
		 
			                    
			      
		 

		                                      

		                                    
		                                                
		                                               
		                                                  
		                                             

		                                                                                                                                           
		                                 
		 
			                                                               
			                                                                     

			                                             
			                                                                   
				                                           
		 

		                                         
		                        

		                               
		                                                                         
		                                                                                       

		                                                                        
		                                   
		                                                   
		                                   
		                                                        
		                    

		                               

		                                                    

		                                                                                           
			                                             
		                                
			                                    

		                                                    

                      
		                                     
			                                                                                   
                            

	#endif
}

#if SERVER
                                                                     
 
	                                   

	                                    

	                        
	 
		                    
		      
	 
	                          

	                                                                                                                              
	                    
	 
		                                                      
		                          
	 

	                           

	                                                                                                                                                

	                                                      
	                              

	                                          

	                                                            
	                                                                     

	                                    

	                              

	                                                              

	            
		                               
		 
			                            
			 
				                                       
			 

			                    
			 
				            
			 
		 
	 

	                                                                                                                        

	                                                                                    
 

                                                        
 
	                                   

	                                                            
	                              
	                                                           
 

                                                                                                                                  
 
	                                   
	                                     

	                                    

	                        
		      

	                                            

	                                                                                                                                                                                                                      
	                                  
	                                                  

	                                              
	                                     

	                                      

	                                 

	                                                             
	                                                      

	                                                                                                                 
		                       
			                                                            
	  

	            
		                                         
		 

			                                              
				                                          
			                                           
				                                       
			                              
				                                   
		 
	 

	                                                      
	                                              

	                                              
		                                          
	                                           
		                                       

	                                                            
	                                                                     

	                                                                                                                            

	            
		                                    
		 
			                                           
				                                       
			                                        
				                                    

			                            
				                                                           
		 
	 

	                                                           

	                                   
	                                   

 

                                                     
 
	                                                                                  

	                                         

	                           
		                            

	                             

	                                   
	                                        

	            
		                      
		 
			                       
				               
		 
	 

	                                                           
	                                                                      
	                                           
	                                     
 

                                                    
 
	                                  
	                                           

	                                      
	                   

	                                                                                                                
	                             
	                                             

	                                            
	                                    
	                               

	                                 

	            
		                         
		 
			                         
				                 
		 
	 

	             
 

                                                            
 
	                     
		                                                
 

                                                                     
 
	                             
	                           
	                                 

	            
		                    
		 
			                     
			 
				                                             
				 
					                                                          
					                                     
				 
			 
		 
	 

	                                  
	 
		                                                                                       
		              
		 
			                                             
				                                                                                                   
		 
		    
		 
			                                                          
			                                     
		 

		           
	 

	                                             
	 
		                                                          
		                                     
	 
 

#endif         

#if CLIENT
void function BubbleBunker_EnterDome( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	file.bubbleBunkerRui = CreateCockpitRui( $"ui/bubble_bunker.rpak", HUD_Z_BASE )
	RuiTrackFloat( file.bubbleBunkerRui, "bleedoutEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "bleedoutEndTime" ) )
	RuiTrackFloat( file.bubbleBunkerRui, "reviveEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "reviveEndTime" ) )
}

void function BubbleBunker_ExitDome( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	RuiDestroyIfAlive( file.bubbleBunkerRui )
	file.bubbleBunkerRui = null
}

var function GetBubbleBunkerRui()
{
	return file.bubbleBunkerRui
}
#endif         


bool function GibraltarIsInDome( entity player )
{
	if ( !PlayerHasPassive( player, ePassives.PAS_ADS_SHIELD ) )
		return false

	return InDomeShield( player )
}

bool function InDomeShield( entity player )
{
	return StatusEffect_GetSeverity( player, eStatusEffect.bubble_bunker ) > 0.0
}