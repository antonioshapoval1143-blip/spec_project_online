extends GridContainer

var filter = int()
signal table_change

func _ready():
	table_change.connect(leaderscores)
	on_pressed($"../OptionButton".get_selected())
	$"../OptionButton".item_selected.connect(on_pressed)

func on_pressed(index: int):
	match index:
		0:
			filter = 1
		1:
			filter = 2
		2:
			filter = 3
	table_change.emit()

func leaderscores():
	var leaderscores1 = (await DbConnection.mp_results(filter)).items
	for child in get_children():
		child.queue_free()
		
	add_label("№", true)
	add_label("Host", true)
	add_label("Guest", true)
	add_label("Winner", true)
	
	for i in leaderscores1.size():
		var s = leaderscores1[i]
		add_label(str(i + 1))
		add_label(s.Host)
		add_label(s.Guest)
		add_label(s.Winner)

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
	get_tree().change_scene_to_file("res://mp_menu.tscn")
	pass # Replace with function body.
