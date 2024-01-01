extends Node

@onready var goblin = $Goblin
@onready var inventory_interface = $UserInterface/InventoryInterface


func _ready() -> void:
	goblin.toggle_inventory.connect(toggle_inventory_interface)
	inventory_interface.set_goblin_inventory_data(goblin.inventory_data)

func toggle_inventory_interface() -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
