extends GridContainer

func _ready():
	leaderscores()

func leaderscores():
	var leaderscores1 = (await DbConnection.fetch_leaderboard()).items
	for child in get_children():
		child.queue_free()
		
	add_label("№", true)
	add_label("Username", true)
	add_label("Scores", true)
	
	for i in leaderscores1.size():
		var s = leaderscores1[i]
		add_label(str(i + 1))
		add_label(s.nickname)
		add_label(str(s.score))

func add_label(text: String, header := false):
	var l = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if header:
		l.add_theme_font_size_override("font_size", 50)
	else:
		l.add_theme_font_size_override("font_size", 45)
		
	add_child(l)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://profile.tscn")
	pass # Replace with function body.
