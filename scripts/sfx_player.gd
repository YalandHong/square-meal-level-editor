extends Node
#class_name SfxPlayer

'''
全局sfx音效播放器
'''

# 存储音效文件路径的字典
var SFX_STREAMS: Dictionary = {
    "eat": preload("res://sounds/sfx/eat.wav"),
    "explode": preload("res://sounds/sfx/explode.wav"),
    "spit": preload("res://sounds/sfx/spit.wav"),
    "die": preload("res://sounds/sfx/die.wav"),
    "stun": preload("res://sounds/sfx/stun.wav"),
    "block_stops": preload("res://sounds/sfx/block_stops.wav"),
    "win": preload("res://sounds/sfx/win.wav"),
    "wood_break": preload("res://sounds/sfx/wood_break.wav"),
    "rubble_bounce": preload("res://sounds/sfx/rubber_bounce.wav"),
}

# 存储每个音效对应的 AudioStreamPlayer
var active_players: Dictionary = {}

# 播放音效的方法
func play_sfx(sound_name: String):
    if not SFX_STREAMS.has(sound_name):
        print("Error: Sound", sound_name, "not found in sfx_files.")
        return
    var audio_stream = SFX_STREAMS[sound_name]

    # 获取或创建 AudioStreamPlayer
    var audio_player: AudioStreamPlayer
    if active_players.has(sound_name):
        audio_player = active_players[sound_name]
    else:
        audio_player = AudioStreamPlayer.new()
        active_players[sound_name] = audio_player
        add_child(audio_player)
        audio_player.stream = audio_stream

    # 如果该音效正在播放，先停止
    if audio_player.is_playing():
        audio_player.stop()
    audio_player.play()
