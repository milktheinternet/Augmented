extends Control

var camera : Camera2D
var screen_size : Vector2
var healthBar : Node2D
var roomControl : Node
var menus : Dictionary
var activeMenu = 'game'

const PLURAL_ITEM : Dictionary = {
	"gear":"gears",
	"plate":"plates",
	"battery":"batteries",
	"coil":"coils"
}

func hide_menus():
	for menu in menus.values():
		menu.hide()

func switch_menu(menu):
	hide_menus()
	menus[menu].show()
	activeMenu = menu

func update_camera():
	# places the gui on the camera
	camera = get_viewport().get_camera_2d()
	screen_size = get_viewport_rect().size
	size.x = screen_size.x / camera.zoom.x
	size.y = screen_size.y / camera.zoom.y
	global_position = camera.global_position - Vector2(size.x/2, size.y/2)
	# switch to the game window when you enter a new room
	switch_menu('game')

func _ready():
	$HelperWindowRect.hide()
	menus = {
		'game':$Game,
		'pause':$PauseMenu,
		'options':$OptionsMenu,
		'upgrade':$UpgradeMenu
	}
	healthBar = $Game/TopInfo/Healthbar
	roomControl = $/root/main/RoomControl
	update_camera()

func _process(delta):
	# update the game menu
	if activeMenu == 'game':
		healthBar.updateHP(PlayerStats.hp/PlayerStats.maxHP)
		var depth = roomControl.depth
		var heat = roomControl.heat
		var inventory : Dictionary = PlayerStats.inventory
		var inventoryString : String = ""
		for item in inventory:
			inventoryString += ('\n%s: %s' % [item, inventory[item]]).to_upper()
		$Game/TopInfo/Label.text = "DEPTH: %s\nHEAT: %s%s" % [depth, heat, inventoryString]

	if Input.is_action_just_pressed('pause'):
		if activeMenu == 'pause':
			switch_menu('game')
			get_tree().paused = false
		else:
			switch_menu('pause')
			get_tree().paused = true

func set_master_volume(volume : float):
	print('Volume set to ',volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), volume)

# When buttons pressed:
func _on_resume_pressed():
	switch_menu('game')
	get_tree().paused = false

func _on_back_pressed():
	switch_menu('pause')
	
func _on_options_pressed():
	switch_menu('options')


func _on_upgrade_shortcut_pressed():
	switch_menu('upgrade')

var part_name : String
var upgrade_name : String

func _on_part_label_value_updated(stringValue):
	part_name = stringValue

func _on_upgrade_label_value_updated(stringValue):
	upgrade_name = stringValue
	update_upgrade_cost()

func update_upgrade_cost():
	var label : Label = $UpgradeMenu/Buttons/CostLabel
	var cost : Dictionary = AugmentData.AUGMENTS[upgrade_name]['cost']
	print(upgrade_name,": ",cost)
	var itemStrings : Array[String] = []
	for item in cost:
		var ammount : int = cost[item]
		if ammount == 0: continue
		item = item if ammount == 1 else PLURAL_ITEM[item]
		itemStrings.append("%s %s" % [ammount, item])
	label.text = "Cost: " + ", ".join(itemStrings)
