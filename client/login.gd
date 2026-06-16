extends Control

func _process(_delta):
	if $CheckButton.button_pressed == true:
		$CheckButton.text = "Sign up"
	else:
		$CheckButton.text = "Log in"
	

func _on_button_pressed() -> void:
	if await DbConnection.is_server_online():
		var login = $LineEdit.text
		var pw = $LineEdit2.text.md5_text()
		if $CheckButton.button_pressed == true:
			DbConnection.register(login, pw)
			await get_tree().create_timer(1).timeout
			var res = await DbConnection.login(login, pw)
			#print((res))
			var logined = res.items[0]
			FileAccess.open("user://login", FileAccess.WRITE).store_var(logined)
			get_tree().change_scene_to_file("res://profile.tscn")
		else:
			var res = await DbConnection.login(login, pw)
			#print((res.items))
			if res.items == []:
				$Error.dialog_text = "Wrong username or password"
				$Error.visible = true
			else:
				var logined = res.items[0]
				FileAccess.open("user://login", FileAccess.WRITE).store_var(logined)
				
				get_tree().change_scene_to_file("res://profile.tscn")
	else:
		$Error.visible = true
		return
		
		


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
	pass # Replace with function body.
