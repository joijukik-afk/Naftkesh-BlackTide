extends Node
## DialogueData - پایگاه داده دیالوگ‌های داستانی
## تمام دیالوگ‌های بازی به تفکیک فصل و صحنه اینجا ذخیره می‌شوند.

# ============================================================
# شخصیت‌ها - شناسه‌های ثابت
# ============================================================
const CHAR_NAFTKESH: String = "Naftkesh"
const CHAR_NARGIL: String = "Nargil"
const CHAR_KHALF_KAR: String = "KhalfKarAsli"
const CHAR_AMIR: String = "AmirAlavi"
const CHAR_BEST_TIME: String = "Best Time Kabir"
const CHAR_CAPTAIN: String = "Captain"
const CHAR_KASRA: String = "Kasra"
const CHAR_SHAKERI: String = "Shakeri"
const CHAR_JALIL: String = "Jalil"
const CHAR_BACTERIA: String = "Bacteria"
const CHAR_SEEDROY: String = "SeedRoy"
const CHAR_ANANAS: String = "Ananas"
const CHAR_ALIFIFA: String = "Alififa"
const CHAR_NIMA: String = "Nima"
const CHAR_SAEED: String = "Saeed"
const CHAR_YGGDRASI: String = "Yggdrasi_KS"
const CHAR_WARDEN: String = "Warden"
const CHAR_RADIO: String = "Radio"
const CHAR_SYSTEM: String = "System"

# ============================================================
# فصل اول: DEAD WATER
# ============================================================

## صحنه افتتاحیه - معرفی شخصیت‌ها
static func get_chapter_1_intro() -> Array:
	return [
		{
			"speaker": CHAR_SYSTEM,
			"text": "سال ۲۰۳۱. آب‌های آزاد. نفتکش ABYSS-01 در مسیر خطرناکی حرکت می‌کند.",
			"voice": "",
			"portrait": "system"
		},
		{
			"speaker": CHAR_CAPTAIN,
			"text": "ناوگان، این کاپیتان است. به عرضه‌ی نفتکش ABYSS-01 خوش آمدید. مسیر ما از آب‌های طوفانی می‌گذرد. هوشیار باشید.",
			"voice": "",
			"portrait": "captain"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "تیم، وضعیت چطوره؟ گزارش بدید.",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_NARGIL,
			"text": "فرمانده، همه چیز تحت کنترله. تیم آماده و تجهیزات بررسی شده.",
			"voice": "",
			"portrait": "nargil"
		},
		{
			"speaker": CHAR_SHAKERI,
			"text": "موتورخانه یه لرزش خفیف داره، ولی چیزی نیست که نتونم درستش کنم.",
			"voice": "",
			"portrait": "shakeri"
		},
		{
			"speaker": CHAR_KASRA,
			"text": "ارتباطات رادیویی یه کم نویز داره. امواج مغناطیسی غیرعادی توی این منطقه زیاده.",
			"voice": "",
			"portrait": "kasra"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "خوبه. اما حس خوبی به این منطقه ندارم. کسی چیز مشکوکی ندیده؟",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_SEEDROY,
			"text": "فرمانده، افق شرقی یه سایه‌ی سنگین داره. شبیه قایق‌های تندروئه. فاصله زیاد نیست.",
			"voice": "",
			"portrait": "seedroy"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "همه به مواضع! این احتمالاً شروع یه چیز بزرگه.",
			"voice": "",
			"portrait": "naftkesh"
		}
	]

## شروع مبارزه - حمله BLACK VEIL
static func get_combat_start() -> Array:
	return [
		{
			"speaker": CHAR_KASRA,
			"text": "فرمانده! دشمن از سمت راست داره میاد! چندین قایق تندرو!",
			"voice": "",
			"portrait": "kasra"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "همه به پوشش! شلیک آزاد! نذارید به عرشه برسند!",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_NARGIL,
			"text": "دریافت شد. در حال حرکت به سمت پل فرماندهی!",
			"voice": "",
			"portrait": "nargil"
		},
		{
			"speaker": CHAR_KHALF_KAR,
			"text": "خلف‌کار اینجاست. تیم چپ رو من می‌گیرم. آقای سعید، با من بیا!",
			"voice": "",
			"portrait": "khalf_kar"
		},
		{
			"speaker": CHAR_SAEED,
			"text": "روی من حساب کن، رفیق.",
			"voice": "",
			"portrait": "saeed"
		}
	]

## در حین نبرد
static func get_combat_mid_battle() -> Array:
	return [
		{
			"speaker": CHAR_JALIL,
			"text": "فرمانده، دو نفر از خدمه زخمی شدن. دارم می‌رم سمتشون.",
			"voice": "",
			"portrait": "jalil"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "مراقب باش، جلیل. اگه اوضاع بد شد، عقب‌نشینی کن.",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_AMIR,
			"text": "فرمانده، توی انبار یه تحرک مشکوک دیدم. دارم بررسی می‌کنم.",
			"voice": "",
			"portrait": "amir"
		},
		{
			"speaker": CHAR_BACTERIA,
			"text": "پهپاد شناسایی فرستادم. تصاویر نشون می‌ده حداقل سه گروه مهاجم داریم.",
			"voice": "",
			"portrait": "bacteria"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "سه گروه... پس نقشه‌شون از قبل کشیده شده.",
			"voice": "",
			"portrait": "naftkesh"
		}
	]

## نجات خدمه
static func get_crew_rescue() -> Array:
	return [
		{
			"speaker": CHAR_NAFTKESH,
			"text": "خدمه‌ای که گیر افتادن رو نجات بدید! هیچ‌کس جا نمی‌مونه!",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_NIMA,
			"text": "فرمانده، پله‌های بخش ۴ مسدوده. راه دیگه‌ای هست؟",
			"voice": "",
			"portrait": "nima"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "از راهروی سمت راست برو. از اونجا به موتورخانه می‌رسی.",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_NIMA,
			"text": "دریافت شد. در حال حرکت.",
			"voice": "",
			"portrait": "nima"
		}
	]

## پایان فصل اول - قطع ارتباطات
static func get_chapter_1_ending() -> Array:
	return [
		{
			"speaker": CHAR_KASRA,
			"text": "فرمانده! ارتباطات قطع شد! هیچ سیگنالی از بیرون نمی‌گیریم!",
			"voice": "",
			"portrait": "kasra"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "چی؟ چطور ممکنه؟",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_ALIFIFA,
			"text": "سیستم‌های الکترونیکی ما هک شدن. یکی از پنل‌های کنترل رو دستکاری کرده.",
			"voice": "",
			"portrait": "alififa"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "... یعنی یکی از خودمون؟",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_BEST_TIME,
			"text": "بهتره عجله نکنیم، فرمانده. شاید کسی از بیرون دسترسی پیدا کرده.",
			"voice": "",
			"portrait": "best_time"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "نه. این خیلی دقیق و از داخله. یه جاسوس بین ماست.",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_SYSTEM,
			"text": "فصل اول: DEAD WATER - پایان",
			"voice": "",
			"portrait": "system"
		}
	]

# ============================================================
# فصل دوم: SILENT ENGINE
# ============================================================

static func get_chapter_2_intro() -> Array:
	return [
		{
			"speaker": CHAR_SYSTEM,
			"text": "فصل دوم: SILENT ENGINE",
			"voice": "",
			"portrait": "system"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "باید بریم سمت موتورخانه. شاکری، وضعیت اونجا چطوره؟",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_SHAKERI,
			"text": "بد نیست، ولی سیستم برق پشتیبان از کار افتاده. اگه موتور اصلی هم بره، همه چیز تاریک می‌شه.",
			"voice": "",
			"portrait": "shakeri"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "پس با هم می‌ریم. شاکری و جلیل، همراه من.",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_JALIL,
			"text": "من آماده‌ام، فرمانده. تجهیزات پزشکی همراهمه.",
			"voice": "",
			"portrait": "jalil"
		}
	]

static func get_chapter_2_midway() -> Array:
	return [
		{
			"speaker": CHAR_SHAKERI,
			"text": "فرمانده، این پنل اینجا دستکاری شده. یکی از سیم‌ها عمداً بریده شده.",
			"voice": "",
			"portrait": "shakeri"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "مطمئنی؟ شاید فرسوده شده.",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_SHAKERI,
			"text": "نه، این کار یه آدم حرفه‌ایه. دقیق و تمیز. جاسوس ما یه مهندسه.",
			"voice": "",
			"portrait": "shakeri"
		}
	]

# ============================================================
# فصل سوم: GHOST PLATFORM
# ============================================================

static func get_chapter_3_intro() -> Array:
	return [
		{
			"speaker": CHAR_SYSTEM,
			"text": "فصل سوم: GHOST PLATFORM",
			"voice": "",
			"portrait": "system"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "یه سکوی متروکه توی این منطقه هست. اطلاعات محرمانه‌ای اونجا نگه‌داری می‌شه.",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_YGGDRASI,
			"text": "من می‌تونم بی‌صدا وارد بشم. تجربه‌ی این کار رو دارم.",
			"voice": "",
			"portrait": "yggdrasi"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "خوبه. یگدراسی و امیر، شما اول برید. ما پشت سرتون میایم.",
			"voice": "",
			"portrait": "naftkesh"
		}
	]

# ============================================================
# فصل چهارم: BLACK TIDE
# ============================================================

static func get_chapter_4_intro() -> Array:
	return [
		{
			"speaker": CHAR_SYSTEM,
			"text": "فصل چهارم: BLACK TIDE",
			"voice": "",
			"portrait": "system"
		},
		{
			"speaker": CHAR_WARDEN,
			"text": "نفتکش! تسلیم شو. راه فراری نداری. BLACK VEIL همه چیز رو کنترل می‌کنه.",
			"voice": "",
			"portrait": "warden"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "هرگز. تا وقتی من نفس می‌کشم، این کشتی رو ترک نمی‌کنم.",
			"voice": "",
			"portrait": "naftkesh"
		},
		{
			"speaker": CHAR_WARDEN,
			"text": "پس خودت انتخاب کردی. آماده باش، فرمانده.",
			"voice": "",
			"portrait": "warden"
		}
	]

# ============================================================
# دیالوگ‌های عمومی
# ============================================================

static func get_victory() -> Array:
	return [
		{
			"speaker": CHAR_NARGIL,
			"text": "منطقه امن شد، فرمانده.",
			"voice": "",
			"portrait": "nargil"
		},
		{
			"speaker": CHAR_NAFTKESH,
			"text": "کار خوبی کردید، تیم. ولی این تازه شروع ماجراست.",
			"voice": "",
			"portrait": "naftkesh"
		}
	]

static func get_defeat() -> Array:
	return [
		{
			"speaker": CHAR_SYSTEM,
			"text": "فرمانده از پا افتاد...",
			"voice": "",
			"portrait": "system"
		},
		{
			"speaker": CHAR_WARDEN,
			"text": "این پایان راه تو بود، نفتکش. BLACK VEIL پیروز شد.",
			"voice": "",
			"portrait": "warden"
		}
	]

static func get_team_orders() -> Dictionary:
	return {
		"follow": [
			{"speaker": CHAR_NAFTKESH, "text": "با من بیاید!", "voice": "", "portrait": "naftkesh"},
			{"speaker": CHAR_NARGIL, "text": "دریافت شد. پشت سرت هستیم.", "voice": "", "portrait": "nargil"}
		],
		"hold": [
			{"speaker": CHAR_NAFTKESH, "text": "این موقعیت رو حفظ کنید!", "voice": "", "portrait": "naftkesh"},
			{"speaker": CHAR_KHALF_KAR, "text": "موقعیت رو نگه می‌داریم.", "voice": "", "portrait": "khalf_kar"}
		],
		"attack": [
			{"speaker": CHAR_NAFTKESH, "text": "شلیک آزاد! پیشروی!", "voice": "", "portrait": "naftkesh"},
			{"speaker": CHAR_SAEED, "text": "بزنید! نذارید جلوتر بیان!", "voice": "", "portrait": "saeed"}
		],
		"retreat": [
			{"speaker": CHAR_NAFTKESH, "text": "عقب‌نشینی! به پوشش برید!", "voice": "", "portrait": "naftkesh"},
			{"speaker": CHAR_JALIL, "text": "همه به پشت! امن‌تره!", "voice": "", "portrait": "jalil"}
		]
	}

# ============================================================
# توابع کمکی
# ============================================================
static func get_all_characters() -> Array[String]:
	return [
		CHAR_NAFTKESH, CHAR_NARGIL, CHAR_KHALF_KAR, CHAR_AMIR,
		CHAR_BEST_TIME, CHAR_CAPTAIN, CHAR_KASRA, CHAR_SHAKERI,
		CHAR_JALIL, CHAR_BACTERIA, CHAR_SEEDROY, CHAR_ANANAS,
		CHAR_ALIFIFA, CHAR_NIMA, CHAR_SAEED, CHAR_YGGDRASI
	]

static func get_character_color(character: String) -> Color:
	match character:
		CHAR_NAFTKESH: return Color(0.8, 0.2, 0.2)
		CHAR_NARGIL: return Color(0.2, 0.6, 0.2)
		CHAR_KHALF_KAR: return Color(0.4, 0.4, 0.8)
		CHAR_AMIR: return Color(0.8, 0.6, 0.2)
		CHAR_BEST_TIME: return Color(0.6, 0.4, 0.8)
		CHAR_CAPTAIN: return Color(0.8, 0.8, 0.4)
		CHAR_KASRA: return Color(0.2, 0.8, 0.8)
		CHAR_SHAKERI: return Color(0.8, 0.4, 0.2)
		CHAR_JALIL: return Color(0.4, 0.8, 0.4)
		CHAR_BACTERIA: return Color(0.6, 0.8, 0.2)
		CHAR_SEEDROY: return Color(0.8, 0.8, 0.8)
		CHAR_ANANAS: return Color(0.8, 0.6, 0.6)
		CHAR_ALIFIFA: return Color(0.6, 0.2, 0.6)
		CHAR_NIMA: return Color(0.2, 0.6, 0.8)
		CHAR_SAEED: return Color(0.6, 0.3, 0.2)
		CHAR_YGGDRASI: return Color(0.2, 0.2, 0.2)
		CHAR_WARDEN: return Color(0.9, 0.1, 0.1)
		CHAR_RADIO: return Color(0.5, 0.5, 0.5)
		CHAR_SYSTEM: return Color(0.7, 0.7, 0.7)
		_: return Color.WHITE
