extends Node2D

func _ready():
	var personaje = $Personaje
	var hud = $HUD
	
	# Conectar señales
	personaje.vida_cambiada.connect(hud.actualizar_vida)
	personaje.mascara_muerta.connect(hud.mostrar_game_over)
	
	# Inicializar la UI
	hud.actualizar_vida(personaje.vida_actual, personaje.vida_maxima)
