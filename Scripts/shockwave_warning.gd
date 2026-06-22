extends Node2D

# ============================================================
# CONFIGURAÇÕES DO AVISO
# ============================================================

@export var radius = 250.0
@export var grow_duration = 1.0
@export var final_alpha = 0.7

@export var fill_color = Color(1, 0, 0, 0.25)
@export var border_color = Color.RED
@export var border_width = 4.0


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	play_warning_animation()


# ============================================================
# LOOP VISUAL
# ============================================================

func _process(_delta):

	queue_redraw()


# ============================================================
# ANIMAÇÃO
# ============================================================

func play_warning_animation():

	scale = Vector2.ZERO
	modulate.a = 1.0

	var tween = create_tween()

	tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ONE,
		grow_duration
	)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		final_alpha,
		grow_duration
	)

	await tween.finished

	queue_free()


# ============================================================
# DESENHO DO CÍRCULO
# ============================================================

func _draw():

	draw_circle(
		Vector2.ZERO,
		radius,
		fill_color
	)

	draw_arc(
		Vector2.ZERO,
		radius,
		0,
		TAU,
		64,
		border_color,
		border_width
	)
