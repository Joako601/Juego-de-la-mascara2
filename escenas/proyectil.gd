extends Area2D

var velocidad: float = 300.0
var danio: int = 10
var direccion: Vector2 = Vector2.RIGHT

func _ready():
	# Conectar señales
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Rotar según dirección
	rotation = direccion.angle()
	
	# Autodestruir después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(self):
		queue_free()

func set_direccion(nueva_direccion: Vector2) -> void:
	direccion = nueva_direccion.normalized()
	rotation = direccion.angle()

func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	print("[PROYECTIL] Colisionó con body: ", body.name, " | Grupos: ", body.get_groups())
	
	# Si golpea a la máscara
	if body.is_in_group("mascara"):
		print("[PROYECTIL] ¡Impactó a la máscara! Haciendo ", danio, " de daño")
		if body.has_method("recibir_danio"):
			body.recibir_danio(danio)
			print("[PROYECTIL] Daño aplicado correctamente")
		else:
			print("[PROYECTIL] ERROR: La máscara no tiene método recibir_danio()")
		queue_free()
	# Si golpea paredes u otros objetos
	elif body is TileMap or body is StaticBody2D or body is CharacterBody2D:
		print("[PROYECTIL] Destruido por colisión con objeto sólido")
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	print("[PROYECTIL] Entró en área: ", area.name, " | Grupos: ", area.get_groups())
	
	# Si el área pertenece a la máscara
	if area.is_in_group("mascara"):
		print("[PROYECTIL] ¡Área de la máscara detectada! Haciendo ", danio, " de daño")
		# Buscar el nodo padre que tiene el método recibir_danio
		var mascara = area.get_parent()
		if mascara and mascara.has_method("recibir_danio"):
			mascara.recibir_danio(danio)
			print("[PROYECTIL] Daño aplicado a través del área")
		queue_free()
