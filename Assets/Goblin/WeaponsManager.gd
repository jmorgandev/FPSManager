extends Node3D

@onready var Animation_Player = get_node("%AnimationPlayer")

var Current_Weapon = null

var Weapon_Stack = []

var Weapon_Indicator = 0

var Next_weapon:String

var Weapon_List = {}

@export var _weapon_resources: Array[Weapon_Resource]

@export var Start_Weapons: Array[String]

func _ready():
	Initialise(Start_Weapons) #enter the state machine

func Initialise(_start_weapons: Array):
	#Create a Dictionary to refer to our weapons
	for weapon in _weapon_resources:
		Weapon_List[weapon.Weapon_name] = weapon
		
	for i in _start_weapons:
		Weapon_Stack.push_back(i) #Add Starting Weapon
		
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	enter()
	
func enter():
	pass
	Animation_Player.queue(Current_Weapon.activate)
	
func exit():
	pass
	
func Change_weapon():
	pass
	

