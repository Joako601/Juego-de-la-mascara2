extends CharacterBody2D # <--- ESTO ES LO CORRECTO

@onready var sprite = $AnimatedSprite2D

func _ready():
	# Asegúrate de que el nombre sea "idle" o "idle_hechicero"
	sprite.play("idle_hechicero") 

func _physics_process(delta):
	# Aplicar gravedad si no está tocando el suelo
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Mover al personaje y resolver colisiones
	move_and_slide()
