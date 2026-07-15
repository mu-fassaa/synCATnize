class_name CutscenePlayer
extends Node

signal cutscene_started(cutscene_name: String)
signal cutscene_finished(cutscene_name: String)

var is_playing: bool = false
var _timeline: Array = []
var _current_step: int = 0
var _cutscene_name: String = ""

func play_cutscene(cutscene_name: String, timeline: Array):
	if is_playing:
		print("CutscenePlayer: Already playing a cutscene.")
		return
		
	is_playing = true
	_cutscene_name = cutscene_name
	_timeline = timeline
	_current_step = 0
	
	print("CutscenePlayer: Starting cutscene '", _cutscene_name, "'")
	EventBus.cutscene_started.emit(_cutscene_name)
	cutscene_started.emit(_cutscene_name)
	
	# Transition game state
	GameManager.current_gameplay_state = GameManager.GameplayState.CUTSCENE
	
	# Auto-freeze player at start of cutscene
	_freeze_player(true)
	
	_execute_next_step()

func _execute_next_step():
	if _current_step >= _timeline.size():
		_finish_cutscene()
		return
		
	var step = _timeline[_current_step]
	_current_step += 1
	
	var step_type = step.get("type", "")
	match step_type:
		"freeze":
			_freeze_player(step.get("value", true))
			_execute_next_step()
			
		"wait":
			var duration = step.get("duration", 1.0)
			get_tree().create_timer(duration).timeout.connect(func():
				_execute_next_step()
			)
			
		"dialogue":
			var speaker = step.get("speaker", "NPC")
			var lines = step.get("lines", [])
			# Standard dialogue event trigger
			EventBus.dialogue_started.emit(speaker, lines)
			# Connect to dialogue finished signal to continue
			var on_finished: Callable
			on_finished = func():
				EventBus.dialogue_finished.disconnect(on_finished)
				_execute_next_step()
			EventBus.dialogue_finished.connect(on_finished)
			
		"camera_move":
			var target_pos = step.get("target_position", Vector2.ZERO)
			var duration = step.get("duration", 1.0)
			var cam = get_tree().current_scene.get_node_or_null("GameCamera")
			if cam:
				var tween = create_tween()
				tween.tween_property(cam, "global_position", target_pos, duration)
				tween.finished.connect(func():
					_execute_next_step()
				)
			else:
				_execute_next_step()
			
		"camera_target":
			var target_path = step.get("target_node", NodePath(""))
			var target_node = get_tree().current_scene.get_node_or_null(target_path)
			var cam = get_tree().current_scene.get_node_or_null("GameCamera")
			if cam and target_node:
				cam.set_target(target_node)
			_execute_next_step()
			
		"trigger_event":
			var event_id = step.get("event_id", "")
			EventBus.event_triggered.emit(event_id)
			_execute_next_step()
			
		_:
			_execute_next_step()

func _freeze_player(freeze: bool):
	var active_char = GameManager.active_character
	if is_instance_valid(active_char) and active_char.has_method("change_state_by_enum"):
		if freeze:
			active_char.change_state_by_enum(4) # CharacterStateEnum.DISABLED
		else:
			active_char.change_state_by_enum(0) # CharacterStateEnum.IDLE

func _finish_cutscene():
	_freeze_player(false)
	is_playing = false
	GameManager.current_gameplay_state = GameManager.GameplayState.EXPLORATION
	print("CutscenePlayer: Finished cutscene '", _cutscene_name, "'")
	EventBus.cutscene_finished.emit(_cutscene_name)
	cutscene_finished.emit(_cutscene_name)
