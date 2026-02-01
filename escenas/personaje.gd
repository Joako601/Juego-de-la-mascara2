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

<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
# Variables para detección de pinchos
var puede_recibir_daño_pincho = true
var cooldown_pincho = 1.0

# ===== REFERENCIA AL TILEMAPLAYER DE PINCHOS =====
var tilemap_pinchos: TileMapLayer
# ==================================

<<<<<<< HEAD
=======
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
# =====Variables Parabola =====
@onready var linea_guia = $Line2D
@export var puntos_parabola: int = 25
@export var precision_parabola: float = 0.1

func _ready() -> void:
	vida_actual = vida_maxima
	
<<<<<<< HEAD
=======
<<<<<<< HEAD
	# Iniciar pérdida de vida continua
=======
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	# Esperar un frame para que la escena esté completa
	await get_tree().process_frame
	
	# Buscar directamente el nodo "borde" dentro de Estructura
	var estructura = get_tree().root.get_node_or_null("Escena principal/Estructura")
	if estructura:
		tilemap_pinchos = estructura.get_node_or_null("pinchos")
	print("TileMapLayer pinchos encontrado: ", tilemap_pinchos)
	if tilemap_pinchos:
		var metodos = []
		for m in tilemap_pinchos.get_method_list():
			metodos.append(m["name"])
		print("Métodos disponibles: ", metodos)
	
<<<<<<< HEAD
=======
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
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
<<<<<<< HEAD
		$AnimatedSprite2D.play("idle")
	else:
=======
<<<<<<< HEAD
		# Cuando está siendo arrastrada, mostrar idle
		$AnimatedSprite2D.play("idle")
	else:
		# Cambiar animación según velocidad
=======
		$AnimatedSprite2D.play("idle")
	else:
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
		if velocity.length() > 2:
			$AnimatedSprite2D.play("moving")
		else:
			$AnimatedSprite2D.play("idle")
		
<<<<<<< HEAD
=======
<<<<<<< HEAD
		# Flip horizontal según dirección
=======
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
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
<<<<<<< HEAD
=======
<<<<<<< HEAD
=======
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	
	# ===== DETECCIÓN DE PINCHOS =====
	_verificar_pinchos()

# ===== FUNCIÓN DE DETECCIÓN DE PINCHOS =====
func _verificar_pinchos() -> void:
	if not tilemap_pinchos or not puede_recibir_daño_pincho:
		return
	
	# Revisar varios puntos alrededor del personaje
	var puntos_chequeo = [
		global_position,
		global_position + Vector2(8, 0),
		global_position + Vector2(-8, 0),
		global_position + Vector2(0, 8),
		global_position + Vector2(0, -8),
	]
	
	for punto in puntos_chequeo:
		var pos_local = tilemap_pinchos.to_local(punto)
		var coordenada_tile = tilemap_pinchos.local_to_map(pos_local)
		var datos_tile = tilemap_pinchos.get_cell_tile_data(coordenada_tile)
		
		if datos_tile != null:
			print("💔 ¡Colisionaste con un pincho!")
			recibir_danio(40)
			puede_recibir_daño_pincho = false
			get_tree().create_timer(cooldown_pincho).timeout.connect(func(): puede_recibir_daño_pincho = true)
			return
# =============================================
<<<<<<< HEAD
=======
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095

func _process(_delta: float) -> void:
	if tiempo_ralentizado:
		$AnimatedSprite2D.modulate = Color(0.7, 0.7, 1.0)
		Engine.time_scale = escala_tiempo_ralentizado
	else:
		$AnimatedSprite2D.modulate = Color(1, 1, 1)
		Engine.time_scale = 1.0
		
<<<<<<< HEAD
	# Lógica de la parábola
=======
<<<<<<< HEAD
# Lógica de la parábola
=======
	# Lógica de la parábola
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	if mascara_agarrada:
		linea_guia.show()
		_actualizar_parabola()
	else:
		linea_guia.hide()

# ===== FUNCIONES DEL SISTEMA DE VIDA =====

func recibir_danio(cantidad: int) -> void:
	vida_actual -= cantidad
<<<<<<< HEAD
	vida_actual = max(vida_actual, 0)
=======
<<<<<<< HEAD
	vida_actual = max(vida_actual, 0)  # Evita que la vida sea negativa
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	
	print("¡Daño recibido! Vida actual: ", vida_actual, "/", vida_maxima)
	
	vida_cambiada.emit(vida_actual, vida_maxima)
	
	_efecto_danio()
	
<<<<<<< HEAD
=======
	# Verificar si murió
=======
	vida_actual = max(vida_actual, 0)
	
	print("¡Daño recibido! Vida actual: ", vida_actual, "/", vida_maxima)
	
	vida_cambiada.emit(vida_actual, vida_maxima)
	
	_efecto_danio()
	
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	if vida_actual <= 0:
		morir()

func morir() -> void:
	print("¡La máscara ha muerto! Game Over")
	mascara_muerta.emit()
	
<<<<<<< HEAD
	Engine.time_scale = 1.0
	
=======
<<<<<<< HEAD
	# Restaurar la escala de tiempo antes de pausar
	Engine.time_scale = 1.0
	
	# Mostrar Game Over en el HUD
=======
	Engine.time_scale = 1.0
	
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.mostrar_game_over()
	
<<<<<<< HEAD
=======
<<<<<<< HEAD
	# Pausar el juego después de un momento
=======
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = true

func _efecto_danio() -> void:
<<<<<<< HEAD
=======
<<<<<<< HEAD
	# Parpadeo rojo al recibir daño
=======
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	$AnimatedSprite2D.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = Color(1, 1, 1)

func curar(cantidad: int) -> void:
	vida_actual += cantidad
<<<<<<< HEAD
	vida_actual = min(vida_actual, vida_maxima)
=======
<<<<<<< HEAD
	vida_actual = min(vida_actual, vida_maxima)  # No superar la vida máxima
=======
	vida_actual = min(vida_actual, vida_maxima)
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	print("¡Curación! Vida actual: ", vida_actual, "/", vida_maxima)
	vida_cambiada.emit(vida_actual, vida_maxima)

func obtener_vida() -> int:
	return vida_actual

<<<<<<< HEAD
=======
<<<<<<< HEAD
# =========================================

=======
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
func iniciar_perdida_vida() -> void:
	while vida_actual > 0:
		await get_tree().create_timer(1.0).timeout
		recibir_danio(1)
		
func _actualizar_parabola() -> void:
	var puntos = []
<<<<<<< HEAD
=======
<<<<<<< HEAD
	# Calculamos el vector de disparo igual que en tu función _input
=======
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	var mouse_pos = get_global_mouse_position()
	var vector_final = mouse_pos - posicion_inicial
	vector_final = vector_final.limit_length(radio_maximo)
	
<<<<<<< HEAD
=======
<<<<<<< HEAD
	# Usamos el multiplicador 15 que tienes en tu código de lanzamiento
=======
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
	var velocidad_simulada = -vector_final * 15
	
	for i in range(puntos_parabola):
		var t = i * precision_parabola
<<<<<<< HEAD
=======
<<<<<<< HEAD
		# x = v0 * t
		# y = v0 * t + 0.5 * g * t^2
=======
>>>>>>> 669bacb36ef352b87e43affb953a2aecbcbb7b47
>>>>>>> d167c3c33bafc14a22f59cbc8510d284f5cc4095
		var x = velocidad_simulada.x * t
		var y = velocidad_simulada.y * t + 0.5 * get_gravity().y * (t * t)
		puntos.append(Vector2(x, y))
	
	linea_guia.points = puntos
