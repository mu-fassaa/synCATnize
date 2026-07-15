extends Node

@onready var player = get_parent().get_node("Player")
@onready var cat = get_parent().get_node("Cat")

func _ready():
	# Connect to narrative/quest event triggers
	EventBus.event_triggered.connect(_on_event_triggered)
	
	# Delay sequence trigger slightly to allow engine scene nodes to initialize fully
	get_tree().create_timer(0.5).timeout.connect(start_opening_cutscene)

func start_opening_cutscene():
	var timeline = [
		{"type": "freeze", "value": true},
		{"type": "dialogue", "speaker": "Narasi", "lines": [
			"Kamu terbangun di dalam pondok tua.",
			"Di luar pintu, energi misterius berputar dengan kencang.",
			"Temukan jalan keluar dan pulihkan energi wilayah ini!"
		]},
		{"type": "dialogue", "speaker": "Pemain", "lines": [
			"Aduh... kepalaku pusing. Di mana aku?",
			"Dan... kenapa pintu rumah terkunci rapat?",
			"Mungkin aku bisa mendorong peti kayu itu ke atas tombol di lantai untuk membukanya."
		]},
		{"type": "dialogue", "speaker": "Sistem", "lines": [
			"[TUTORIAL GERAKAN]",
			"Gunakan tombol arah / WASD untuk bergerak.",
			"Gunakan tombol SHIFT untuk berlari."
		]},
		{"type": "freeze", "value": false}
	]
	
	# Run cutscene
	var cutscene_player = CutscenePlayer.new()
	add_child(cutscene_player)
	cutscene_player.play_cutscene("opening", timeline)
	
	# Initialize first objectives
	ObjectiveManager.add_objective("movement_tutorial", "Gunakan WASD untuk berjalan di sekitar pondok.", "visit_area")
	ObjectiveManager.add_objective("met_cat", "Bicaralah dengan kucing orange yang tertidur di sebelah kanan.", "talk_npc")
	
	# Lock character swapping initially
	GameManager.is_switch_allowed = false
	
	# Disable exit transition trigger initially
	var trigger_shape = get_parent().get_node_or_null("Transitions/Trigger0/CollisionShape2D")
	if trigger_shape:
		trigger_shape.set_deferred("disabled", true)

func _on_event_triggered(event_id: String):
	match event_id:
		"met_cat":
			_play_cat_recruitment_cutscene()
		"rift_closed_house_rift":
			_play_ending_cutscene()

func _play_cat_recruitment_cutscene():
	var timeline = [
		{"type": "freeze", "value": true},
		{"type": "dialogue", "speaker": "Kucing", "lines": [
			"Meow... (Menguap malas)",
			"Hei manusia, apa kamu mau membuka pintu itu? Aku bisa membantumu.",
			"Tekan C untuk menukar kesadaran dan mengendalikanku!"
		]},
		{"type": "dialogue", "speaker": "Sistem", "lines": [
			"[TUTORIAL GANTI KARAKTER]",
			"Gunakan tombol C untuk berganti karakter antara Manusia dan Kucing.",
			"Dorong peti ke pressure plate untuk membuka jalan."
		]},
		{"type": "freeze", "value": false}
	]
	
	# Unlock swap control
	GameManager.is_switch_allowed = true
	
	# Play recruitment cutscene
	var cutscene_player = CutscenePlayer.new()
	add_child(cutscene_player)
	cutscene_player.play_cutscene("recruitment", timeline)
	
	# Add next progression objectives
	ObjectiveManager.add_objective("house_puzzle", "Dorong peti ke pressure plate untuk membuka gerbang.", "solve_puzzle")
	ObjectiveManager.add_objective("house_rift", "Tutup Rift misterius di bagian atas rumah.", "close_rift")

func _play_ending_cutscene():
	var timeline = [
		{"type": "freeze", "value": true},
		{"type": "dialogue", "speaker": "Pemain", "lines": [
			"Luar biasa! Rift berhasil ditutup dan area ini kembali normal.",
			"Sekarang pintu keluar menuju desa telah terbuka!"
		]},
		{"type": "dialogue", "speaker": "Sistem", "lines": [
			"[VERTICAL SLICE SELESAI]",
			"Selamat! Anda telah menyelesaikan demo Vertical Slice synCATnize.",
			"Terima kasih telah mencoba!"
		]},
		{"type": "freeze", "value": false}
	]
	
	# Enable output transitions
	var trigger_shape = get_parent().get_node_or_null("Transitions/Trigger0/CollisionShape2D")
	if trigger_shape:
		trigger_shape.set_deferred("disabled", false)
		
	var cutscene_player = CutscenePlayer.new()
	add_child(cutscene_player)
	cutscene_player.play_cutscene("ending", timeline)
