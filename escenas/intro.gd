extends Node2D

# Configura aquí el tiempo de espera y la ruta de la escena
@export var tiempo_espera: float = 60.0
@export var siguiente_escena: String = "res://escenas/escena_principal.tscn"

var clics = 0

func _ready():
	# Inicia el conteo automático por si el jugador no hace nada
	await get_tree().create_timer(tiempo_espera).timeout
	saltar_escena()

func _input(event):
	# Detecta si el jugador hace clic izquierdo
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clics += 1
		
		if clics == 1:
			# Si solo hizo un clic, esperamos un poquito para ver si hace el segundo
			await get_tree().create_timer(0.3).timeout
			clics = 0 # Si pasaron 0.3s y no hizo el segundo, reiniciamos
		
		elif clics == 2:
			# ¡Doble clic detectado!
			saltar_escena()

func saltar_escena():
	# Usamos 'change_scene_to_file' para movernos de escena
	# (Asegúrate de que la ruta sea correcta)
	get_tree().change_scene_to_file(siguiente_escena)
