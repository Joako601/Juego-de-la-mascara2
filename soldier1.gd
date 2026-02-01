extends CharacterBody2D


# ... tus otras variables ...

func _ready() -> void:
	# Buscar el Area2D hijo del soldado
	var area_deteccion = $Area2D  # Ajusta el nombre si es diferente
	
	# Conectar la señal de colisión
	if area_deteccion:
		area_deteccion.body_entered.connect(_on_mascara_colision)

func _on_mascara_colision(body: Node2D) -> void:
	# Verificar si el cuerpo que entró es la máscara
	if body.is_in_group("mascara"):
		print("¡La máscara tocó al soldado!")
		morir()

func morir() -> void:
	print("Soldado murió")
	# Aquí ejecutarás tu animación de muerte
	# Por ahora solo lo destruimos
	queue_free()
