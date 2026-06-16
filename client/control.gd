extends Control

@onready var activated = false
var current_prog
var player_id = int(FileAccess.open("user://login", FileAccess.READ).get_var().player_id)


func checking_prog():
	if FileAccess.file_exists("user://conf_prog"):
		var conf_prog = FileAccess.open("user://conf_prog", FileAccess.READ).get_var()
		if current_prog != conf_prog:
			if current_prog.M1 != conf_prog.M1 and conf_prog.M1 != 1:
				$Panel/Wep_label.text = "Flame Weapon"
			elif current_prog.M2 != conf_prog.M2 and conf_prog.M2 != 1:
				$Panel/Wep_label.text = "Freeze Weapon"
			elif current_prog.M3 != conf_prog.M3 and conf_prog.M3 != 1:
				$Panel/Wep_label.text = "Electric Weapon"
			elif current_prog.M4 != conf_prog.M4 and conf_prog.M4 != 1:
				$Panel/Label.text = "You defeated \nthe final boss!"
				$Panel/Wep_label.text = "Congrats!"
			elif current_prog.M1 == 0 and current_prog.M2 == 0 and current_prog.M3 == 0:
				$Panel.visible = false

		else: 
			$Panel.visible = false



func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	if is_visible_in_tree():
		_initialize_when_visible()
	
func _on_visibility_changed() -> void:
	if is_visible_in_tree() and not activated:
		_initialize_when_visible()

func _initialize_when_visible() -> void:
	activated = true
	var scores = int(FileAccess.open("user://current_score", FileAccess.READ).get_var())
	print(scores)
	$Scores.text = str(scores)
	current_prog = FileAccess.open("user://current_prog", FileAccess.READ).get_var()
	checking_prog()


#



func _on_continue_pressed() -> void:
	$ConfirmationDialog.visible = true
	$BtM.disabled = true
	$Continue.disabled = true
	pass # Replace with function body.


func _on_bt_m_pressed() -> void:
	get_tree().paused = !get_tree().paused
	get_tree().change_scene_to_file("res://menu.tscn")
	pass # Replace with function body.


func _on_confirmation_dialog_canceled() -> void:
	FileAccess.open("user://conf_prog", FileAccess.WRITE).store_var(current_prog)
	get_tree().paused = !get_tree().paused
	get_tree().change_scene_to_file("res://next_levs.tscn")
	pass # Replace with function body.


func _on_confirmation_dialog_confirmed() -> void:
	FileAccess.open("user://conf_prog", FileAccess.WRITE).store_var(current_prog)
	get_tree().paused = !get_tree().paused
	get_tree().change_scene_to_file("res://save_game.tscn")
	pass # Replace with function body.


func _on_confirmation_dialog_close_requested() -> void:
	$ConfirmationDialog.visible = false
	$BtM.disabled = false
	$Continue.disabled = false
	
	pass # Replace with function body.
