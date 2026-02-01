extends CharacterBody2D
extends Area2D

var velocidad: float = 300.0
var danio: int = 10
var direccion: Vector2 = Vector2.RIGHT

func _ready():
	# Conectar señal de colisión
	body_entered.connect(_on_body_entered)
	
	# Rotar el sprite según la dirección
	rotation = direccion.angle()
	
	# Autodestruir después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	queue_free()

func set_direccion(nueva_direccion: Vector2) -> void:
	direccion = nueva_direccion.normalized()
	rotation = direccion.angle()

func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	# Si golpea a la máscara
	if body.is_in_group("mascara"):
		if body.has_method("recibir_danio"):
			body.recibir_danio(danio)
		queue_free()
	
	# Si golpea cualquier otra cosa sólida
	elif body is TileMap or body is StaticBody2D:
		queue_free()
