import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/tricks/trick_providers.dart';

// ---------------------------------------------------------------------------
// Learn module — each entry represents a bite-sized lesson
// ---------------------------------------------------------------------------

class LearnModule {
  final String id;
  final String title;
  final String emoji;
  final String category;
  final int xpReward;
  final List<String> paragraphs;

  const LearnModule({
    required this.id,
    required this.title,
    required this.emoji,
    required this.category,
    this.xpReward = 10,
    required this.paragraphs,
  });
}

// ---------------------------------------------------------------------------
// Module catalog — add new learn modules here
// ---------------------------------------------------------------------------

class LearnCatalog {
  static const categories = [
    'Security',
    'Mountain',
    'Backcountry Gear',
  ];

  static const categoryIcons = {
    'Security': Icons.health_and_safety,
    'Mountain': Icons.terrain,
    'Backcountry Gear': Icons.build,
  };

  static const categoryColors = {
    'Security': Color(0xFFFF7043),
    'Mountain': Color(0xFFCE93D8),
    'Backcountry Gear': Color(0xFF4FC3F7),
  };

  static const all = [
    // ---- SECURITY ----
    LearnModule(
      id: 'survival_checklist',
      title: 'Apex Survival Checklist',
      emoji: '\u{1F480}',
      category: 'Security',
      xpReward: 20,
      paragraphs: [
        'POLE STRAPS: Never put your hands through pole straps off-piste. In an avalanche, poles become anchors that drag you under. In trees, a snagged pole dislocates your shoulder. Cut the straps or hold them loose.',
        'DIN SETTINGS: Check your binding release before every session. With a fragile knee, stay at DIN 8\u20139. If the rental set it to 11\u201312, it\'s too tight \u2014 in a slow torsion fall the ski won\'t release and your knee takes the twist instead.',
        'STOPPING POSITION: Never stop below a ridge break \u2014 you\'re invisible to skiers coming at 80 km/h from above. Always stop on the side of the trail or at the top of a bump where you can be seen. Face uphill when stopped.',
        'THE COLD KNEE: After pushing hard, your joint is warm. Sitting 15 min on a freezing chairlift thickens the synovial fluid and stiffens ligaments. Keep your leg moving on every lift ride. After a lunch break, do 2 easy turns before going hard.',
        'THE EGO RULE: 90% of injuries happen on the "last run" when legs are burned and focus is gone. If your quads tremble in a tuck or you catch yourself skiing backseat \u2014 it\'s over. Don\'t attempt that one more jump at 4:30 PM when the light drops and the snow turns to concrete.',
        'OFF-PISTE KIT: DVA on your body (not in the bag), batteries fresh, plus shovel + probe in the pack. Never go off-piste alone \u2014 if you\'re buried, you can\'t dig yourself out.',
      ],
    ),
    LearnModule(
      id: 'how_dva_works',
      title: 'How a DVA Works',
      emoji: '\u{1F4E1}',
      category: 'Security',
      xpReward: 20,
      paragraphs: [
        'A DVA (avalanche transceiver) is a radio on the global 457 kHz frequency. In SEND mode (default while skiing) it pulses an electromagnetic signal every second \u2014 like a lighthouse blinking "I\'m here." The signal passes through 3+ meters of snow.',
        'In SEARCH mode (activated when someone is buried) it becomes a listener. Modern digital 3-antenna DVAs (Mammut Barryvox, Ortovox Diract) use antennas on the X, Y, Z axes to triangulate the signal: they display distance in meters and a directional arrow.',
        'Phase 1 \u2014 Signal Search: screen is blank. Run in zigzags across the avalanche debris until the first "beep" appears. Phase 2 \u2014 Coarse Search: follow the arrow, run toward the decreasing number. Slow down at 3 m.',
        'Phase 3 \u2014 Fine Search: below 3 m the arrow vanishes (signal saturates). Drop to your knees, move the DVA in a cross pattern at snow level to find the smallest number (e.g. 0.8 m). That\'s where you probe.',
        'INTERFERENCE WARNING: your phone must be 20 cm away from the DVA while skiing, 50 cm while searching. GoPro and magnetic car keys also jam the signal. Airplane mode is safest.',
        'A DVA only tells you WHERE someone is buried. Without a probe (to pinpoint depth) and a shovel (to dig), it\'s useless \u2014 hand-digging 1.5 m of avalanche debris takes over an hour. The victim has ~15 minutes of air. With a shovel: 10 minutes.',
      ],
    ),
    LearnModule(
      id: 'unstuck_deep_snow',
      title: 'Getting Unstuck in Deep Snow',
      emoji: '\u{26A0}',
      category: 'Security',
      xpReward: 20,
      paragraphs: [
        'THE #1 RULE: Never take off your skis in deep powder. Your boots are ~300 cm\u00B2 of surface. Your skis are ~3,500 cm\u00B2. Without skis you sink instantly and exhaust yourself in 3 minutes. A pro will crawl for an hour with skis on rather than unclip for one second.',
        'THE SEAL TECHNIQUE: If you need to move uphill without skins, stay on your knees or belly with skis on. Plant both poles far ahead, pull yourself forward. You glide, not walk.',
        'BUILDING A PLATFORM: If you fall and you\'re stuck, don\'t thrash. Use your skis and poles to pack down the snow around you. Create a solid "step" before trying to stand.',
        'GETTING UP (THE CROSS): Pushing on one pole in powder \u2014 it sinks. Cross both poles in an X on the snow surface, press your palm on the center of the X, and push up. The cross distributes your weight.',
        'THE PANIC CYCLE: Fall \u2192 frustration \u2192 violent effort (anaerobic) \u2192 hyperventilation \u2192 acidosis \u2192 mental panic \u2192 bad decisions (taking off skis). The fix: when things go wrong, freeze for 10 seconds. Breathe. Drink water. Think. Then act slowly.',
        'HYPOGLYCEMIA: Stress burns glucose 10\u00D7 faster than sport. Always carry a cereal bar or energy gel in your POCKET (not the bag) for emergencies.',
      ],
    ),
    LearnModule(
      id: 'terrain_traps',
      title: 'Terrain Traps & Navigation',
      emoji: '\u{1F3D4}',
      category: 'Security',
      xpReward: 15,
      paragraphs: [
        'FLATS & BOWLS: In freeride, speed is life. If you see a flat zone or an uphill ahead, arrive at full speed. If you arrive slowly, you\'re stranded in the middle. Always scan 50 m ahead \u2014 don\'t stare at your tips.',
        'TREE WELLS: Under the low branches of spruce trees, the snow is hollow. If you fall headfirst against the trunk, you cannot get out \u2014 death by suffocation. Never brush close to a snow-loaded spruce.',
        'HIDDEN CREEKS: Valley floors (especially under ridgelines) hide streams under snow bridges. If the bridge collapses, you fall into 0\u00B0C water with 2 m snow walls around you.',
        'POINT OF NO RETURN: Before dropping into a slope, ask: "If it\'s blocked at the bottom, can I climb back up?" If the answer is no and you can\'t see the exit \u2014 don\'t go.',
        'ESCAPE ROUTE: Always identify a Plan B before committing. If the face turns icy or triggers a slide, where do you bail to safety? A ridge, dense forest, or marked piste.',
      ],
    ),

    // ---- MOUNTAIN ----
    LearnModule(
      id: 'isola_fatalities',
      title: 'Fatal Incidents at Isola',
      emoji: '\u{1F3D4}',
      category: 'Mountain',
      xpReward: 20,
      paragraphs: [
        'FEB 2024 \u2014 Combe Grosse (North Face): A 50-year-old experienced ski tourer triggered a wind slab ~100 m wide. Buried under 1.5 m. Despite carrying a DVA and rapid rescue response, he was in cardiac arrest at extraction.',
        'MAR 2015 \u2014 M\u00E9n\u00E9 / Saint-Sauveur: Two station employees (a 50-year-old patroller and a 58-year-old groomer) were killed by a massive avalanche while securing the domain before opening. If it kills professionals who know the terrain by heart, it can kill anyone.',
        'DEC 2010 \u2014 Col de la Lombarde: A 19-year-old skier was doing "close to piste" off-piste near the Col. A wind slab released. He was found by avalanche dogs, but too late. The Col is a wind corridor \u2014 the snow is often "plated" (hard on top, hollow below).',
        'MAR 2009 \u2014 T\u00EAte du M\u00E9n\u00E9: A 26-year-old snowboarder went off-piste when avalanche risk was 4/5 (High). He triggered a slide that swept him over rock cliffs. Risk level 4 is an absolute stop signal.',
        'DEATH ZONES: Lombarde / Combe Grosse \u2014 the Italian border. Extreme wind creates a wind-slab factory. Most dangerous for triggering a slab just by skiing near the edge of a groomed run. M\u00E9n\u00E9 \u2014 steep and rocky. Avalanches here drag you over rocks, causing fatal trauma before burial.',
      ],
    ),
    LearnModule(
      id: 'snow_physics',
      title: 'Snow Physics & Landing',
      emoji: '\u2744',
      category: 'Mountain',
      xpReward: 15,
      paragraphs: [
        'In inline skating the ground is always hard. In off-piste, snow changes every meter. Learning to read it from above is a survival skill.',
        'AVOID: Shiny snow (ice), snow with tiny ripples (wind crust), and depressions around trees (tree wells \u2014 you fall in and can\'t get out).',
        'TARGET: Matte, uniform snow, and especially snow on a slope. A sloped landing absorbs impact; a flat landing destroys knees.',
        'GOLDEN RULE: Never jump onto flat ground. You need a landing steeper than your flight arc. Dropping 4 m onto flat at 80 kg produces forces that will blow out your knees.',
        'WIND SLABS: Wind transports snow and packs it behind ridges, forming a trap. If the snow makes a "whump" sound (like a drum) under your skis, or cracks shoot out in front of you \u2014 STOP. Turn around or descend straight to safety (tree zone or anchored rocks).',
      ],
    ),
    LearnModule(
      id: 'pop_and_stomp',
      title: 'Pop & Stomp Technique',
      emoji: '\u{1F680}',
      category: 'Mountain',
      xpReward: 15,
      paragraphs: [
        'THE POP: Use the tail of the ski as a spring. The "Ollie" in skiing: compress as you approach the lip, then extend explosively through ankles, knees, and hips at the edge. This is what gives you height.',
        'THE STOMP: The signature backcountry move. In the air, stay tucked. As you spot the landing, extend your legs firmly to "stomp" the snow. You don\'t absorb the landing passively \u2014 you attack it.',
        'The difference between a crash and a clean landing is aggression. Passive = the snow decides. Active stomp = you decide.',
        'Practice on small natural side hits before taking it to big terrain. Feel the pop timing at low speed. A solid pop on a 3 m natural kicker beats a lazy launch off a 10 m park table.',
      ],
    ),

    // ---- GEAR CHOICES EXPLAINED ----
    LearnModule(
      id: 'ski_selection',
      title: 'Freeride Ski Selection',
      emoji: '\u{1F3BF}',
      category: 'Backcountry Gear',
      xpReward: 15,
      paragraphs: [
        'You need a wide ski (to float in powder) with pop (spring for jumping). The sweet spot for a resort like Isola: 105\u2013115 mm waist width.',
        'PROFILE: Double rocker (tip and tail raised). This lets you land switch or bail without catching an edge and planting face-first.',
        'FACTION MANA 3 / PRODIGY 3: The Candide Thovex spirit. Built to be abused. Playful and forgiving, great pop.',
        'ATOMIC BENT CHETLER 110: Very playful, turns on its own, but demands you stay centered. Rewards good technique, punishes backseat skiing.',
        'BLACK CROWS ANIMA: A stability monster. Made for going fast and sending cliffs. Less playful, more confidence at speed.',
      ],
    ),
    LearnModule(
      id: 'pivot_bindings',
      title: 'Look Pivot Bindings',
      emoji: '\u2699',
      category: 'Backcountry Gear',
      xpReward: 15,
      paragraphs: [
        'The Look Pivot (15 or 18) is THE pro freestyle binding. The heel piece pivots under your foot instead of lifting up like regular bindings.',
        'It absorbs lateral shocks without releasing \u2014 so you don\'t lose a ski mid-air during a 360. But it releases instantly under dangerous torsion to protect your ACL.',
        'It\'s built from metal, not plastic. Virtually indestructible. That\'s why every park rat and big mountain skier uses them.',
        'DIN SETTING: With a fragile knee, set to 8 or 9. Better to eject for nothing than to not eject at all. In a slow torsion fall (the worst for meniscus), if DIN is at 11\u201312, the ski stays on and your knee rotates instead.',
      ],
    ),
    LearnModule(
      id: 'boot_choice',
      title: 'Freeride Boots (Flex 130)',
      emoji: '\u{1F462}',
      category: 'Backcountry Gear',
      xpReward: 15,
      paragraphs: [
        'FLEX 130: At ~80 kg with athletic background, you need direct power transmission. Below 130 flex the boot collapses in hard carves and absorbs your pop. Above 140 and you can\'t flex enough to absorb landings.',
        'TYPE: Freeride boots have rubber Vibram/Grip Walk soles for hiking to spots without slipping on rocks. Regular race boots have smooth plastic soles.',
        'CABRIO (3-piece) DESIGN: The shell has 3 separate parts instead of the traditional 4-buckle overlap. The flex is progressive \u2014 soft initially, then firm. Freestylers love it for the shin comfort and shock absorption.',
        'MODELS: Dalbello Lupo (best shin comfort, Cabrio design), Lange XT3 (tight and precise), Full Tilt / K2 (great progressive flex, iconic look). Hard spot on your tibia = CHANGE boots. Heel lifting = CHANGE boots.',
      ],
    ),
    LearnModule(
      id: 'stealth_protection',
      title: 'Stealth Protection Setup',
      emoji: '\u{1F6E1}',
      category: 'Backcountry Gear',
      xpReward: 15,
      paragraphs: [
        'EVOC BACKPACK WITH SPINE PROTECTOR: A certified back plate is built into the pack. It hugs your back, doesn\'t shift during a 360, and you forget it\'s there. Holds all your safety gear.',
        'DVA HARNESS: Worn under your jacket. The Barryvox S (best range) or Ortovox Diract Voice (talks to you: "go left", "crouch down" \u2014 ideal in panic) clips to the harness and stays invisible.',
        'KNEE BRACE (ZAMST ZK-7): Lateral resin/carbon stays mechanically replace tired ligaments. Prevents drawer motion and rotation (ACL protection). Must be worn tight under your ski pants \u2014 nobody sees it.',
      ],
    ),
  ];

  static List<LearnModule> byCategory(String category) =>
      all.where((m) => m.category == category).toList();
}

// ---------------------------------------------------------------------------
// Provider — tracks which modules have been completed
// ---------------------------------------------------------------------------

const _learnProgressKey = 'learn_progress';

class LearnProgressNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences _prefs;

  LearnProgressNotifier(this._prefs) : super({}) {
    _load();
  }

  void _load() {
    final raw = _prefs.getString(_learnProgressKey);
    if (raw != null) {
      final List<dynamic> list = json.decode(raw);
      state = list.cast<String>().toSet();
    }
  }

  Future<void> _save() async {
    await _prefs.setString(_learnProgressKey, json.encode(state.toList()));
  }

  bool isCompleted(String moduleId) => state.contains(moduleId);

  Future<void> markCompleted(String moduleId) async {
    if (state.contains(moduleId)) return;
    state = {...state, moduleId};
    await _save();
  }

  int get completedCount => state.length;
  int get totalCount => LearnCatalog.all.length;
  int get totalXpEarned {
    int xp = 0;
    for (final m in LearnCatalog.all) {
      if (state.contains(m.id)) xp += m.xpReward;
    }
    return xp;
  }
}

final learnProgressProvider =
    StateNotifierProvider<LearnProgressNotifier, Set<String>>(
  (ref) => LearnProgressNotifier(ref.watch(sharedPrefsProvider)),
);

// ---------------------------------------------------------------------------
// Learn screen
// ---------------------------------------------------------------------------

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(learnProgressProvider);
    final notifier = ref.read(learnProgressProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Learn', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Progress summary
          _ProgressCard(notifier: notifier),
          // Categories
          ...LearnCatalog.categories.map((cat) {
            final modules = LearnCatalog.byCategory(cat);
            if (modules.isEmpty) return const SizedBox.shrink();
            final catColor =
                LearnCatalog.categoryColors[cat] ?? const Color(0xFF90A4AE);
            final catIcon =
                LearnCatalog.categoryIcons[cat] ?? Icons.school;
            final doneInCat =
                modules.where((m) => completed.contains(m.id)).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Icon(catIcon, color: catColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        cat.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: catColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$doneInCat / ${modules.length}',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
                ...modules.map((m) => _ModuleTile(
                      module: m,
                      isDone: completed.contains(m.id),
                      catColor: catColor,
                    )),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress card
// ---------------------------------------------------------------------------

class _ProgressCard extends StatelessWidget {
  final LearnProgressNotifier notifier;

  const _ProgressCard({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final done = notifier.completedCount;
    final total = notifier.totalCount;
    final xp = notifier.totalXpEarned;
    final pct = total > 0 ? done / total : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Knowledge',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '$done / $total lessons',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$xp XP earned',
            style: const TextStyle(
              color: Color(0xFFFFCA28),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFFCA28)),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Module tile
// ---------------------------------------------------------------------------

class _ModuleTile extends StatelessWidget {
  final LearnModule module;
  final bool isDone;
  final Color catColor;

  const _ModuleTile({
    required this.module,
    required this.isDone,
    required this.catColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone
              ? catColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        leading: Text(module.emoji, style: const TextStyle(fontSize: 22)),
        title: Text(
          module.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDone ? Colors.white : Colors.white54,
          ),
        ),
        subtitle: Text(
          isDone ? 'Completed \u2022 +${module.xpReward} XP' : '${module.xpReward} XP',
          style: TextStyle(
            fontSize: 11,
            color: isDone ? catColor.withValues(alpha: 0.7) : Colors.white30,
          ),
        ),
        trailing: isDone
            ? Icon(Icons.check_circle, color: catColor, size: 22)
            : const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ModuleDetailScreen(module: module),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Module detail screen — reading the lesson
// ---------------------------------------------------------------------------

class _ModuleDetailScreen extends ConsumerWidget {
  final LearnModule module;

  const _ModuleDetailScreen({required this.module});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(learnProgressProvider);
    final isDone = completed.contains(module.id);
    final theme = Theme.of(context);
    final catColor =
        LearnCatalog.categoryColors[module.category] ?? const Color(0xFF90A4AE);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(module.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: catColor.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(module.emoji, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            module.category,
                            style: TextStyle(fontSize: 12, color: catColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFCA28).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${module.xpReward} XP',
                        style: const TextStyle(
                          color: Color(0xFFFFCA28),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Paragraphs
          ...module.paragraphs.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: catColor.withValues(alpha: 0.15),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: catColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 16),

          // Mark as read button
          if (!isDone)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ref
                      .read(learnProgressProvider.notifier)
                      .markCompleted(module.id);
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Mark as Read'),
                style: FilledButton.styleFrom(
                  backgroundColor: catColor,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: catColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: catColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: catColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
