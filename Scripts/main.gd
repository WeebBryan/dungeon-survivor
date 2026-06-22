extends Node2D

# ============================================================
# REFERÊNCIAS
# ============================================================

@onready var music_player = $MusicPlayer
@onready var player = $Player
@onready var level_up_panel = $UI/LevelUpPanel


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func start_game_music():

	if music_player == null:
		return

	if !music_player.playing:
		music_player.play()


func _ready():

	get_tree().paused = false
	start_game_music()

	var tutorial_panel = get_tree().get_first_node_in_group("tutorial_panel")

	if tutorial_panel:

		tutorial_panel.visible = true

		get_tree().paused = true


# ============================================================
# BOTÕES DO LEVEL UP
# ============================================================

func _on_speed_button_pressed():

	if player:

		player._on_speed_button_pressed()


func _on_dash_button_pressed():

	if player:

		player._on_dash_button_pressed()


func _on_damage_button_pressed():

	if player:

		player._on_damage_button_pressed()


# ============================================================
# FECHAR PAINEL DE LEVEL UP
# ============================================================

func close_levelup():

	if level_up_panel:

		level_up_panel.visible = false

	get_tree().paused = false
