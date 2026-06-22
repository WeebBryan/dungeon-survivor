extends Node

# ============================================================
# FUNÇÃO AUXILIAR
# ============================================================

func play_sound(player):

	if player == null:
		return

	player.stop()
	player.play()


# ============================================================
# SONS DO PLAYER
# ============================================================

func play_slash():

	play_sound($SlashPlayer)


func play_levelup():

	play_sound($LevelUpPlayer)


# ============================================================
# SONS DE COMBATE
# ============================================================

func play_hit():

	play_sound($HitPlayer)


func play_death():

	play_sound($DeathPlayer)


# ============================================================
# SONS DE XP
# ============================================================

func play_xp():

	play_sound($XPPlayer)


# ============================================================
# SONS DO BOSS
# ============================================================

func play_boss_charge():

	play_sound($BossChargePlayer)
