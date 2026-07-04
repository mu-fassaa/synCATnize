extends Node

# CamelCase wrappers to match requirement specifications
func PlaySFX(sfx_name: String):
	play_sfx(sfx_name)

func PlayMusic(music_name: String):
	play_music(music_name)

func StopMusic():
	stop_music()

func FadeMusic(target_volume: float, duration: float):
	fade_music(target_volume, duration)

# Clean, standard GDScript snake_case implementations
func play_sfx(sfx_name: String):
	print("AudioManager (Placeholder): Play SFX -> ", sfx_name)

func play_music(music_name: String):
	print("AudioManager (Placeholder): Play Music -> ", music_name)

func stop_music():
	print("AudioManager (Placeholder): Stop Music")

func fade_music(target_volume: float, duration: float):
	print("AudioManager (Placeholder): Fade Music to ", target_volume, " over ", duration, " seconds")
