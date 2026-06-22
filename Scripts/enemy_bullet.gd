extends Area2D

# ============================================================
# CONFIGURAÇÕES BÁSICAS
# ============================================================

@export var speed = 350.0
@export var damage = 10
@export var lifetime = 5.0


# ============================================================
# MOVIMENTO
# ============================================================

var direction = Vector2.ZERO


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	start_lifetime_timer()


func start_lifetime_timer():

	await get_tree().create_timer(lifetime).timeout

	queue_free()


# ============================================================
# LOOP PRINCIPAL
# ============================================================

func _process(delta):

	move_bullet(delta)


func move_bullet(delta):

	global_position += direction * speed * delta


# ============================================================
# COLISÃO
# ============================================================

func _on_body_entered(body):

	if body.is_in_group("player"):

		body.take_damage(damage)

		queue_free()
