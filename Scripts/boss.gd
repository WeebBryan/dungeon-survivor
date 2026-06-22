extends CharacterBody2D

# ============================================================
# CONFIGURAÇÕES BÁSICAS
# ============================================================

@export var normal_speed = 80.0
@export var damage = 25
@export var health = 100

var max_health = 100
var dead = false
var is_final_boss = false
var boss_info_panel

# ============================================================
# CENAS EXPORTADAS
# ============================================================

@export var damage_text_scene: PackedScene
@export var shockwave_warning_scene: PackedScene
@export var summon_warning_scene: PackedScene

@export var enemy_scene: PackedScene
@export var runner_scene: PackedScene


# ============================================================
# INVESTIDA
# ============================================================

@export var charge_speed = 450.0

var charging = false
var charge_direction = Vector2.ZERO


# ============================================================
# ONDA DE CHOQUE
# ============================================================

@export var shockwave_range = 250.0
@export var shockwave_damage = 35

var using_shockwave = false


# ============================================================
# INVOCAÇÃO DE MINIONS
# ============================================================

var summoning = false


# ============================================================
# REFERÊNCIAS
# ============================================================

var player
var boss_health_bar
var boss_name_label
var boss_sprite_base_scale = Vector2.ONE

# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	get_references()

	boss_sprite_base_scale = $Sprite2D.scale

	setup_boss_animation()

	setup_health_bar()

	create_attack_timer()

	if is_final_boss:
		create_summon_timer()


func get_references():

	player = get_tree().get_first_node_in_group("player")
	boss_info_panel = get_tree().get_first_node_in_group("boss_info_panel")
	boss_health_bar = get_tree().get_first_node_in_group("boss_health_bar")
	boss_name_label = get_tree().get_first_node_in_group("boss_name_label")
	


# ============================================================
# ANIMAÇÕES DO BOSS
# ============================================================

func setup_boss_animation():

	play_boss_animation("idle")


func play_boss_animation(animation_name):

	if $Sprite2D.sprite_frames == null:
		return

	if !$Sprite2D.sprite_frames.has_animation(animation_name):
		return

	if $Sprite2D.animation == animation_name:
		return

	$Sprite2D.play(animation_name)


func update_boss_animation():

	if is_busy():
		return

	if velocity.length() > 0.1:

		play_boss_animation("walk")

		if velocity.x != 0:

			$Sprite2D.flip_h = velocity.x > 0

	else:

		play_boss_animation("idle")





func setup_health_bar():

	if boss_info_panel:
		boss_info_panel.visible = true

	if boss_name_label:
		boss_name_label.visible = true

		if is_final_boss:
			boss_name_label.text = "Lorde Abissal"
		else:
			boss_name_label.text = "Guardião da Cripta"

	if boss_health_bar == null:
		print("BossHealthBar não encontrada. Verifique o grupo boss_health_bar.")
		return

	boss_health_bar.visible = true
	boss_health_bar.max_value = max_health
	boss_health_bar.value = health


func create_attack_timer():

	var attack_timer = Timer.new()

	attack_timer.wait_time = 4.0
	attack_timer.timeout.connect(use_special_attack)
	attack_timer.autostart = true

	add_child(attack_timer)


func create_summon_timer():

	print("CRIANDO TIMER DE MINIONS")

	var summon_timer = Timer.new()

	summon_timer.wait_time = 12.0
	summon_timer.timeout.connect(summon_minions)
	summon_timer.autostart = true

	add_child(summon_timer)


# ============================================================
# LOOP PRINCIPAL
# ============================================================

func _physics_process(_delta):

	if player == null:
		return

	if is_busy():

		move_and_slide()

		return

	follow_player()

	update_boss_animation()

	move_and_slide()


func is_busy():

	return charging or using_shockwave or summoning


func follow_player():

	var direction = (
		player.global_position - global_position
	).normalized()

	velocity = direction * normal_speed


# ============================================================
# ESCOLHA DE HABILIDADE
# ============================================================

func use_special_attack():

	if dead:
		return

	if player == null:
		return

	if is_busy():
		return

	if randf() < 0.5:

		start_charge()

	else:

		shockwave()


# ============================================================
# HABILIDADE 1: INVESTIDA
# ============================================================

func start_charge():

	play_boss_charge_sound()

	if player == null:
		return

	charging = true

	charge_direction = (
		player.global_position - global_position
	).normalized()

	await charge_warning_animation()

	velocity = charge_direction * charge_speed

	await get_tree().create_timer(0.5).timeout

	charging = false


func charge_warning_animation():

	# Pisca vermelho.
	var tween = create_tween()

	tween.set_loops(4)

	tween.tween_property(
		$Sprite2D,
		"modulate",
		Color(1, 0.3, 0.3),
		0.1
	)

	tween.tween_property(
		$Sprite2D,
		"modulate",
		Color.WHITE,
		0.1
	)

	# Cresce e treme antes da investida.
	$Sprite2D.scale = Vector2(1.4, 1.4)

	for i in range(16):

		$Sprite2D.position = Vector2(
			randf_range(-4, 4),
			randf_range(-4, 4)
		)

		await get_tree().create_timer(0.05).timeout

	reset_sprite_visual()


# ============================================================
# HABILIDADE 2: ONDA DE CHOQUE
# ============================================================

func shockwave():

	play_boss_charge_sound()

	using_shockwave = true
	velocity = Vector2.ZERO

	create_shockwave_warning()

	await shockwave_charge_animation()

	await shockwave_explosion_animation()

	deal_shockwave_damage()

	using_shockwave = false


func create_shockwave_warning():

	if shockwave_warning_scene == null:
		return

	var warning = shockwave_warning_scene.instantiate()

	get_parent().add_child(warning)

	warning.global_position = global_position
	warning.radius = shockwave_range


func shockwave_charge_animation():

	for i in range(8):

		$Sprite2D.modulate = Color(1, 0.2, 0.2)

		await get_tree().create_timer(0.1).timeout

		$Sprite2D.modulate = Color.WHITE

		await get_tree().create_timer(0.1).timeout


func shockwave_explosion_animation():

	var tween = create_tween()

	tween.tween_property(
		$Sprite2D,
		"scale",
		Vector2(2.0, 2.0),
		0.1
	)

	await tween.finished

	$Sprite2D.scale = Vector2.ONE

	$Sprite2D.modulate = Color(1.5, 1.5, 1.5)

	await get_tree().create_timer(0.05).timeout

	$Sprite2D.modulate = Color.WHITE


func deal_shockwave_damage():

	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= shockwave_range:

		player.take_damage(shockwave_damage)


# ============================================================
# HABILIDADE 3: INVOCAÇÃO DE MINIONS
# ============================================================

func summon_minions():

	if dead:
		return

	if player == null:
		return

	if enemy_scene == null:
		return

	if runner_scene == null:
		return

	if summoning:
		return

	print("BOSS INVOCANDO MINIONS")

	summoning = true
	velocity = Vector2.ZERO

	play_boss_charge_sound()

	await summon_charge_animation()

	var pos1 = global_position + Vector2(-120, -60)
	var pos2 = global_position + Vector2(120, -60)
	var pos3 = global_position + Vector2(0, 120)

	var warning1 = create_summon_warning(pos1)
	var warning2 = create_summon_warning(pos2)
	var warning3 = create_summon_warning(pos3)

	await get_tree().create_timer(0.8).timeout

	remove_summon_warning(warning1)
	remove_summon_warning(warning2)
	remove_summon_warning(warning3)

	spawn_minion(enemy_scene, pos1)

	await get_tree().create_timer(0.1).timeout

	spawn_minion(enemy_scene, pos2)

	await get_tree().create_timer(0.1).timeout

	spawn_minion(runner_scene, pos3)

	reset_sprite_visual()

	summoning = false


func summon_charge_animation():

	for i in range(6):

		$Sprite2D.modulate = Color(0.7, 0.2, 1.0)
		$Sprite2D.scale = Vector2(1.2, 1.2)

		$Sprite2D.position = Vector2(
			randf_range(-4, 4),
			randf_range(-4, 4)
		)

		await get_tree().create_timer(0.08).timeout

		reset_sprite_visual()

		await get_tree().create_timer(0.08).timeout


func create_summon_warning(spawn_position):

	if summon_warning_scene == null:
		return null

	var warning = summon_warning_scene.instantiate()

	get_parent().add_child(warning)

	warning.global_position = spawn_position

	return warning


func remove_summon_warning(warning):

	if is_instance_valid(warning):

		warning.queue_free()


func spawn_minion(scene_to_spawn, spawn_position):

	if scene_to_spawn == null:
		return

	var minion = scene_to_spawn.instantiate()

	get_parent().add_child(minion)

	minion.global_position = spawn_position


# ============================================================
# DANO RECEBIDO
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

	if boss_health_bar == null:
		return

	boss_health_bar.max_value = max_health
	boss_health_bar.value = health


# ============================================================
# MORTE
# ============================================================

func die():

	if dead:
		return

	dead = true

	play_death_sound()

	reward_player()

	hide_health_bar()
	if boss_health_bar:
		boss_health_bar.visible = false

	if boss_name_label:
		boss_name_label.visible = false

	await death_animation()

	queue_free()


func reward_player():

	var player_ref = get_tree().get_first_node_in_group("player")

	if player_ref == null:
		return

	player_ref.bosses_killed += 1
	player_ref.gain_xp(20)

	player_ref.show_boss_reward(global_position)

	player_ref.health += 30
	player_ref.health = min(
		player_ref.health,
		player_ref.max_health
	)

	if player_ref.health_label:

		player_ref.health_label.text = "Vida: " + str(player_ref.health)


func hide_health_bar():

	if boss_health_bar:
		boss_health_bar.visible = false

	if boss_name_label:
		boss_name_label.visible = false

	if boss_info_panel:
		boss_info_panel.visible = false


func death_animation():

	$Sprite2D.modulate = Color(1, 0.2, 0.2)

	var tween = create_tween()

	tween.parallel().tween_property(
		self,
		"scale",
		Vector2.ZERO,
		0.4
	)

	tween.parallel().tween_property(
		self,
		"modulate:a",
		0.0,
		0.4
	)

	await tween.finished


# ============================================================
# COLISÃO COM PLAYER
# ============================================================

func _on_hitbox_body_entered(body):

	if dead:
		return

	if body.is_in_group("player"):

		body.take_damage(damage)


# ============================================================
# ÁUDIO
# ============================================================

func play_boss_charge_sound():

	var audio = get_tree().get_first_node_in_group("audio_manager")

	if audio:

		audio.play_boss_charge()


func play_hit_sound():

	var audio = get_tree().get_first_node_in_group("audio_manager")

	if audio:

		audio.play_hit()


func play_death_sound():

	var audio = get_tree().get_first_node_in_group("audio_manager")

	if audio:

		audio.play_death()


# ============================================================
# UTILITÁRIOS VISUAIS
# ============================================================

func reset_sprite_visual():

	$Sprite2D.position = Vector2.ZERO
	$Sprite2D.scale = Vector2.ONE
	$Sprite2D.modulate = Color.WHITE
