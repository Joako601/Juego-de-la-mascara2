extends CanvasLayer

@onready var health_bar = $MarginContainer/VBoxContainer/HealthBarContainer/HealthBar
@onready var health_label = $MarginContainer/HealthLabel

func _ready():
	# Esperar un frame para que todo esté listo
	await get_tree().process_frame
	
	# Buscar el personaje en el padre (escena principal)
	var personaje = get_parent().get_node_or_null("Personaje")
	
	if personaje:
		personaje.vida_cambiada.connect(actualizar_vida)
		# Actualizar vida inicial
		actualizar_vida(personaje.vida_actual, personaje.vida_maxima)
		print("✅ HUD conectado correctamente al personaje")
	else:
		print("❌ ERROR: No se encontró el personaje")
		print("Intentando buscar con otros nombres...")
		
		# Intentar con nombres alternativos comunes
		personaje = get_parent().get_node_or_null("CharacterBody2D")
		if not personaje:
			personaje = get_parent().get_node_or_null("Player")
		if not personaje:
			personaje = get_parent().get_node_or_null("Mascara")
		
		if personaje:
			personaje.vida_cambiada.connect(actualizar_vida)
			actualizar_vida(personaje.vida_actual, personaje.vida_maxima)
			print("✅ HUD conectado a:", personaje.name)
		else:
			print("❌ No se pudo conectar. Nodos disponibles:")
			for child in get_parent().get_children():
				print("  - ", child.name, " (", child.get_class(), ")")

func actualizar_vida(vida_nueva, vida_max):
	print("Actualizando HUD - Vida: ", vida_nueva, "/", vida_max)
	
	health_bar.max_value = vida_max
	health_bar.value = vida_nueva
	health_label.text = "Vida: " + str(vida_nueva) + " / " + str(vida_max)
	
	# Detectar Game Over
	if vida_nueva <= 0:
		mostrar_game_over()
		return
	
	var porcentaje = float(vida_nueva) / float(vida_max)
	
	if porcentaje > 0.6:
		health_bar.modulate = Color(0.2, 1.0, 0.2)
	elif porcentaje > 0.3:
		health_bar.modulate = Color(1.0, 0.8, 0.0)
	else:
		health_bar.modulate = Color(1.0, 0.2, 0.2)

func mostrar_game_over():
	print("¡La máscara ha muerto! Game Over")
	
	# Obtener el tamaño de la pantalla
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Crear un contenedor central
	var game_over_container = Control.new()
	game_over_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_container.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(game_over_container)
	
	# Fondo semi-transparente SUAVE (más claro y menos opaco)
	var fondo = ColorRect.new()
	fondo.color = Color(0, 0, 0, 0.3)  # ✅ Cambié de 0.85 a 0.3 (mucho más sutil)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_container.add_child(fondo)
	
	# Contenedor centrado
	var center_container = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_container.add_child(center_container)
	
	# VBox dentro del centro
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", int(viewport_size.y * 0.05))
	center_container.add_child(vbox)
	
	# Imagen "GAME OVER" - MÁS GRANDE (60% ancho, 35% alto)
	var game_over_image = TextureRect.new()
	game_over_image.texture = load("res://Assets/UI/GAME OVER.png")
	game_over_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	game_over_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	game_over_image.custom_minimum_size = Vector2(viewport_size.x * 0.6, viewport_size.y * 0.35)  # ✅ Más grande
	vbox.add_child(game_over_image)
	
	# Botón "RESTART" - MÁS GRANDE (40% ancho, 15% alto)
	var restart_button = TextureButton.new()
	restart_button.texture_normal = load("res://Assets/UI/RESTART.png")
	restart_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	restart_button.ignore_texture_size = true
	restart_button.custom_minimum_size = Vector2(viewport_size.x * 0.4, viewport_size.y * 0.15)  # ✅ Más grande
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var button_container = CenterContainer.new()
	button_container.add_child(restart_button)
	vbox.add_child(button_container)
	
	# Conectar el botón
	restart_button.pressed.connect(_on_restart_pressed)
	
	# Pausar el juego
	get_tree().paused = true

func _on_restart_pressed():
	print("🔄 Botón REINICIAR presionado")
	# Despausar el juego
	get_tree().paused = false
	# Cargar la escena principal
	get_tree().change_scene_to_file("res://escenas/escena_principal.tscn")
