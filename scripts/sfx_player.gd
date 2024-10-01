extends Node
class_name SfxPlayer

# 存储音效文件路径的字典
var sfx_files: Dictionary = {
    "eat": "res://sounds/sfx/eat.wav",
    "explode": "res://sounds/sfx/explode.wav",
    "spit": "res://sounds/sfx/spit.wav",
    "die": "res://sounds/sfx/die.wav",
    "stun": "res://sounds/sfx/stun.wav",
    "block_stops": "res://sounds/sfx/block_stops.wav",
    "win": "res://sounds/sfx/win.wav",
    "wood_break": "res://sounds/sfx/wood_break.wav",
}

# 存储每个音效对应的 AudioStreamPlayer
var active_players: Dictionary = {}

# 播放音效的方法
func play_sfx(sound_name: String):
    if not sfx_files.has(sound_name):
        print("Error: Sound", sound_name, "not found in sfx_files.")
        return

    # 获取或创建 AudioStreamPlayer
    var audio_player: AudioStreamPlayer

    if active_players.has(sound_name):
        audio_player = active_players[sound_name]
    else:
        audio_player = AudioStreamPlayer.new()
        active_players[sound_name] = audio_player
        add_child(audio_player)

    var sfx_path = sfx_files[sound_name]
    var audio_stream = load(sfx_path)

    if audio_stream == null:
        print("Error: Failed to load sound at path:", sfx_path)
        return

    # 如果该音效正在播放，先停止
    if audio_player.is_playing():
        audio_player.stop()

    audio_player.stream = audio_stream
    audio_player.play()
