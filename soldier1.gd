extends CharacterBody2D

var esperando_muerte: bool = false
@export var proyectil_scene: PackedScene
@export var velocidad_proyectil := 300.0
@export var tiempo_entre_disparos := 1.5
@export var danio_proyectil: int = 10
@export var vida_maxima: int = 100
@export var distancia_maxima_disparo: float = 400.0  # ← NUEVO: Distancia máxima para disparar

var puede_disparar := true
var mascara: CharacterBody2D = null
var vida_actual: int = 100

func _ready():
	vida_actual = vida_maxima
	mascara = get_tree().get_first_node_in_group("mascara")
	
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("idle")
	
	var area_deteccion = $Area2D
	if area_deteccion:
		area_deteccion.body_entered.connect(_on_mascara_colision)
	
	# Crear timer
	var timer = Timer.new()
	timer.name = "TimerDisparo"
	timer.wait_time = tiempo_entre_disparos
	timer.one_shot = true
	timer.timeout.connect(_on_timer_disparo_timeout)
	add_child(timer)

func _on_timer_disparo_timeout() -> void:
	if not esperando_muerte and is_instance_valid(self):
		puede_disparar = true

func _on_mascara_colision(body: Node2D) -> void:
	if body.is_in_group("mascara") and not esperando_muerte:
		morir()

func recibir_danio(cantidad: int) -> void:
	if esperando_muerte:
		return
	
	vida_actual -= cantidad
	
	if vida_actual <= 0:
		morir()

func morir() -> void:
	if esperando_muerte:
		return
	
	esperando_muerte = true
	puede_disparar = false
	
	# Detener TODO
	set_process(false)
	set_physics_process(false)
	
	# Deshabilitar colisiones INMEDIATAMENTE
	if has_node("Area2D"):
		$Area2D.monitoring = false
		$Area2D.monitorable = false
	
	if has_node("TimerDisparo"):
		$TimerDisparo.stop()
	
	# Reproducir animación de muerte
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("dead")
		await $AnimatedSprite2D.animation_finished
	
	queue_free()

func _process(delta: float) -> void:
	if esperando_muerte or mascara == null or not is_instance_valid(mascara):
		return
	
	# ← NUEVO: Calcular distancia a la máscara
	var distancia = global_position.distance_to(mascara.global_position)
	
	# ← NUEVO: Solo disparar si está dentro del rango
	if distancia > distancia_maxima_disparo:
		return
	
	# Apuntar
	var direccion = (mascara.global_position - global_position).normalized()
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.flip_h = direccion.x < 0
	
	# Disparar
	if puede_disparar:
		_disparar(direccion)

func _disparar(direccion: Vector2) -> void:
	if esperando_muerte or not puede_disparar or proyectil_scene == null:
		return
	
	puede_disparar = false
	
	var bala = proyectil_scene.instantiate()
	bala.global_position = global_position
	bala.velocidad = velocidad_proyectil
	bala.danio = danio_proyectil
	bala.set_direccion(direccion)
	
	get_tree().current_scene.add_child(bala)
	
	if has_node("TimerDisparo") and not esperando_muerte:
		$TimerDisparo.start()
