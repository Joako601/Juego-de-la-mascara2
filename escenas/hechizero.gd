extends CharacterBody2D # Ahora el script sabe qué es el suelo

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("idle_hechicero") # Asegúrate que el nombre coincida con tu panel de animaciones

func _physics_process(delta):
	# Aplicar gravedad si no está tocando el suelo
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	# Mover al personaje y procesar colisiones
	move_and_slide()
