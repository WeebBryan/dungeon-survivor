extends Node2D

# ============================================================
# CONFIGURAÇÕES DO AVISO
# ============================================================

@export var radius = 45.0

@export var grow_duration = 0.25
@export var pulse_speed = 8.0
@export var pulse_strength = 0.12

@export var fill_color = Color(0.7, 0.0, 1.0, 0.45)
@export var border_color = Color(1.0, 0.3, 1.0, 1.0)
@export var border_width = 5.0


# ============================================================
# ESTADO INTERNO
# ============================================================

var pulse_time = 0.0


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	setup_layer()

	play_spawn_animation()


func setup_layer():

	z_index = 100
	z_as_relative = false


# ============================================================
# LOOP VISUAL
# ============================================================

func _process(delta):

	update_pulse(delta)

	queue_redraw()


func update_pulse(delta):

	pulse_time += delta * pulse_speed


# ============================================================
# ANIMAÇÃO
# ============================================================

func play_spawn_animation():

	scale = Vector2.ZERO
	modulate = Color.WHITE

	var tween = create_tween()

	tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		grow_duration
	)


# ============================================================
# DESENHO DO CÍRCULO
# ============================================================

func _draw():

	var pulse = 1.0 + sin(pulse_time) * pulse_strength

	draw_circle(
		Vector2.ZERO,
		radius * pulse,
		fill_color
	)

	draw_arc(
		Vector2.ZERO,
		radius * pulse,
		0,
		TAU,
		64,
		border_color,
		border_width
	)
