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
	print("Actualizando HUD - Vida: ", vida_nueva, "/", vida_max)  # Debug
	
	health_bar.max_value = vida_max
	health_bar.value = vida_nueva
	health_label.text = "Vida: " + str(vida_nueva) + " / " + str(vida_max)
	
	var porcentaje = float(vida_nueva) / float(vida_max)
	
	if porcentaje > 0.6:
		health_bar.modulate = Color(0.2, 1.0, 0.2)
	elif porcentaje > 0.3:
		health_bar.modulate = Color(1.0, 0.8, 0.0)
	else:
		health_bar.modulate = Color(1.0, 0.2, 0.2)

func mostrar_game_over():
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.add_theme_font_size_override("font_size", 72)
	game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_label.size = get_viewport().size
	add_child(game_over_label)
