extends CharacterBody2D # Ahora el script sabe qué es el suelo

@onready var sprite = $AnimatedSprite2D
@onready var sonido_final = $Final
func _ready():
	sprite.play("idle_hechicero") # Asegúrate que el nombre coincida con tu panel de animaciones
	sonido_final.volume_db=+40
	
	
@export var escena_nueva : String = "res://escenas/final.tscn"



func cambiar_a_escena_final():
	# Cambia la escena inmediatamente
	var error = get_tree().change_scene_to_file(escena_nueva)
	
	if error != OK:
		print("Error: No se pudo encontrar la escena en la ruta especificada")
	


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("mascara"):
		sonido_final.play()
		print("¡Colisión detectada! Cambiando escena...")
		cambiar_a_escena_final()
