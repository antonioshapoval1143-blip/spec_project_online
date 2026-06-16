extends Node


var score: int


signal score_changed(new_score: int)

func score_save(scores: int):
	var file = FileAccess.open("user://temp_score", FileAccess.WRITE)
	file.store_var(scores)

func end_save(scores: int):
	var file = FileAccess.open("user://current_score", FileAccess.WRITE)
	file.store_var(scores)
	clean_temp()
	
func clean_temp():
	DirAccess.remove_absolute("user://temp_score")
	

func start_scores():
	var scores = int(FileAccess.open("user://current_score", FileAccess.READ).get_var())
	FileAccess.open("user://temp_score", FileAccess.WRITE).store_var(scores)
	score = scores

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)
	score_save(score)
	print("Очки: ", score)
