#extends Area2D
#
#
## Called when the node enters the scene tree for the first time.
#func _ready():
	#body_entered.connect(_on_body_entered)
#
#func _on_body_entered(body):
	#if body.is_in_group("player"): # Перевіряємо, чи це гравець
		##print("Гравець увійшов у тригер!")
		#$"../Node2D2/StaticBody2D4/CollisionShape2D".set_deferred("disabled", false) 			#.disabled = false
		#$"../Node2D2/StaticBody2D4".visible = true
		#$"../Node2D2/Node2D2".visible = true
		#$"../Node2D2/Node2D".visible = true
		#$"../Player/Camera2D2".set_deferred("enabled", false)
		#$"../Node2D/Camera2D".set_deferred("enabled", true) #.enabled = true
		#$AnimatedSprite2D.visible = true
		#$AnimatedSprite2D.play("default")
		#$Node2D.visible = false
		#$"../Boss".visible = true
		#await $AnimatedSprite2D.animation_finished
		#$"../CanvasLayer/HealthBar".visible = true
		#$"../Boss".is_enabled = true
		#
		#queue_free()
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
	#pass

extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):  # Перевіряємо, чи це гравець
		#print("Гравець увійшов у тригер!")
		$"../Node2D2/StaticBody2D4/CollisionShape2D".set_deferred("disabled", false)
		$"../Node2D2/StaticBody2D4".visible = true
		$"../Node2D2/Node2D2".visible = true
		$"../Node2D2/Node2D".visible = true
		
		# Замість миттєвого перемикання — плавний перехід
		var current_cam = $"../Player/Camera2D2"  # Поточна камера (гравця)
		var target_cam = $"../Node2D/Camera2D"    # Цільова камера (для боса?)
		switch_cameras_smoothly(current_cam, target_cam, 1.0)  # 1.0 секунда на перехід
		
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play("default")
		$Node2D.visible = false
		$"../Boss".visible = true
		
		await $AnimatedSprite2D.animation_finished
		
		$"../CanvasLayer/HealthBar".visible = true
		$"../Boss".is_enabled = true
		queue_free()

# Функція для плавного перемикання між двома Camera2D
func switch_cameras_smoothly(current_cam: Camera2D, target_cam: Camera2D, duration: float = 1.0):
	# Зберігаємо цільові властивості нової камери (позиція, зум, ротація)
	var target_position = target_cam.position
	var target_zoom = target_cam.zoom
	var target_rotation = target_cam.rotation
	
	# Деактивуємо поточну, активуємо нову і копіюємо властивості з поточної
	target_cam.set_deferred("enabled", true)
	#target_cam.position = current_cam.position
	target_cam.zoom = current_cam.zoom
	target_cam.rotation = current_cam.rotation
	current_cam.set_deferred("enabled", false)
	
	# Створюємо Tween для інтерполяції
	var tween = create_tween()
	tween.set_parallel(true)  # Паралельно інтерполювати всі властивості
	
	# Інтерполюємо позицію
	tween.tween_property(target_cam, "position", target_position, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	# Інтерполюємо зум (якщо потрібно; якщо зум однаковий, це не змінить нічого)
	tween.tween_property(target_cam, "zoom", target_zoom, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Інтерполюємо ротацію (якщо потрібно)
	tween.tween_property(target_cam, "rotation", target_rotation, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Опціонально: await tween.finished, якщо потрібно чекати завершення переходу

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
