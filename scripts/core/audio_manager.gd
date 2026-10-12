extends Node
## AudioManager - مدیریت صداها
## موسیقی، افکت‌های صوتی و دیالوگ‌ها را مدیریت می‌کند.

# ============================================================
# سیگنال‌ها
# ============================================================
signal music_started(track_name: String)
signal music_stopped
signal sfx_played(sfx_name: String)
signal voice_started(voice_name: String)
signal voice_finished

# ============================================================
# پخش‌کننده‌ها
# ============================================================
var music_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

# ============================================================
# تنظیمات
# ============================================================
const SFX_POOL_SIZE: int = 12
var music_volume_db: float = -6.0
var sfx_volume_db: float = -3.0
var voice_volume_db: float = 0.0

# ============================================================
# کش صداها
# ============================================================
var music_cache: Dictionary = {}
var sfx_cache: Dictionary = {}

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_players()
	await get_tree().process_frame
	_connect_settings()

func _setup_players() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	voice_player = AudioStreamPlayer.new()
	voice_player.bus = "Voice"
	voice_player.finished.connect(func(): voice_finished.emit())
	add_child(voice_player)
	
	for i in range(SFX_POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

func _connect_settings() -> void:
	if not SettingsManager:
		return
	SettingsManager.music_volume_changed.connect(_on_music_volume_changed)
	SettingsManager.sfx_volume_changed.connect(_on_sfx_volume_changed)
	SettingsManager.voice_volume_changed.connect(_on_voice_volume_changed)
	_on_music_volume_changed(SettingsManager.music_volume)
	_on_sfx_volume_changed(SettingsManager.sfx_volume)
	_on_voice_volume_changed(SettingsManager.voice_volume)

# ============================================================
# موسیقی
# ============================================================
func play_music(track_name: String, fade_in: float = 1.0) -> void:
	var path: String = "res://assets/audio/music/" + track_name + ".ogg"
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/music/" + track_name + ".wav"
	if not ResourceLoader.exists(path):
		push_warning("[AudioManager] موسیقی پیدا نشد: " + track_name)
		return
	
	var stream: AudioStream = music_cache.get(path)
	if not stream:
		stream = load(path)
		if stream is AudioStreamOggVorbis:
			stream.loop = true
		elif stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		music_cache[path] = stream
	
	music_player.stream = stream
	music_player.volume_db = -80.0
	music_player.play()
	
	var tween: Tween = create_tween()
	tween.tween_property(music_player, "volume_db", music_volume_db, fade_in)
	music_started.emit(track_name)

func stop_music(fade_out: float = 1.0) -> void:
	if not music_player.playing:
		return
	if fade_out > 0.0:
		var tween: Tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_out)
		tween.finished.connect(func():
			music_player.stop()
			music_stopped.emit()
		)
	else:
		music_player.stop()
		music_stopped.emit()

# ============================================================
# افکت‌های صوتی
# ============================================================
func play_sfx(sfx_name: String, volume_offset_db: float = 0.0) -> void:
	var path: String = "res://assets/audio/sfx/" + sfx_name + ".wav"
	if not ResourceLoader.exists(path):
		path = "res://assets/audio/sfx/" + sfx_name + ".ogg"
	if not ResourceLoader.exists(path):
		push_warning("[AudioManager] افکت صوتی پیدا نشد: " + sfx_name)
		return
	
	var stream: AudioStream = sfx_cache.get(path)
	if not stream:
		stream = load(path)
		sfx_cache[path] = stream
	
	var player: AudioStreamPlayer = _get_available_sfx_player()
	if player:
		player.stream = stream
		player.volume_db = sfx_volume_db + volume_offset_db
		player.play()
		sfx_played.emit(sfx_name)

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	# اگر همه پخش می‌کنند، قدیمی‌ترین را برگردان
	return sfx_players[0]

# ============================================================
# دیالوگ صوتی
# ============================================================
func play_voice(voice_path: String) -> void:
	if not ResourceLoader.exists(voice_path):
		push_warning("[AudioManager] دیالوگ پیدا نشد: " + voice_path)
		return
	if voice_player.playing:
		voice_player.stop()
	voice_player.stream = load(voice_path)
	voice_player.play()
	voice_started.emit(voice_path.get_file())

func stop_voice() -> void:
	if voice_player.playing:
		voice_player.stop()

func is_voice_playing() -> bool:
	return voice_player.playing

# ============================================================
# کنترل صدا
# ============================================================
func _on_music_volume_changed(value: float) -> void:
	music_volume_db = linear_to_db(maxf(value, 0.001))
	if music_player:
		music_player.volume_db = music_volume_db

func _on_sfx_volume_changed(value: float) -> void:
	sfx_volume_db = linear_to_db(maxf(value, 0.001))

func _on_voice_volume_changed(value: float) -> void:
	voice_volume_db = linear_to_db(maxf(value, 0.001))
	if voice_player:
		voice_player.volume_db = voice_volume_db
