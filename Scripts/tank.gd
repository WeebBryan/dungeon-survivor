extends CharacterBody2D

# ============================================================
# CONFIGURAÇÕES BÁSICAS
# ============================================================

@export var speed = 70.0
@export var health = 10
@export var damage = 15
@export var xp_drop = 3


# ============================================================
# CENAS EXPORTADAS
# ============================================================

@export var xp_scene: PackedScene
@export var damage_text_scene: PackedScene


# ============================================================
# REFERÊNCIAS
# ============================================================

@onready var health_bar = $ProgressBar

var player


# ============================================================
# ESTADO
# ============================================================

var dead = false


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	player = get_tree().get_first_node_in_group("player")

	setup_health_bar()


func setup_health_bar():

	if health_bar == null:
		return

	health_bar.visible = false
	health_bar.max_value = health
	health_bar.value = health


# ============================================================
# ANIMAÇÃO
# ============================================================

func play_enemy_animation(animation_name):

	if $Sprite2D.sprite_frames == null:
		return

	if !$Sprite2D.sprite_frames.has_animation(animation_name):
		return

	if $Sprite2D.animation == animation_name:
		return

	$Sprite2D.play(animation_name)


func update_enemy_animation():

	if velocity.length() > 0.1:

		play_enemy_animation("walk")

		if velocity.x != 0:

			$Sprite2D.flip_h = velocity.x < 0

	else:

		play_enemy_animation("idle")

# ============================================================
# LOOP PRINCIPAL
# ============================================================

func _physics_process(_delta):

	if dead:
		return

	if player == null:
		return

	follow_player()

	update_enemy_animation()

	move_and_slide()


func follow_player():

	var direction = (
		player.global_position - global_position
	).normalized()

	velocity = direction * speed


# ============================================================
# COLISÃO COM PLAYER
# ============================================================

func _on_hitbox_body_entered(body):

	if dead:
		return

	if body.is_in_group("player"):

		body.take_damage(damage)


# ============================================================
# RECEBER DANO
# ============================================================

func take_damage(amount):

	if dead:
		return

	play_hit_sound()

	spawn_damage_text(amount)

	flash_damage()

	health -= amount

	update_health_bar()

	if health <= 0:

		die()


func spawn_damage_text(amount):

	if damage_text_scene == null:
		return

	var text = damage_text_scene.instantiate()

	get_parent().add_child(text)

	text.global_position = global_position + Vector2(0, -40)

	text.setup(amount)


func flash_damage():

	$Sprite2D.modulate = Color.RED

	await get_tree().create_timer(0.1).timeout

	if !dead:

		$Sprite2D.modulate = Color.WHITE


func update_health_bar():

	if health_bar == null:
		return

	health_bar.visible = true
	health_bar.value = health


# ============================================================
# MORTE
# ============================================================

func die():

	if dead:
		return

	dead = true

	play_death_sound()

	reward_player()

	spawn_xp()

	await death_animation()

	call_deferred("queue_free")


func reward_player():

	var player_ref = get_tree().get_first_node_in_group("player")

	if player_ref:

		player_ref.enemies_killed += 1


func spawn_xp():

	if xp_scene == null:
		return

	for i in range(xp_drop):

		var xp = xp_scene.instantiate()

		xp.global_position = global_position + Vector2(
			randf_range(-20, 20),
			randf_range(-20, 20)
		)

		get_parent().call_deferred("add_child", xp)


func death_animation():

	var tween = create_tween()

	tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ZERO,
		0.2
	)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		0.2
	)

	await tween.finished


# ============================================================
# ÁUDIO
# ============================================================

func play_hit_sound():

	var audio = get_tree().get_first_node_in_group("audio_manager")

	if audio:

		audio.play_hit()


func play_death_sound():

	var audio = get_tree().get_first_node_in_group("audio_manager")

	if audio:

		audio.play_death()
