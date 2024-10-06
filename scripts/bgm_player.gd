extends Node

# 全局bgm播放器
# 使用autoload载入作为全局对象

var menu_song_player: AudioStreamPlayer
var game_song_player: AudioStreamPlayer

func _init() -> void:
    menu_song_player = AudioStreamPlayer.new()
    menu_song_player.stream = preload("res://sounds/music/menu_music.mp3")
    add_child(menu_song_player)

    game_song_player = AudioStreamPlayer.new()
    game_song_player.stream = preload("res://sounds/music/game_music.mp3")
    add_child(game_song_player)

func play_game_song():
    if menu_song_player.is_playing():
        menu_song_player.stop()
    if not game_song_player.is_playing():
        game_song_player.play()

func play_menu_song():
    if game_song_player.is_playing():
        game_song_player.stop()
    if not menu_song_player.is_playing():
        menu_song_player.play()
