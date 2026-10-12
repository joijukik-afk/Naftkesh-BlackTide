extends Node
## SoundForge - کارگاه تولید خودکار صداها
## تمام افکت‌های صوتی، موسیقی و صداهای محیطی را از صفر می‌سازد.
## هیچ فایل خارجی نیاز نیست.

# ============================================================
# مسیرهای ذخیره‌سازی
# ============================================================
const SFX_DIR: String = "res://assets/audio/sfx/"
const MUSIC_DIR: String = "res://assets/audio/music/"
const VOICE_DIR: String = "res://assets/audio/voice/"
const AMBIENT_DIR: String = "res://assets/audio/ambient/"

const SAMPLE_RATE: int = 22050

# ============================================================
# توابع اولیه
# ============================================================
func _ready() -> void:
	_ensure_directories()

func _ensure_directories() -> void:
	for dir in [SFX_DIR, MUSIC_DIR, VOICE_DIR, AMBIENT_DIR]:
		if not DirAccess.dir_exists_absolute(dir):
			DirAccess.make_dir_recursive_absolute(dir)

# ============================================================
# تابع اصلی - تولید همه صداها
# ============================================================
func generate_all() -> void:
	print("[SoundForge] شروع تولید صداها...")
	_generate_all_sfx()
	_generate_all_music()
	_generate_all_ambient()
	print("[SoundForge] ✓ تمام صداها با موفقیت ساخته شدند.")

# ============================================================
# توابع کمکی
# ============================================================
func _float_to_bytes(samples: Array[float]) -> PackedByteArray:
	var data: PackedByteArray = PackedByteArray()
	data.resize(samples.size() * 2)
	for i in range(samples.size()):
		var s: float = clampf(samples[i], -1.0, 1.0)
		var v: int = int(s * 32767.0)
		data[i * 2] = v & 0xFF
		data[i * 2 + 1] = (v >> 8) & 0xFF
	return data

func _save_wav(samples: Array[float], path: String, loop: bool = false) -> void:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.data = _float_to_bytes(samples)
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()
	var err: int = ResourceSaver.save(stream, path)
	if err == OK:
		print("  ✓ ", path)
	else:
		push_error("  ✗ خطا در ذخیره: " + path)

# ============================================================
# تولید تمام افکت‌های صوتی
# ============================================================
func _generate_all_sfx() -> void:
	_make_gunshot_pistol()
	_make_gunshot_rifle()
	_make_gunshot_shotgun()
	_make_gunshot_sniper()
	_make_reload()
	_make_reload_empty()
	_make_weapon_switch()
	_make_footstep_deck()
	_make_footstep_metal()
	_make_footstep_water()
	_make_hit_flesh()
	_make_hit_metal()
	_make_hit_wall()
	_make_explosion_small()
	_make_explosion_large()
	_make_ui_click()
	_make_ui_hover()
	_make_ui_back()
	_make_ui_error()
	_make_door_open()
	_make_door_close()
	_make_alarm()
	_make_pickup_ammo()
	_make_pickup_health()
	_make_player_hurt()
	_make_player_death()
	_make_enemy_alert()

# ============================================================
# تولید تمام موسیقی‌ها
# ============================================================
func _generate_all_music() -> void:
	_make_music_menu()
	_make_music_combat()
	_make_music_stealth()
	_make_music_victory()
	_make_music_game_over()
	_make_music_story()

# ============================================================
# تولید صداهای محیطی
# ============================================================
func _generate_all_ambient() -> void:
	_make_ambient_ocean()
	_make_ambient_wind()
	_make_ambient_engine()
	_make_ambient_rain()

# ============================================================
# === افکت‌های صوتی سلاح ===
# ============================================================
func _make_gunshot_pistol() -> void:
	var count: int = int(SAMPLE_RATE * 0.12)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 45.0)
		var noise: float = randf_range(-1.0, 1.0) * 0.55
		var tone: float = sin(t * 180.0 * TAU) * 0.4
		var crack: float = sin(t * 800.0 * TAU) * exp(-t * 120.0) * 0.3
		samples.append((noise + tone + crack) * env)
	_save_wav(samples, SFX_DIR + "gunshot_pistol.wav")

func _make_gunshot_rifle() -> void:
	var count: int = int(SAMPLE_RATE * 0.18)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 30.0)
		var noise: float = randf_range(-1.0, 1.0) * 0.7
		var tone: float = sin(t * 120.0 * TAU) * 0.5
		var boom: float = sin(t * 60.0 * TAU) * 0.3
		samples.append((noise + tone + boom) * env)
	_save_wav(samples, SFX_DIR + "gunshot_rifle.wav")

func _make_gunshot_shotgun() -> void:
	var count: int = int(SAMPLE_RATE * 0.35)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 12.0)
		var noise: float = randf_range(-1.0, 1.0) * 0.85
		var rumble: float = sin(t * 55.0 * TAU) * 0.5
		samples.append((noise + rumble) * env)
	_save_wav(samples, SFX_DIR + "gunshot_shotgun.wav")

func _make_gunshot_sniper() -> void:
	var count: int = int(SAMPLE_RATE * 0.5)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 8.0)
		var noise: float = randf_range(-1.0, 1.0) * 0.8
		var boom: float = sin(t * 40.0 * TAU) * 0.6
		var crack: float = sin(t * 1500.0 * TAU) * exp(-t * 100.0) * 0.4
		samples.append((noise + boom + crack) * env)
	_save_wav(samples, SFX_DIR + "gunshot_sniper.wav")

# ============================================================
# === افکت‌های خشاب‌گذاری ===
# ============================================================
func _make_reload() -> void:
	var count: int = int(SAMPLE_RATE * 0.6)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = 0.0
		# کلیک اول (خارج کردن خشاب)
		if t < 0.08:
			env = exp(-t * 80.0)
		# کلیک دوم (جا زدن خشاب)
		elif t > 0.2 and t < 0.28:
			env = exp(-(t - 0.2) * 80.0)
		# کلیک سوم (کشیدن گلنگدن)
		elif t > 0.45 and t < 0.52:
			env = exp(-(t - 0.45) * 80.0)
		var click: float = randf_range(-1.0, 1.0) * env * 0.5
		var tone: float = sin(t * 400.0 * TAU) * env * 0.3
		samples.append(click + tone)
	_save_wav(samples, SFX_DIR + "reload.wav")

func _make_reload_empty() -> void:
	var count: int = int(SAMPLE_RATE * 0.15)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 70.0)
		var click: float = randf_range(-1.0, 1.0) * env * 0.4
		var tone: float = sin(t * 600.0 * TAU) * env * 0.3
		samples.append(click + tone)
	_save_wav(samples, SFX_DIR + "reload_empty.wav")

func _make_weapon_switch() -> void:
	var count: int = int(SAMPLE_RATE * 0.2)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = 0.0
		if t < 0.05:
			env = exp(-t * 60.0)
		elif t > 0.1 and t < 0.15:
			env = exp(-(t - 0.1) * 60.0)
		var click: float = randf_range(-1.0, 1.0) * env * 0.4
		samples.append(click)
	_save_wav(samples, SFX_DIR + "weapon_switch.wav")

# ============================================================
# === صدای قدم ===
# ============================================================
func _make_footstep_deck() -> void:
	var count: int = int(SAMPLE_RATE * 0.12)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 40.0)
		var noise: float = randf_range(-1.0, 1.0) * 0.3
		var thud: float = sin(t * 80.0 * TAU) * 0.4
		samples.append((noise + thud) * env)
	_save_wav(samples, SFX_DIR + "footstep_deck.wav")

func _make_footstep_metal() -> void:
	var count: int = int(SAMPLE_RATE * 0.15)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 35.0)
		var noise: float = randf_range(-1.0, 1.0) * 0.25
		var clang: float = sin(t * 250.0 * TAU) * 0.5
		var ring: float = sin(t * 500.0 * TAU) * exp(-t * 20.0) * 0.3
		samples.append((noise + clang + ring) * env)
	_save_wav(samples, SFX_DIR + "footstep_metal.wav")

func _make_footstep_water() -> void:
	var count: int = int(SAMPLE_RATE * 0.2)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 20.0)
		var splash: float = randf_range(-1.0, 1.0) * 0.4
		var drip: float = sin(t * 150.0 * TAU) * 0.3
		samples.append((splash + drip) * env)
	_save_wav(samples, SFX_DIR + "footstep_water.wav")

# ============================================================
# === صدای برخورد ===
# ============================================================
func _make_hit_flesh() -> void:
	var count: int = int(SAMPLE_RATE * 0.1)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 60.0)
		var thud: float = sin(t * 100.0 * TAU) * 0.5
		var noise: float = randf_range(-1.0, 1.0) * 0.3
		samples.append((thud + noise) * env)
	_save_wav(samples, SFX_DIR + "hit_flesh.wav")

func _make_hit_metal() -> void:
	var count: int = int(SAMPLE_RATE * 0.15)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 40.0)
		var clang: float = sin(t * 800.0 * TAU) * 0.4
		var ring: float = sin(t * 1600.0 * TAU) * exp(-t * 15.0) * 0.3
		samples.append((clang + ring) * env)
	_save_wav(samples, SFX_DIR + "hit_metal.wav")

func _make_hit_wall() -> void:
	var count: int = int(SAMPLE_RATE * 0.08)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 70.0)
		var noise: float = randf_range(-1.0, 1.0) * 0.5
		samples.append(noise * env)
	_save_wav(samples, SFX_DIR + "hit_wall.wav")

# ============================================================
# === انفجار ===
# ============================================================
func _make_explosion_small() -> void:
	var count: int = int(SAMPLE_RATE * 0.8)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 5.0)
		var noise: float = randf_range(-1.0, 1.0) * 0.7
		var rumble: float = sin(t * 70.0 * TAU) * 0.4
		samples.append((noise + rumble) * env)
	_save_wav(samples, SFX_DIR + "explosion_small.wav")

func _make_explosion_large() -> void:
	var count: int = int(SAMPLE_RATE * 2.0)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 2.5)
		var noise: float = randf_range(-1.0, 1.0) * 0.85
		var boom: float = sin(t * 40.0 * TAU) * 0.5
		var crackle: float = randf_range(-1.0, 1.0) * exp(-t * 0.5) * 0.2
		samples.append((noise + boom + crackle) * env)
	_save_wav(samples, SFX_DIR + "explosion_large.wav")

# ============================================================
# === رابط کاربری ===
# ============================================================
func _make_ui_click() -> void:
	var count: int = int(SAMPLE_RATE * 0.05)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 80.0)
		var tone: float = sin(t * 1200.0 * TAU) * 0.5
		samples.append(tone * env)
	_save_wav(samples, SFX_DIR + "ui_click.wav")

func _make_ui_hover() -> void:
	var count: int = int(SAMPLE_RATE * 0.04)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 100.0)
		var tone: float = sin(t * 800.0 * TAU) * 0.3
		samples.append(tone * env)
	_save_wav(samples, SFX_DIR + "ui_hover.wav")

func _make_ui_back() -> void:
	var count: int = int(SAMPLE_RATE * 0.08)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 50.0)
		var freq: float = lerpf(800.0, 400.0, t / 0.08)
		var tone: float = sin(t * freq * TAU) * 0.4
		samples.append(tone * env)
	_save_wav(samples, SFX_DIR + "ui_back.wav")

func _make_ui_error() -> void:
	var count: int = int(SAMPLE_RATE * 0.2)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 20.0)
		var tone: float = sin(t * 200.0 * TAU) * 0.5
		samples.append(tone * env)
	_save_wav(samples, SFX_DIR + "ui_error.wav")

# ============================================================
# === درها ===
# ============================================================
func _make_door_open() -> void:
	var count: int = int(SAMPLE_RATE * 1.2)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = 0.0
		if t < 0.9:
			env = exp(-t * 2.0) * (1.0 - t / 0.9)
		var creak: float = sin(t * 200.0 * TAU) * 0.3 * env
		var noise: float = randf_range(-1.0, 1.0) * 0.2 * env
		samples.append(creak + noise)
	_save_wav(samples, SFX_DIR + "door_open.wav")

func _make_door_close() -> void:
	var count: int = int(SAMPLE_RATE * 0.8)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = 0.0
		if t > 0.5:
			env = exp(-(t - 0.5) * 30.0)
		var slam: float = sin(t * 100.0 * TAU) * 0.4 * env
		var noise: float = randf_range(-1.0, 1.0) * 0.3 * env
		samples.append(slam + noise)
	_save_wav(samples, SFX_DIR + "door_close.wav")

# ============================================================
# === هشدار ===
# ============================================================
func _make_alarm() -> void:
	var count: int = int(SAMPLE_RATE * 2.0)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var freq: float = 600.0 if fmod(t, 0.5) < 0.25 else 800.0
		var env: float = 0.5
		var tone: float = sin(t * freq * TAU) * env * 0.4
		samples.append(tone)
	_save_wav(samples, SFX_DIR + "alarm.wav")

# ============================================================
# === جمع‌آوری آیتم ===
# ============================================================
func _make_pickup_ammo() -> void:
	var count: int = int(SAMPLE_RATE * 0.25)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 12.0)
		var freq: float = 600.0 + t * 800.0
		var tone: float = sin(t * freq * TAU) * 0.4
		samples.append(tone * env)
	_save_wav(samples, SFX_DIR + "pickup_ammo.wav")

func _make_pickup_health() -> void:
	var count: int = int(SAMPLE_RATE * 0.35)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 8.0)
		var freq: float = 400.0 + sin(t * 10.0 * TAU) * 200.0
		var tone: float = sin(t * freq * TAU) * 0.4
		samples.append(tone * env)
	_save_wav(samples, SFX_DIR + "pickup_health.wav")

# ============================================================
# === بازیکن ===
# ============================================================
func _make_player_hurt() -> void:
	var count: int = int(SAMPLE_RATE * 0.25)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 10.0)
		var freq: float = 200.0 - t * 100.0
		var tone: float = sin(t * freq * TAU) * 0.4
		var noise: float = randf_range(-1.0, 1.0) * 0.2 * env
		samples.append(tone * env + noise)
	_save_wav(samples, SFX_DIR + "player_hurt.wav")

func _make_player_death() -> void:
	var count: int = int(SAMPLE_RATE * 1.5)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 2.0)
		var freq: float = 300.0 - t * 180.0
		var tone: float = sin(t * freq * TAU) * 0.5
		samples.append(tone * env)
	_save_wav(samples, SFX_DIR + "player_death.wav")

# ============================================================
# === دشمن ===
# ============================================================
func _make_enemy_alert() -> void:
	var count: int = int(SAMPLE_RATE * 0.4)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 5.0)
		var freq: float = 400.0 + sin(t * 15.0 * TAU) * 100.0
		var tone: float = sin(t * freq * TAU) * 0.4
		samples.append(tone * env)
	_save_wav(samples, SFX_DIR + "enemy_alert.wav")

# ============================================================
# === موسیقی منو ===
# ============================================================
func _make_music_menu() -> void:
	var duration: float = 16.0
	var count: int = int(SAMPLE_RATE * duration)
	var samples: Array[float] = []
	# آکورد مینور آرام (Am - F - C - G)
	var chords: Array = [
		[220.0, 261.63, 329.63],   # Am
		[174.61, 220.0, 261.63],   # F
		[261.63, 329.63, 392.0],   # C
		[196.0, 246.94, 293.66]    # G
	]
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var chord_index: int = int(t / 4.0) % chords.size()
		var local_t: float = fmod(t, 4.0)
		var env: float = 0.0
		if local_t < 0.5:
			env = local_t / 0.5
		elif local_t > 3.0:
			env = (4.0 - local_t) / 1.0
		else:
			env = 1.0
		env *= 0.3
		var value: float = 0.0
		for freq in chords[chord_index]:
			value += sin(t * freq * TAU) * 0.15
			value += sin(t * freq * 2.0 * TAU) * 0.05
		# بیس
		value += sin(t * chords[chord_index][0] * 0.5 * TAU) * 0.1
		samples.append(value * env)
	_save_wav(samples, MUSIC_DIR + "menu.ogg", true)

# ============================================================
# === موسیقی مبارزه ===
# ============================================================
func _make_music_combat() -> void:
	var duration: float = 8.0
	var count: int = int(SAMPLE_RATE * duration)
	var samples: Array[float] = []
	var notes: Array[float] = [110.0, 146.83, 164.81, 110.0, 146.83, 196.0, 164.81, 110.0]
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var beat: float = fmod(t * 4.0, 1.0)
		var note_index: int = int(t * 2.0) % notes.size()
		var freq: float = notes[note_index]
		# کیک
		var kick_env: float = exp(-beat * 18.0)
		var kick: float = sin(t * 55.0 * TAU) * kick_env * 0.5
		# لید
		var lead: float = sin(t * freq * TAU) * 0.2
		lead += sin(t * freq * 2.0 * TAU) * 0.1
		# بیس
		var bass: float = sin(t * freq * 0.5 * TAU) * 0.3
		# های‌هت
		var hat_env: float = exp(-fmod(t * 8.0, 1.0) * 40.0)
		var hat: float = randf_range(-1.0, 1.0) * hat_env * 0.08
		samples.append(kick + lead + bass + hat)
	_save_wav(samples, MUSIC_DIR + "combat.ogg", true)

# ============================================================
# === موسیقی مخفی‌کاری ===
# ============================================================
func _make_music_stealth() -> void:
	var duration: float = 12.0
	var count: int = int(SAMPLE_RATE * duration)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var pulse: float = fmod(t * 0.5, 1.0)
		var env: float = exp(-pulse * 3.0) * 0.3
		var tone1: float = sin(t * 80.0 * TAU) * env
		var tone2: float = sin(t * 120.0 * TAU) * env * 0.6
		var noise: float = randf_range(-1.0, 1.0) * exp(-pulse * 8.0) * 0.05
		samples.append(tone1 + tone2 + noise)
	_save_wav(samples, MUSIC_DIR + "stealth.ogg", true)

# ============================================================
# === موسیقی پیروزی ===
# ============================================================
func _make_music_victory() -> void:
	var duration: float = 4.0
	var count: int = int(SAMPLE_RATE * duration)
	var samples: Array[float] = []
	var notes: Array = [261.63, 329.63, 392.0, 523.25]
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var note_duration: float = 1.0
		var note_index: int = int(t / note_duration)
		if note_index >= notes.size():
			note_index = notes.size() - 1
		var local_t: float = fmod(t, note_duration)
		var env: float = exp(-local_t * 2.0)
		var freq: float = notes[note_index]
		var value: float = sin(t * freq * TAU) * 0.4 * env
		value += sin(t * freq * 1.5 * TAU) * 0.15 * env
		samples.append(value)
	_save_wav(samples, MUSIC_DIR + "victory.ogg")

# ============================================================
# === موسیقی باخت ===
# ============================================================
func _make_music_game_over() -> void:
	var duration: float = 5.0
	var count: int = int(SAMPLE_RATE * duration)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var freq: float = 220.0 - t * 30.0
		if freq < 80.0:
			freq = 80.0
		var env: float = exp(-t * 0.5)
		var value: float = sin(t * freq * TAU) * 0.4 * env
		value += sin(t * freq * 0.5 * TAU) * 0.3 * env
		samples.append(value)
	_save_wav(samples, MUSIC_DIR + "game_over.ogg")

# ============================================================
# === موسیقی داستانی ===
# ============================================================
func _make_music_story() -> void:
	var duration: float = 20.0
	var count: int = int(SAMPLE_RATE * duration)
	var samples: Array[float] = []
	var chords: Array = [
		[130.81, 155.56, 196.0],   # Cm
		[146.83, 174.61, 220.0],   # Dm
		[155.56, 196.0, 233.08],   # Eb
		[174.61, 220.0, 261.63]    # F
	]
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var chord_index: int = int(t / 5.0) % chords.size()
		var local_t: float = fmod(t, 5.0)
		var env: float = 1.0
		if local_t < 1.0:
			env = local_t / 1.0
		elif local_t > 4.0:
			env = (5.0 - local_t) / 1.0
		env *= 0.25
		var value: float = 0.0
		for freq in chords[chord_index]:
			value += sin(t * freq * TAU) * 0.12
			value += sin(t * freq * 1.5 * TAU) * 0.05
		value += sin(t * chords[chord_index][0] * 0.5 * TAU) * 0.15
		samples.append(value * env)
	_save_wav(samples, MUSIC_DIR + "story.ogg", true)

# ============================================================
# === صدای محیط: اقیانوس ===
# ============================================================
func _make_ambient_ocean() -> void:
	var duration: float = 8.0
	var count: int = int(SAMPLE_RATE * duration)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		# موج‌های آرام
		var wave: float = sin(t * 0.3 * TAU) * 0.15
		wave += sin(t * 0.5 * TAU) * 0.1
		wave += sin(t * 0.7 * TAU) * 0.08
		# نویز پایین
		var noise: float = randf_range(-1.0, 1.0) * 0.08
		samples.append((wave + noise) * 0.6)
	_save_wav(samples, AMBIENT_DIR + "ocean.ogg", true)

# ============================================================
# === صدای محیط: باد ===
# ============================================================
func _make_ambient_wind() -> void:
	var duration: float = 10.0
	var count: int = int(SAMPLE_RATE * duration)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var mod: float = 0.5 + sin(t * 0.2 * TAU) * 0.5
		var noise: float = randf_range(-1.0, 1.0) * 0.25 * mod
		samples.append(noise * 0.5)
	_save_wav(samples, AMBIENT_DIR + "wind.ogg", true)

# ============================================================
# === صدای محیط: موتور کشتی ===
# ============================================================
func _make_ambient_engine() -> void:
	var duration: float = 4.0
	var count: int = int(SAMPLE_RATE * duration)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		# لرزش موتور
		var rumble: float = sin(t * 40.0 * TAU) * 0.3
		rumble += sin(t * 80.0 * TAU) * 0.2
		rumble += sin(t * 120.0 * TAU) * 0.1
		# نویز
		var noise: float = randf_range(-1.0, 1.0) * 0.1
		samples.append((rumble + noise) * 0.5)
	_save_wav(samples, AMBIENT_DIR + "engine.ogg", true)

# ============================================================
# === صدای محیط: باران ===
# ============================================================
func _make_ambient_rain() -> void:
	var duration: float = 6.0
	var count: int = int(SAMPLE_RATE * duration)
	var samples: Array[float] = []
	for i in range(count):
		var t: float = float(i) / SAMPLE_RATE
		var noise: float = randf_range(-1.0, 1.0) * 0.3
		# قطرات پراکنده
		if randf() < 0.001:
			noise += randf_range(-1.0, 1.0) * 0.5
		samples.append(noise * 0.4)
	_save_wav(samples, AMBIENT_DIR + "rain.ogg", true)
