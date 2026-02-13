// ---------------------------------------------------------------------------
// Trick mastery system — inspired by progression tracking
// ---------------------------------------------------------------------------

/// Mastery state for each trick in the repertoire.
enum TrickMastery {
  locked('Locked', '\u{1F512}', 0),
  attempted('Attempted', '\u2197', 5),
  working('Working', '\u{1F6D6}', 5),
  landed('Landed', '\u2705', 15),
  mastered('Mastered', '\u2B50', 30);

  final String label;
  final String icon;
  final int xp;

  const TrickMastery(this.label, this.icon, this.xp);

  TrickMastery next() {
    final vals = TrickMastery.values;
    return vals[(index + 1) % vals.length];
  }
}

/// Difficulty level: 1 = beginner, 2 = intermediate, 3 = advanced.
enum TrickDifficulty {
  beginner(1, 'Beginner'),
  intermediate(2, 'Intermediate'),
  advanced(3, 'Advanced');

  final int stars;
  final String label;

  const TrickDifficulty(this.stars, this.label);
}

/// Risk assessment for a trick.
enum TrickRisk {
  low('LOW'),
  medium('MED'),
  high('HIGH');

  final String label;

  const TrickRisk(this.label);
}

/// Category of a trick.
enum TrickCategory {
  spin('Spins', 0xFF4FC3F7),
  flip('Flips', 0xFFFF7043),
  grab('Grabs', 0xFF81C784),
  freestyle('Freestyle', 0xFFFFD54F),
  rails('Rails', 0xFFCE93D8),
  backcountry('Backcountry', 0xFF4DB6AC),
  other('Other', 0xFF90A4AE);

  final String label;
  final int colorValue;

  const TrickCategory(this.label, this.colorValue);
}

/// XP level thresholds.
class TrickLevel {
  final String name;
  final int xpRequired;

  const TrickLevel(this.name, this.xpRequired);
}

const trickLevels = [
  TrickLevel('Tourist', 0),
  TrickLevel('Beginner', 100),
  TrickLevel('Apprentice', 250),
  TrickLevel('Rider', 450),
  TrickLevel('Freestyler', 700),
  TrickLevel('Shredder', 1000),
  TrickLevel('Ripper', 1350),
  TrickLevel('Pro', 1750),
  TrickLevel('Legend', 2200),
  TrickLevel('Apex Predator', 2700),
];

TrickLevel levelForXp(int xp) {
  TrickLevel current = trickLevels.first;
  for (final lvl in trickLevels) {
    if (xp >= lvl.xpRequired) {
      current = lvl;
    } else {
      break;
    }
  }
  return current;
}

/// Returns progress fraction [0..1] towards the next level.
double levelProgress(int xp) {
  final current = levelForXp(xp);
  final idx = trickLevels.indexOf(current);
  if (idx >= trickLevels.length - 1) return 1.0;
  final next = trickLevels[idx + 1];
  final range = next.xpRequired - current.xpRequired;
  if (range <= 0) return 1.0;
  return ((xp - current.xpRequired) / range).clamp(0.0, 1.0);
}

// ---------------------------------------------------------------------------
// Trick model
// ---------------------------------------------------------------------------

class Trick {
  final String id;
  final String name;
  final TrickCategory category;
  final TrickDifficulty difficulty;
  final TrickRisk risk;
  final String description;
  final String? prerequisiteId;

  /// Score multiplier applied to base jump score.
  /// Rotations: +0.5x per half-rotation (Front=1.0, 180=1.5, 360=2.0, …)
  /// Grabs/style: smaller multipliers that stack when combined.
  final double scoreMultiplier;

  const Trick({
    required this.id,
    required this.name,
    required this.category,
    this.difficulty = TrickDifficulty.beginner,
    this.risk = TrickRisk.low,
    this.description = '',
    this.prerequisiteId,
    this.scoreMultiplier = 1.0,
  });
}

// ---------------------------------------------------------------------------
// Full trick catalog
// ---------------------------------------------------------------------------

class TrickCatalog {
  // ---- SPINS ----
  // Multiplier: +0.5x per half-rotation (Front=1.0, 180=1.5, 360=2.0, …)
  // Switch adds +0.2x bonus on top
  static const spins = [
    Trick(
      id: 'front_jump',
      name: 'Front Jump',
      category: TrickCategory.spin,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Straight jump off a kicker. The foundation of all aerial tricks.',
      scoreMultiplier: 1.0,
    ),
    Trick(
      id: '180',
      name: '180',
      category: TrickCategory.spin,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Half rotation — land switch.',
      scoreMultiplier: 1.5,
    ),
    Trick(
      id: '360',
      name: '360',
      category: TrickCategory.spin,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Full rotation — land forwards.',
      prerequisiteId: '180',
      scoreMultiplier: 2.0,
    ),
    Trick(
      id: '540',
      name: '540',
      category: TrickCategory.spin,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: '1.5 rotations — land switch.',
      prerequisiteId: '360',
      scoreMultiplier: 2.5,
    ),
    Trick(
      id: '720',
      name: '720',
      category: TrickCategory.spin,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: 'Two full rotations.',
      prerequisiteId: '540',
      scoreMultiplier: 3.0,
    ),
    Trick(
      id: '900',
      name: '900',
      category: TrickCategory.spin,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: '2.5 rotations — land switch.',
      prerequisiteId: '720',
      scoreMultiplier: 3.5,
    ),
    Trick(
      id: '1080',
      name: '1080',
      category: TrickCategory.spin,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: 'Three full rotations.',
      prerequisiteId: '900',
      scoreMultiplier: 4.0,
    ),
    Trick(
      id: 'switch_180',
      name: 'Switch 180',
      category: TrickCategory.spin,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Take off switch, rotate 180 to land forwards.',
      scoreMultiplier: 1.7,
    ),
    Trick(
      id: 'switch_360',
      name: 'Switch 360',
      category: TrickCategory.spin,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Take off switch, full rotation.',
      prerequisiteId: 'switch_180',
      scoreMultiplier: 2.2,
    ),
    Trick(
      id: 'switch_540',
      name: 'Switch 540',
      category: TrickCategory.spin,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: 'Take off switch, 1.5 rotations.',
      prerequisiteId: 'switch_360',
      scoreMultiplier: 2.7,
    ),
  ];

  // ---- FLIPS ----
  // Flips include inversion — multipliers match rotation equivalent + bonus
  static const flips = [
    Trick(
      id: 'backflip',
      name: 'Backflip',
      category: TrickCategory.flip,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.high,
      description: 'Full backward rotation on the sagittal axis.',
      scoreMultiplier: 2.0,
    ),
    Trick(
      id: 'frontflip',
      name: 'Frontflip',
      category: TrickCategory.flip,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.high,
      description: 'Full forward rotation.',
      scoreMultiplier: 2.0,
    ),
    Trick(
      id: 'misty_flip',
      name: 'Misty Flip',
      category: TrickCategory.flip,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: 'Off-axis front flip with a 540 spin.',
      scoreMultiplier: 3.0,
    ),
    Trick(
      id: 'cork_540',
      name: 'Cork 540',
      category: TrickCategory.flip,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: 'Off-axis 540 with an inverted component.',
      scoreMultiplier: 3.0,
    ),
    Trick(
      id: 'cork_720',
      name: 'Cork 720',
      category: TrickCategory.flip,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: 'Off-axis 720 with an inverted component.',
      prerequisiteId: 'cork_540',
      scoreMultiplier: 3.5,
    ),
    Trick(
      id: 'rodeo_540',
      name: 'Rodeo 540',
      category: TrickCategory.flip,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: 'Backflip with a 180 — off-axis backside rotation.',
      scoreMultiplier: 3.0,
    ),
    Trick(
      id: 'rodeo_720',
      name: 'Rodeo 720',
      category: TrickCategory.flip,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: 'Backflip with a 360 — off-axis backside rotation.',
      prerequisiteId: 'rodeo_540',
      scoreMultiplier: 3.5,
    ),
    Trick(
      id: 'dspin',
      name: 'D-Spin',
      category: TrickCategory.flip,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: 'Double cork-style off-axis rotation.',
      scoreMultiplier: 4.0,
    ),
  ];

  // ---- GRABS ----
  // Grabs are style bonuses — they stack with rotation multipliers.
  // When combined (e.g. 360 + Mute), the multipliers multiply together.
  static const grabs = [
    Trick(
      id: 'safety',
      name: 'Safety',
      category: TrickCategory.grab,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Grab the outside edge of the ski between the bindings. The safest grab.',
      scoreMultiplier: 1.2,
    ),
    Trick(
      id: 'mute',
      name: 'Mute',
      category: TrickCategory.grab,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Cross-body grab on the toe-side edge of the opposite ski.',
      scoreMultiplier: 1.3,
    ),
    Trick(
      id: 'indy',
      name: 'Indy',
      category: TrickCategory.grab,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Same-hand grab on the toe-side edge between bindings.',
      scoreMultiplier: 1.3,
    ),
    Trick(
      id: 'stalefish',
      name: 'Stalefish',
      category: TrickCategory.grab,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.low,
      description: 'Reach behind and grab the heel edge of the opposite ski.',
      scoreMultiplier: 1.4,
    ),
    Trick(
      id: 'melon',
      name: 'Melon',
      category: TrickCategory.grab,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.low,
      description: 'Cross-body grab on the heel edge between bindings.',
      scoreMultiplier: 1.4,
    ),
    Trick(
      id: 'tail_grab',
      name: 'Tail Grab',
      category: TrickCategory.grab,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Grab the tail of the ski behind the rear binding.',
      scoreMultiplier: 1.4,
    ),
    Trick(
      id: 'nose_grab',
      name: 'Nose Grab',
      category: TrickCategory.grab,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Grab the tip of the ski in front of the front binding.',
      scoreMultiplier: 1.4,
    ),
    Trick(
      id: 'japan',
      name: 'Japan',
      category: TrickCategory.grab,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Mute grab with the knee pulled behind — very stylish.',
      scoreMultiplier: 1.5,
    ),
    Trick(
      id: 'truck_driver',
      name: 'Truck Driver',
      category: TrickCategory.grab,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Grab both ski tips at the same time.',
      scoreMultiplier: 1.5,
    ),
    Trick(
      id: 'blunt',
      name: 'Blunt',
      category: TrickCategory.grab,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Grab the tail of the opposite ski behind your back.',
      scoreMultiplier: 1.5,
    ),
  ];

  // ---- FREESTYLE ----
  static const freestyle = [
    Trick(
      id: 'straight_air',
      name: 'Straight Air',
      category: TrickCategory.freestyle,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'A clean jump with stable body position. The base of everything.',
      scoreMultiplier: 1.0,
    ),
    Trick(
      id: 'spread_eagle',
      name: 'Spread Eagle',
      category: TrickCategory.freestyle,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Spread legs and arms wide mid-air — classic style.',
      scoreMultiplier: 1.1,
    ),
    Trick(
      id: 'daffy',
      name: 'Daffy',
      category: TrickCategory.freestyle,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'One ski forward, one ski back — splits in the air.',
      scoreMultiplier: 1.1,
    ),
    Trick(
      id: 'iron_cross',
      name: 'Iron Cross',
      category: TrickCategory.freestyle,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Cross your skis in an X shape mid-air.',
      scoreMultiplier: 1.3,
    ),
    Trick(
      id: 'helicopter',
      name: 'Helicopter',
      category: TrickCategory.freestyle,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Flat spin rotation while keeping the body horizontal.',
      scoreMultiplier: 1.5,
    ),
    Trick(
      id: 'method',
      name: 'Method',
      category: TrickCategory.freestyle,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.low,
      description: 'Kick both skis to one side while grabbing — borrowed from snowboard.',
      scoreMultiplier: 1.3,
    ),
    Trick(
      id: 'butter',
      name: 'Butter',
      category: TrickCategory.freestyle,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Press on the nose or tail of the ski and spin on the snow.',
      scoreMultiplier: 1.1,
    ),
    Trick(
      id: 'shifty',
      name: 'Shifty',
      category: TrickCategory.freestyle,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Rotate legs 90 degrees mid-air then bring them back before landing.',
      scoreMultiplier: 1.2,
    ),
  ];

  // ---- RAILS ----
  static const rails = [
    Trick(
      id: 'fifty_fifty',
      name: '50-50',
      category: TrickCategory.rails,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.medium,
      description: 'Slide straight along the rail with both skis parallel.',
      scoreMultiplier: 1.3,
    ),
    Trick(
      id: 'boardslide',
      name: 'Boardslide',
      category: TrickCategory.rails,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Slide sideways across the rail, perpendicular to it.',
      scoreMultiplier: 1.5,
    ),
    Trick(
      id: 'nose_press',
      name: 'Nose Press',
      category: TrickCategory.rails,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Slide the rail while pressing on the tips of the skis.',
      scoreMultiplier: 1.5,
    ),
    Trick(
      id: 'tail_press',
      name: 'Tail Press',
      category: TrickCategory.rails,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Slide the rail while pressing on the tails of the skis.',
      scoreMultiplier: 1.5,
    ),
    Trick(
      id: 'lipslide',
      name: 'Lipslide',
      category: TrickCategory.rails,
      difficulty: TrickDifficulty.advanced,
      risk: TrickRisk.high,
      description: 'Approach the rail and pass your skis over the top to slide.',
      scoreMultiplier: 2.0,
    ),
  ];

  // ---- BACKCOUNTRY ----
  static const backcountry = [
    Trick(
      id: 'controlled_slide',
      name: 'Controlled Slide',
      category: TrickCategory.backcountry,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Controlled sideslip descent on steep terrain.',
      scoreMultiplier: 1.0,
    ),
    Trick(
      id: 'traverse',
      name: 'Traverse',
      category: TrickCategory.backcountry,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Diagonal crossing of a slope to control descent.',
      scoreMultiplier: 1.0,
    ),
    Trick(
      id: 'kick_turn',
      name: 'Kick-Turn',
      category: TrickCategory.backcountry,
      difficulty: TrickDifficulty.beginner,
      risk: TrickRisk.low,
      description: 'Standing turn on a steep slope by lifting one ski at a time.',
      scoreMultiplier: 1.0,
    ),
    Trick(
      id: 'off_piste',
      name: 'Off-Piste',
      category: TrickCategory.backcountry,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Skiing outside of groomed runs on natural terrain.',
      scoreMultiplier: 1.2,
    ),
    Trick(
      id: 'forest_skiing',
      name: 'Forest Skiing',
      category: TrickCategory.backcountry,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.high,
      description: 'Navigating through trees — requires quick reactions.',
      scoreMultiplier: 1.3,
    ),
    Trick(
      id: 'switch_emergency',
      name: 'Switch Emergency',
      category: TrickCategory.backcountry,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Quick 180 switch to avoid obstacles or stop fast.',
      scoreMultiplier: 1.3,
    ),
    Trick(
      id: 'powder',
      name: 'Powder',
      category: TrickCategory.backcountry,
      difficulty: TrickDifficulty.intermediate,
      risk: TrickRisk.medium,
      description: 'Floating turns in deep fresh snow.',
      scoreMultiplier: 1.2,
    ),
  ];

  static const allByCategory = {
    TrickCategory.spin: spins,
    TrickCategory.flip: flips,
    TrickCategory.grab: grabs,
    TrickCategory.freestyle: freestyle,
    TrickCategory.rails: rails,
    TrickCategory.backcountry: backcountry,
  };

  static List<Trick> get all =>
      allByCategory.values.expand((list) => list).toList();

  static Trick? findById(String id) {
    for (final tricks in allByCategory.values) {
      for (final t in tricks) {
        if (t.id == id) return t;
      }
    }
    return null;
  }

  static Trick? findByName(String name) {
    for (final tricks in allByCategory.values) {
      for (final t in tricks) {
        if (t.name == name) return t;
      }
    }
    return null;
  }

  /// All trick names — used by the trick picker when labeling jumps.
  static const allByLabelCategory = {
    'Spins': spins,
    'Flips': flips,
    'Grabs': grabs,
    'Freestyle': freestyle,
    'Rails': rails,
    'Backcountry': backcountry,
  };
}

// ---------------------------------------------------------------------------
// Trick label utilities (for jump annotation)
// ---------------------------------------------------------------------------

List<String> parseTrickLabel(String? label) {
  if (label == null || label.isEmpty) return [];
  return label.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
}

String formatTrickLabel(List<String> tricks) {
  return tricks.join(',');
}

String displayTrickLabel(String? label) {
  final tricks = parseTrickLabel(label);
  if (tricks.isEmpty) return 'Straight Air';
  return tricks.join(' + ');
}

/// Compute combined score multiplier from a trick label string.
/// When multiple tricks are combined (e.g. "360,Mute"), their multipliers
/// are multiplied together: 360 (2.0x) * Mute (1.3x) = 2.6x.
double trickMultiplierFromLabel(String? label) {
  final names = parseTrickLabel(label);
  if (names.isEmpty) return 1.0;
  double multiplier = 1.0;
  for (final name in names) {
    final trick = TrickCatalog.findByName(name);
    if (trick != null) {
      multiplier *= trick.scoreMultiplier;
    }
  }
  return multiplier;
}

/// Compute the full jump score with trick multiplier applied.
/// Base score = (airtimeMs / 100) * 40 + heightM * 30 + distanceM * 10
/// Final score = base * trickMultiplier
double computeJumpScore({
  required int airtimeMs,
  required double heightM,
  required double distanceM,
  String? trickLabel,
}) {
  final base = (airtimeMs / 100) * 40 + heightM * 30 + distanceM * 10;
  return base * trickMultiplierFromLabel(trickLabel);
}
