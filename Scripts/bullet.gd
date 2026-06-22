extends Area2D

# ============================================================
# CONFIGURAÇÕES BÁSICAS
# ============================================================

@export var speed = 1000.0
@export var damage = 1
@export var lifetime = 2.0
@export var max_distance = 1200.0


# ============================================================
# MOVIMENTO
# ============================================================

var direction = Vector2.ZERO
var speed_multiplier = 1.0

var start_position = Vector2.ZERO


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	start_position = global_position

	start_lifetime_timer()


func start_lifetime_timer():

	await get_tree().create_timer(lifetime).timeout

	if is_inside_tree():

		queue_free()


# ============================================================
# LOOP PRINCIPAL
# ============================================================

func _process(delta):

	move_bullet(delta)

	check_max_distance()


func move_bullet(delta):

	global_position += direction * speed * speed_multiplier * delta


func check_max_distance():

	var distance_traveled = start_position.distance_to(global_position)

	if distance_traveled >= max_distance:

		queue_free()


# ============================================================
# COLISÃO
# ============================================================

func _on_body_entered(body):

	if body.is_in_group("enemy"):

		body.take_damage(damage)

		queue_free()


# ============================================================
# SAIR DA TELA
# ============================================================

func _on_visible_on_screen_notifier_2d_screen_exited():

	queue_free()
