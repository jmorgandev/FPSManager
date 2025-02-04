extends Node3D

@onready var Animation_Player = get_node("%AnimationPlayer")

var Current_Weapon = null

var Weapon_Stack = [] #An Array of all weapons

var Weapon_Indicator = 0

var Next_Weapon: String

var Weapon_List = {}

@export var _weapon_resources: Array[Weapon_Resource]

@export var Start_Weapons: Array[String]

func _ready():
	Initialise(Start_Weapons) #enter the state machine
	
func _input(event):
	if event.is_action_pressed("weapon_up"):
		Weapon_Indicator = min(Weapon_Indicator+1, Weapon_Stack.size()-1)
		exit(Weapon_Stack[Weapon_Indicator])
	if event.is_action_pressed("weapon_down"):
		Weapon_Indicator = max(Weapon_Indicator-1,0)
		exit(Weapon_Stack[Weapon_Indicator])

func Initialise(_start_weapons: Array):
	#Create a Dictionary to refer to our weapons
	for weapon in _weapon_resources:
		Weapon_List[weapon.weapon_name] = weapon
		
	for i in _start_weapons:
		Weapon_Stack.push_back(i) #Add Starting Weapon
		
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	enter()
	
func enter():
	#Call wehn first "entering" into a weapon
	Animation_Player.queue(Current_Weapon.activate_anim)
	
func exit(_next_weapon: String):
	#in order to change weapons first call exit
	if _next_weapon != Current_Weapon.weapon_name:
		if Animation_Player.get_current_animation() != Current_Weapon.deactivate_anim:
			Animation_Player.play(Current_Weapon.deactivate_anim)
			Next_Weapon = _next_weapon
func Change_Weapon(weapon_name: String):
	Current_Weapon = Weapon_List[weapon_name]
	Next_Weapon = ""
	enter()
	



func _on_animation_player_animation_finished(anim_name):
	if anim_name == Current_Weapon.deactivate_anim:
		Change_Weapon(Next_Weapon)

