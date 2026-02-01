extends CharacterBody2D
@export var animacion: AnimatedSprite2D

# Variables de control del mouse
var mouse_en_la_mascara: bool = false
var mascara_agarrada: bool = false
# Variables para el lanzamiento
var posicion_inicial: Vector2 = Vector2.ZERO
var radio_maximo: float = 25.0
# Variables para mejorar el comportamiento físico
var friccion: float = 0.98
var friccion_suelo: float = 0.90
var rebote: float = 0.5
var velocidad_minima: float = 20.0
var en_suelo: bool = false
# Variables para el salto doble / ralentización
var saltos_usados: int = 0
var max_saltos: int = 1
var tiempo_ralentizado: bool = false
var escala_tiempo_ralentizado: float = 0.15

# ===== SISTEMA DE VIDA =====
@export var vida_maxima: int = 100
var vida_actual: int = vida_maxima
signal vida_cambiada(vida_nueva: int, vida_max: int)
signal mascara_muerta
# ===========================

# =====Variables Parabola =====
@onready var linea_guia = $Line2D
@export var puntos_parabola: int = 25
@export var precision_parabola: float = 0.1

#variables de animacion para cuando esta chupando
var pegado_al_enemigo: bool=false

func _ready() -> void:
	vida_actual = vida_maxima
	
	# Iniciar pérdida de vida continua
	iniciar_perdida_vida()

func _on_area_2d_mouse_entered() -> void:
	mouse_en_la_mascara = true

func _on_area_2d_mouse_exited() -> void:
	mouse_en_la_mascara = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drag"):
		print("Click detectado - Mouse en mascara: ", mouse_en_la_mascara, " En suelo: ", en_suelo, " Saltos usados: ", saltos_usados)
		
		if mouse_en_la_mascara and not en_suelo and saltos_usados < max_saltos:
			print("ACTIVANDO SALTO DOBLE")
			mascara_agarrada = true
			posicion_inicial = global_position
			tiempo_ralentizado = true
			saltos_usados += 1
			velocity *= 0.2
		elif mouse_en_la_mascara and en_suelo:
			print("Agarrando desde suelo")
			mascara_agarrada = true
			posicion_inicial = global_position
			velocity = Vector2.ZERO
			tiempo_ralentizado = false
	
	if event.is_action_released("drag") and mascara_agarrada:
		print("Soltando mascara - Saltos usados: ", saltos_usados)
		mascara_agarrada = false
		tiempo_ralentizado = false
		
		var vector_final = get_global_mouse_position() - posicion_inicial
		vector_final = vector_final.limit_length(radio_maximo)
		
		velocity = -vector_final * 15

func _physics_process(delta: float) -> void:
	var delta_ajustado = delta
	if tiempo_ralentizado:
		delta_ajustado = delta * escala_tiempo_ralentizado
	
	# ===== ANIMACIÓN Y FLIP =====
	if mascara_agarrada:
		# Cuando está siendo arrastrada, mostrar idle
		$AnimatedSprite2D.play("idle")
	else:
		# Cambiar animación según velocidad
		if velocity.length() > 2:
			$AnimatedSprite2D.play("moving")
		else:
			$AnimatedSprite2D.play("idle")
		
		# Flip horizontal según dirección
		if velocity.x > 5:
			$AnimatedSprite2D.flip_h = false
		elif velocity.x < -5:
			$AnimatedSprite2D.flip_h = true
		

	# ============================
	
	if mascara_agarrada:
		var mouse_pos = get_global_mouse_position()
		var vector_disparo = mouse_pos - posicion_inicial
		
		if vector_disparo.length() > radio_maximo:
			vector_disparo = vector_disparo.limit_length(radio_maximo)
		
		$AnimatedSprite2D.position = vector_disparo * 0.5
		
		if tiempo_ralentizado:
			velocity.y += get_gravity().y * delta_ajustado
		else:
			velocity = Vector2.ZERO
	else:
		$AnimatedSprite2D.position = Vector2.ZERO
		
		velocity.y += get_gravity().y * delta_ajustado
		velocity.x *= friccion
		
		var colision = move_and_collide(velocity * delta_ajustado)
		
		var estaba_en_suelo = en_suelo
		en_suelo = false
		
		if colision:
			var normal = colision.get_normal()
			velocity = velocity.bounce(normal) * rebote
			
			if normal.y < -0.5:
				en_suelo = true
				
				if not estaba_en_suelo:
					saltos_usados = 0
					print("Recargando salto doble - Contador reseteado")
				
				velocity.x *= friccion_suelo
				
				if abs(velocity.y) < velocidad_minima:
					velocity.y = 0
		
		if en_suelo and velocity.length() < velocidad_minima:
			velocity.x = 0

func _process(_delta: float) -> void:
	if tiempo_ralentizado:
		$AnimatedSprite2D.modulate = Color(0.7, 0.7, 1.0)
		Engine.time_scale = escala_tiempo_ralentizado
	else:
		$AnimatedSprite2D.modulate = Color(1, 1, 1)
		Engine.time_scale = 1.0
		
# Lógica de la parábola
	if mascara_agarrada:
		linea_guia.show()
		_actualizar_parabola()
	else:
		linea_guia.hide()

	if pegado_al_enemigo:
		$AnimatedSprite2D.play("pegado")
		
		
		
		return

# ===== FUNCIONES DEL SISTEMA DE VIDA =====

func recibir_danio(cantidad: int) -> void:
	# ← NUEVO: No recibir daño si está pegada al enemigo
	if pegado_al_enemigo:
		print("🛡️ Máscara invulnerable mientras consume enemigo")
		return
	
	vida_actual -= cantidad
	vida_actual = max(vida_actual, 0)  # Evita que la vida sea negativa
	
	print("¡Daño recibido! Vida actual: ", vida_actual, "/", vida_maxima)
	
	# Emitir señal para actualizar UI si la tienes
	vida_cambiada.emit(vida_actual, vida_maxima)
	
	# Efecto visual de daño (parpadeo rojo)
	_efecto_danio()
	
	# Verificar si murió
	if vida_actual <= 0:
		morir()
func morir() -> void:
	print("¡La máscara ha muerto! Game Over")
	mascara_muerta.emit()
	
	# Restaurar la escala de tiempo antes de pausar
	Engine.time_scale = 1.0
	
	# Mostrar Game Over en el HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.mostrar_game_over()
	
	# Pausar el juego después de un momento
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = true

func _efecto_danio() -> void:
	# Parpadeo rojo al recibir daño
	$AnimatedSprite2D.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)

func curar(cantidad: int) -> void:
	vida_actual += cantidad
	vida_actual = min(vida_actual, vida_maxima)  # No superar la vida máxima
	print("¡Curación! Vida actual: ", vida_actual, "/", vida_maxima)
	vida_cambiada.emit(vida_actual, vida_maxima)

func obtener_vida() -> int:
	return vida_actual

# =========================================

func iniciar_perdida_vida() -> void:
	while vida_actual > 0:
		await get_tree().create_timer(1.0).timeout
		recibir_danio(1)
		
func _actualizar_parabola() -> void:
	var puntos = []
	# Calculamos el vector de disparo igual que en tu función _input
	var mouse_pos = get_global_mouse_position()
	var vector_final = mouse_pos - posicion_inicial
	vector_final = vector_final.limit_length(radio_maximo)
	
	# Usamos el multiplicador 15 que tienes en tu código de lanzamiento
	var velocidad_simulada = -vector_final * 15
	
	for i in range(puntos_parabola):
		var t = i * precision_parabola
		# x = v0 * t
		# y = v0 * t + 0.5 * g * t^2
		var x = velocidad_simulada.x * t
		var y = velocidad_simulada.y * t + 0.5 * get_gravity().y * (t * t)
		puntos.append(Vector2(x, y))
	
	linea_guia.points = puntos





#detecta cuando la mascara y.el soldado chocan
func _on_area_2d_2_area_entered(area: Area2D) -> void:
	print("coalicion de la mascara con algo")
	if area.is_in_group("enemie"):
		print("enemigo tocado")
		_mover_hacia_enemigo(area)

func _mover_hacia_enemigo(enemigo: Area2D) -> void:
	set_physics_process(false)
	mascara_agarrada = true
	velocity = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", enemigo.global_position, 0.15)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	tween.finished.connect(_al_llegar_al_enemigo.bind(enemigo))

func _al_llegar_al_enemigo(enemigo: Area2D) -> void:
	velocity = Vector2.ZERO
	global_position = enemigo.global_position
	pegado_al_enemigo = true
	
	# Ocultar sprite del soldado mientras se chupa
	if enemigo.get_parent().has_node("AnimatedSprite2D"):
		enemigo.get_parent().get_node("AnimatedSprite2D").visible = false
	
	# Matar al soldado
	if enemigo.get_parent().has_method("morir"):
		enemigo.get_parent().morir()
	
	# ← NUEVO: Recuperar vida al matar al soldado
	curar(30)  # Puedes cambiar el número a lo que quieras
	
	await get_tree().create_timer(2.0).timeout
	
	pegado_al_enemigo = false
	velocity = Vector2.ZERO
	mascara_agarrada = false
	set_physics_process(true)
