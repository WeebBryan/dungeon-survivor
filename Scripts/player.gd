extends CharacterBody2D

# ============================================================
# CENAS EXPORTADAS
# ============================================================

@export var floating_text_scene: PackedScene
@export var bullet_scene: PackedScene
@export var slash_scene: PackedScene


# ============================================================
# ANIMAÇÕES DAS CLASSES
# ============================================================

@export var mage_frames: SpriteFrames
@export var duelist_frames: SpriteFrames


# ============================================================
# CLASSES
# ============================================================

const CLASS_MAGE = "mage"
const CLASS_DUELIST = "duelist"

const CLASS_STATS = {
	"mage": {
		"max_health": 80,
		"speed": 280.0,
		"projectile_damage": 3,
		"fire_rate": 0.2,
		"bullet_speed_multiplier": 1.0
	},
	"duelist": {
		"max_health": 150,
		"speed": 350.0,
		"sword_damage": 8,
		"attack_speed": 0.3,
		"sword_range": 150.0
	}
}

var player_class = CLASS_MAGE


# ============================================================
# MOVIMENTAÇÃO
# ============================================================

@export var speed = 300.0

@export var dash_speed = 900.0
@export var dash_duration = 0.15
@export var dash_cooldown = 0.8

@export var roll_speed = 700.0
@export var roll_duration = 0.5
@export var roll_cooldown = 1.0

# ============================================================
# LIMITES DO MAPA
# ============================================================

@export var map_top_left: Marker2D
@export var map_bottom_right: Marker2D

@export var map_margin = 24.0

var map_min_x = -1000.0
var map_max_x = 1000.0
var map_min_y = -1000.0
var map_max_y = 1000.0


# ============================================================
# VIDA
# ============================================================

var max_health = 100
var health = 100
var invincible = false


# ============================================================
# STAMINA
# ============================================================

var stamina = 100.0
var max_stamina = 100.0

var dash_stamina_cost = 40.0
var roll_stamina_cost = 20.0


# ============================================================
# LEVEL / XP
# ============================================================

var level = 1
var current_xp = 0
var xp_to_next_level = 5


# ============================================================
# ESTATÍSTICAS DA PARTIDA
# ============================================================

var enemies_killed = 0
var bosses_killed = 0
var survival_time = 0.0


# ============================================================
# COMBATE GERAL
# ============================================================

var attacking = false


# ============================================================
# MAGO
# ============================================================

var projectile_damage = 3
var fire_rate = 0.2
var bullet_speed_multiplier = 1.0
var can_shoot = true


# ============================================================
# DUELISTA
# ============================================================

var sword_damage = 8
var attack_speed = 0.3
var sword_range = 150.0


# ============================================================
# ESTADO DO DASH
# ============================================================

var is_dashing = false
var dash_timer = 0.0
var dash_direction = Vector2.ZERO
var cooldown_timer = 0.0

var sprite_base_scale = Vector2.ONE


# ============================================================
# ESTADO DA CAMBALHOTA / TELEPORTE
# ============================================================

var is_rolling = false
var roll_timer = 0.0
var roll_direction = Vector2.ZERO
var roll_cooldown_timer = 0.0


# ============================================================
# SISTEMA DE UPGRADES
# ============================================================

var current_upgrade_choices = []

var upgrade_button_1
var upgrade_button_2
var upgrade_button_3


# ============================================================
# REFERÊNCIAS DE NÓS
# ============================================================

var player_collision

var level_panel
var xp_bar
var level_label
var stamina_bar
var health_label
var health_bar
var game_over_panel


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	player_class = PlayerData.selected_class

	player_collision = $CollisionShape2D

	get_ui_references()

	setup_class()
	setup_map_limits()
	sprite_base_scale = $Sprite2D.scale

	update_ui()
	update_health_label()


func update_health_label():

	if health_label:

		health_label.text = "Vida: " + str(health) + " / " + str(max_health)

func get_ui_references():

	health_label = get_tree().get_first_node_in_group("health_label")
	health_bar = get_tree().get_first_node_in_group("player_health_bar")
	level_panel = get_tree().get_first_node_in_group("level_panel")
	xp_bar = get_tree().get_first_node_in_group("xp_bar")
	level_label = get_tree().get_first_node_in_group("level_label")
	stamina_bar = get_tree().get_first_node_in_group("stamina_bar")
	game_over_panel = get_tree().get_first_node_in_group("game_over_panel")

	if level_panel:

		upgrade_button_1 = level_panel.get_node_or_null("VBoxContainer/SpeedButton")
		upgrade_button_2 = level_panel.get_node_or_null("VBoxContainer/DashButton")
		upgrade_button_3 = level_panel.get_node_or_null("VBoxContainer/DamageButton")


# ============================================================
# CONFIGURAÇÃO INICIAL DA CLASSE
# ============================================================

func setup_class():

	if !CLASS_STATS.has(player_class):

		player_class = CLASS_MAGE

	var stats = CLASS_STATS[player_class]

	max_health = stats["max_health"]
	health = max_health
	speed = stats["speed"]

	if player_class == CLASS_MAGE:

		projectile_damage = stats["projectile_damage"]
		fire_rate = stats["fire_rate"]
		bullet_speed_multiplier = stats["bullet_speed_multiplier"]

	elif player_class == CLASS_DUELIST:

		sword_damage = stats["sword_damage"]
		attack_speed = stats["attack_speed"]
		sword_range = stats["sword_range"]
	
	setup_class_animation()



# ============================================================
# ANIMAÇÕES DO PLAYER
# ============================================================

func setup_class_animation():

	if player_class == CLASS_MAGE:

		if mage_frames:

			$Sprite2D.sprite_frames = mage_frames

	elif player_class == CLASS_DUELIST:

		if duelist_frames:

			$Sprite2D.sprite_frames = duelist_frames

	play_player_animation("idle")


func play_player_animation(animation_name):

	if $Sprite2D.sprite_frames == null:
		return

	if !$Sprite2D.sprite_frames.has_animation(animation_name):
		return

	if $Sprite2D.animation == animation_name:
		return

	$Sprite2D.play(animation_name)


func update_player_animation(direction):

	if direction != Vector2.ZERO:

		play_player_animation("walk")

		if direction.x != 0:

			$Sprite2D.flip_h = direction.x < 0

	else:

		play_player_animation("idle")



# ============================================================
# LOOP PRINCIPAL
# ============================================================

func _physics_process(delta):

	survival_time += delta

	handle_attack_input()
	handle_cooldowns(delta)
	handle_stamina_regeneration(delta)

	var direction = get_movement_direction()

	if is_rolling:

		update_player_animation(roll_direction)

		process_roll(delta)

		return

	if is_dashing:

		update_player_animation(dash_direction)

		process_dash(delta)

	else:

		update_player_animation(direction)

		process_normal_movement(direction)
		handle_dash_input(direction)
		handle_roll_or_teleport_input(direction)

	update_ui()

	move_and_slide()
	clamp_to_map()


func get_movement_direction():

	return Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)


# ============================================================
# INPUT DE ATAQUE
# ============================================================

func handle_attack_input():

	if !Input.is_action_pressed("shoot"):
		return

	if player_class == CLASS_MAGE:

		shoot()

	elif player_class == CLASS_DUELIST:

		sword_attack()


# ============================================================
# COOLDOWNS / STAMINA
# ============================================================

func handle_cooldowns(delta):

	if cooldown_timer > 0:
		cooldown_timer -= delta

	if roll_cooldown_timer > 0:
		roll_cooldown_timer -= delta


func handle_stamina_regeneration(delta):

	stamina += 25 * delta
	stamina = min(stamina, max_stamina)


# ============================================================
# MOVIMENTAÇÃO NORMAL
# ============================================================

func process_normal_movement(direction):

	velocity = direction * speed


# ============================================================
# DASH
# ============================================================

func handle_dash_input(direction):

	if !Input.is_action_just_pressed("dash"):
		return

	if direction == Vector2.ZERO:
		return

	if cooldown_timer > 0:
		return

	if stamina < dash_stamina_cost:
		return

	stamina -= dash_stamina_cost

	is_dashing = true
	dash_timer = dash_duration
	dash_direction = direction
	cooldown_timer = dash_cooldown

	update_ui()


func process_dash(delta):

	dash_timer -= delta

	velocity = dash_direction * dash_speed

	$Sprite2D.scale = Vector2(
		sprite_base_scale.x * 1.3,
		sprite_base_scale.y * 0.8
	)

	if dash_timer <= 0:

		is_dashing = false

		$Sprite2D.scale = sprite_base_scale


# ============================================================
# CAMBALHOTA / TELEPORTE
# ============================================================

func handle_roll_or_teleport_input(direction):

	if !Input.is_action_just_pressed("roll"):
		return

	if roll_cooldown_timer > 0:
		return

	if stamina < roll_stamina_cost:
		return

	if direction == Vector2.ZERO:
		return

	stamina -= roll_stamina_cost

	roll_cooldown_timer = roll_cooldown

	update_ui()

	if player_class == CLASS_MAGE:

		teleport(direction)

	elif player_class == CLASS_DUELIST:

		start_roll(direction)


func start_roll(direction):

	if direction == Vector2.ZERO:
		return

	is_rolling = true
	roll_timer = roll_duration
	roll_direction = direction

	player_collision.disabled = true
	invincible = true

	var tween = create_tween()

	tween.tween_property(
		$Sprite2D,
		"modulate:a",
		0.3,
		0.1
	)


func process_roll(delta):

	roll_timer -= delta

	velocity = roll_direction * roll_speed

	if roll_timer <= 0:

		is_rolling = false

		player_collision.disabled = false
		invincible = false

		var tween = create_tween()

		tween.tween_property(
			$Sprite2D,
			"modulate:a",
			1.0,
			0.1
		)

	move_and_slide()


func teleport(teleport_direction):

	if teleport_direction == Vector2.ZERO:
		return

	var teleport_distance = 250

	invincible = true

	var ghost = $Sprite2D.duplicate()

	get_parent().add_child(ghost)

	ghost.global_position = global_position
	ghost.modulate.a = 0.5

	global_position += teleport_direction.normalized() * teleport_distance
	clamp_to_map()

	
	var tween = ghost.create_tween()

	tween.parallel().tween_property(
		ghost,
		"modulate:a",
		0.0,
		0.3
	)

	tween.parallel().tween_property(
		ghost,
		"scale",
		Vector2(1.2, 1.2),
		0.3
	)

	tween.finished.connect(
		func():
			ghost.queue_free()
	)

	await get_tree().create_timer(0.2).timeout

	$Sprite2D.modulate.a = 1.0

	invincible = false


# ============================================================
# TIRO DO MAGO
# ============================================================

func shoot():

	if !can_shoot:
		return

	if bullet_scene == null:
		return

	can_shoot = false

	var bullet = bullet_scene.instantiate()

	get_parent().add_child(bullet)

	bullet.global_position = global_position

	bullet.damage = projectile_damage
	bullet.speed_multiplier = bullet_speed_multiplier

	bullet.direction = (
		get_global_mouse_position()
		- global_position
	).normalized()

	bullet.rotation = bullet.direction.angle()

	await get_tree().create_timer(fire_rate).timeout

	can_shoot = true


# ============================================================
# ATAQUE DO DUELISTA
# ============================================================

func sword_attack():

	if attacking:
		return

	var audio = get_tree().get_first_node_in_group("audio_manager")

	if audio:
		audio.play_slash()

	attacking = true

	var mouse_dir = (
		get_global_mouse_position()
		- global_position
	).normalized()

	create_slash_visual(mouse_dir)

	damage_enemies_in_front(mouse_dir)

	await get_tree().create_timer(attack_speed).timeout

	attacking = false


func create_slash_visual(mouse_dir):

	if slash_scene == null:
		return

	var slash = slash_scene.instantiate()

	get_parent().add_child(slash)

	slash.global_position = global_position + mouse_dir * 70

	slash.rotation = mouse_dir.angle()


func damage_enemies_in_front(attack_direction):

	var enemies = get_tree().get_nodes_in_group("enemy")

	for enemy in enemies:

		var enemy_direction = (
			enemy.global_position
			- global_position
		).normalized()

		var distance_to_enemy = global_position.distance_to(
			enemy.global_position
		)

		var dot = attack_direction.dot(enemy_direction)

		if distance_to_enemy <= sword_range and dot > 0.5:

			enemy.take_damage(sword_damage)


# ============================================================
# RECEBER DANO
# ============================================================

func take_damage(amount):

	if invincible:
		return

	invincible = true

	health -= amount

	update_health_label()

	print("Vida:", health)

	$Sprite2D.modulate = Color(1, 0.3, 0.3)

	if health <= 0:

		game_over()

		return

	await damage_flash()

	$Sprite2D.modulate = Color.WHITE

	invincible = false


func damage_flash():

	for i in range(5):

		$Sprite2D.modulate.a = 0.3

		await get_tree().create_timer(0.1).timeout

		$Sprite2D.modulate.a = 1.0

		await get_tree().create_timer(0.1).timeout

# ============================================================
# XP / LEVEL UP
# ============================================================

func gain_xp(amount):

	current_xp += amount

	update_ui()

	print("XP:", current_xp)

	if current_xp >= xp_to_next_level:

		level_up()


func level_up():

	var audio = get_tree().get_first_node_in_group("audio_manager")

	if audio:
		audio.play_levelup()

	level += 1

	current_xp -= xp_to_next_level

	xp_to_next_level += 5

	update_ui()

	show_levelup_text()

	print("LEVEL UP!")

	show_levelup_panel()

	get_tree().paused = true


func show_levelup_panel():

	if level_panel == null:
		return

	prepare_upgrade_choices()

	level_panel.visible = true


func show_levelup_text():

	if floating_text_scene == null:
		return

	var text = floating_text_scene.instantiate()

	get_parent().add_child(text)

	text.global_position = global_position + Vector2(0, -80)

	text.modulate = Color(0.3, 1.0, 0.3)

	text.setup("LEVEL " + str(level) + "!")


func levelup_flash():

	$Sprite2D.modulate = Color(1.8, 1.8, 0.5)

	await get_tree().create_timer(0.2).timeout

	$Sprite2D.modulate = Color.WHITE


# ============================================================
# SISTEMA DE UPGRADES
# ============================================================

func get_upgrade_pool():

	var upgrades = []

	# =========================
	# UPGRADES GERAIS
	# =========================

	upgrades.append({
		"id": "move_speed",
		"text": "+25 Velocidade"
	})

	upgrades.append({
		"id": "max_stamina",
		"text": "+20 Stamina Máxima"
	})

	upgrades.append({
		"id": "dash_cooldown",
		"text": "-15% Cooldown do Dash"
	})

	upgrades.append({
		"id": "dash_cost",
		"text": "-10 Custo do Dash"
	})

	upgrades.append({
		"id": "heal",
		"text": "+30 de Vida"
	})

	# =========================
	# UPGRADES DO MAGO
	# =========================

	if player_class == CLASS_MAGE:

		upgrades.append({
			"id": "mage_damage",
			"text": "+1 Dano do Projétil"
		})

		upgrades.append({
			"id": "mage_fire_rate",
			"text": "+10% Cadência"
		})

		upgrades.append({
			"id": "mage_bullet_speed",
			"text": "+25% Velocidade Projétil"
		})

		upgrades.append({
			"id": "teleport_cooldown",
			"text": "-15% Cooldown Teleporte"
		})

		upgrades.append({
			"id": "teleport_cost",
			"text": "-5 Custo Teleporte"
		})

	# =========================
	# UPGRADES DO DUELISTA
	# =========================

	elif player_class == CLASS_DUELIST:

		upgrades.append({
			"id": "duelist_damage",
			"text": "+2 Dano da Espada"
		})

		upgrades.append({
			"id": "duelist_attack_speed",
			"text": "+10% Velocidade Ataque"
		})

		upgrades.append({
			"id": "duelist_range",
			"text": "+20 Alcance Espada"
		})

		upgrades.append({
			"id": "duelist_health",
			"text": "+25 Vida Máxima"
		})

		upgrades.append({
			"id": "roll_cooldown",
			"text": "-15% Cooldown Cambalhota"
		})

		upgrades.append({
			"id": "roll_cost",
			"text": "-5 Custo Cambalhota"
		})

	return upgrades


func prepare_upgrade_choices():

	var pool = get_upgrade_pool()

	pool.shuffle()

	current_upgrade_choices.clear()

	for i in range(3):

		current_upgrade_choices.append(pool[i])

	if upgrade_button_1:

		upgrade_button_1.text = current_upgrade_choices[0]["text"]

	if upgrade_button_2:

		upgrade_button_2.text = current_upgrade_choices[1]["text"]

	if upgrade_button_3:

		upgrade_button_3.text = current_upgrade_choices[2]["text"]


func choose_upgrade(index):

	if index >= current_upgrade_choices.size():
		return

	var upgrade_id = current_upgrade_choices[index]["id"]

	apply_upgrade(upgrade_id)

	print("Upgrade aplicado: ", upgrade_id)

	close_levelup_panel()


func apply_upgrade(upgrade_id):

	match upgrade_id:

		"move_speed":

			speed += 25

		"max_stamina":

			max_stamina += 20
			stamina = max_stamina

		"dash_cooldown":

			dash_cooldown = max(dash_cooldown * 0.85, 0.25)

		"dash_cost":

			dash_stamina_cost = max(dash_stamina_cost - 10, 10)

		"heal":

			health += 30

		"mage_damage":

			projectile_damage += 1

		"mage_fire_rate":

			fire_rate = max(fire_rate * 0.90, 0.05)

		"mage_bullet_speed":

			bullet_speed_multiplier += 0.25

		"teleport_cooldown":

			roll_cooldown = max(roll_cooldown * 0.85, 0.25)

		"teleport_cost":

			roll_stamina_cost = max(roll_stamina_cost - 5, 5)

		"duelist_damage":

			sword_damage += 2

		"duelist_attack_speed":

			attack_speed = max(attack_speed * 0.90, 0.08)

		"duelist_range":

			sword_range += 20

		"duelist_health":

			max_health += 25
			health += 25

		"roll_cooldown":

			roll_cooldown = max(roll_cooldown * 0.85, 0.25)

		"roll_cost":

			roll_stamina_cost = max(roll_stamina_cost - 5, 5)

	update_ui()
	update_health_label()


# ============================================================
# BOTÕES DO LEVEL UP
# ============================================================

func _on_speed_button_pressed() -> void:

	choose_upgrade(0)


func _on_dash_button_pressed() -> void:

	choose_upgrade(1)


func _on_damage_button_pressed() -> void:

	choose_upgrade(2)


func close_levelup_panel():

	if level_panel:

		level_panel.visible = false

	get_tree().paused = false

	levelup_flash()

	update_ui()
	update_health_label()




# ============================================================
# UI
# ============================================================

func update_ui():

	if health_bar:

		var displayed_max_health = max(health, max_health)

		health_bar.max_value = displayed_max_health
		health_bar.value = health

	if stamina_bar:

		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina

	if xp_bar:

		xp_bar.max_value = xp_to_next_level
		xp_bar.value = current_xp

	if level_label:

		level_label.text = "Nível: " + str(level)


# ============================================================
# GAME OVER
# ============================================================

func game_over():

	print("GAME OVER")

	if game_over_panel:

		game_over_panel.visible = true

	get_tree().paused = true


func setup_map_limits():

	if map_top_left == null:
		print("Map Top Left não foi definido no Player")
		return

	if map_bottom_right == null:
		print("Map Bottom Right não foi definido no Player")
		return

	map_min_x = map_top_left.global_position.x + map_margin
	map_max_x = map_bottom_right.global_position.x - map_margin

	map_min_y = map_top_left.global_position.y + map_margin
	map_max_y = map_bottom_right.global_position.y - map_margin

	print("LIMITES DO MAPA:")
	print("X: ", map_min_x, " até ", map_max_x)
	print("Y: ", map_min_y, " até ", map_max_y)


func clamp_to_map():

	global_position.x = clamp(
		global_position.x,
		map_min_x,
		map_max_x
	)

	global_position.y = clamp(
		global_position.y,
		map_min_y,
		map_max_y
	)


# ============================================================
# RECOMPENSA DO BOSS
# ============================================================

func show_boss_reward(boss_position):

	if floating_text_scene == null:
		return

	var text = floating_text_scene.instantiate()

	get_parent().add_child(text)

	text.global_position = boss_position

	text.modulate = Color(1.0, 0.9, 0.2)

	text.setup("BOSS DERROTADO!\n+20 XP\n+30 VIDA")
