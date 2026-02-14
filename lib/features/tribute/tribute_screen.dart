import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ---------------------------------------------------------------------------
// Data — EAWS avalanche fatalities per season per country (2017-2026)
// Source: https://www.avalanches.org/fatalities/
// ---------------------------------------------------------------------------

class SeasonData {
  final String season;
  final int total;
  final Map<String, int> byCountry;
  const SeasonData(this.season, this.total, this.byCountry);
}

const _seasons = [
  SeasonData('2025/26', 77, {'France': 19, 'Italy': 21, 'Austria': 12, 'Switzerland': 9, 'Spain': 8, 'Slovakia': 3, 'Slovenia': 3, 'Andorra': 1, 'Norway': 0, 'Germany': 0}),
  SeasonData('2024/25', 70, {'France': 21, 'Switzerland': 20, 'Italy': 11, 'Austria': 8, 'Norway': 5, 'Spain': 2, 'Sweden': 2, 'Slovakia': 1, 'Germany': 0, 'Slovenia': 0}),
  SeasonData('2023/24', 87, {'Switzerland': 20, 'France': 16, 'Austria': 16, 'Italy': 13, 'Norway': 4, 'Finland': 2, 'Poland': 2, 'Romania': 2, 'Slovakia': 2, 'Spain': 2, 'Germany': 1, 'Slovenia': 1}),
  SeasonData('2022/23', 104, {'France': 25, 'Italy': 24, 'Switzerland': 23, 'Austria': 15, 'Norway': 8, 'Slovakia': 4, 'Poland': 3, 'Romania': 1, 'UK': 1, 'Germany': 0}),
  SeasonData('2021/22', 70, {'Austria': 18, 'Switzerland': 14, 'France': 9, 'Italy': 8, 'Norway': 5, 'Slovakia': 5, 'Germany': 4, 'Poland': 2, 'Romania': 2, 'Spain': 2, 'Iceland': 1}),
  SeasonData('2020/21', 131, {'France': 40, 'Switzerland': 32, 'Italy': 25, 'Austria': 14, 'Norway': 9, 'Spain': 4, 'Slovenia': 3, 'Czechia': 2, 'Slovakia': 2, 'Germany': 0}),
  SeasonData('2019/20', 54, {'Austria': 14, 'Italy': 13, 'France': 12, 'Switzerland': 7, 'Norway': 3, 'Iceland': 1, 'Romania': 1, 'Slovakia': 1, 'Spain': 1, 'UK': 1}),
  SeasonData('2018/19', 95, {'Austria': 22, 'Switzerland': 21, 'Italy': 15, 'France': 13, 'Norway': 13, 'Slovakia': 4, 'Germany': 3, 'Romania': 3, 'Spain': 1}),
  SeasonData('2017/18', 147, {'Italy': 44, 'France': 37, 'Switzerland': 27, 'Austria': 10, 'Romania': 7, 'Norway': 6, 'Slovakia': 5, 'Spain': 4, 'Germany': 2, 'Slovenia': 1, 'Andorra': 1}),
];

// ---------------------------------------------------------------------------
// Isola 2000 fatal incidents
// ---------------------------------------------------------------------------

class FatalIncident {
  final String date;
  final String location;
  final String description;
  const FatalIncident(this.date, this.location, this.description);
}

const _isolaIncidents = [
  FatalIncident(
    'Feb 2024',
    'Combe Grosse (North Face)',
    'A 50-year-old experienced ski tourer triggered a wind slab ~100 m wide. Buried under 1.5 m. Despite carrying a DVA and rapid rescue response, he was in cardiac arrest at extraction.',
  ),
  FatalIncident(
    'Mar 2015',
    'Mene / Saint-Sauveur',
    'Two station employees (a 50-year-old patroller and a 58-year-old groomer) were killed by a massive avalanche while securing the domain before opening. If it kills professionals who know the terrain by heart, it can kill anyone.',
  ),
  FatalIncident(
    'Dec 2010',
    'Col de la Lombarde',
    'A 19-year-old skier was doing "close to piste" off-piste near the Col. A wind slab released. He was found by avalanche dogs, but too late. The Col is a wind corridor — the snow is often "plated" (hard on top, hollow below).',
  ),
  FatalIncident(
    'Mar 2009',
    'Tete du Mene',
    'A 26-year-old snowboarder went off-piste when avalanche risk was 4/5 (High). He triggered a slide that swept him over rock cliffs. Risk level 4 is an absolute stop signal.',
  ),
];

// ---------------------------------------------------------------------------
// Current season 2025/26 incidents (from EAWS)
// ---------------------------------------------------------------------------

class EawsIncident {
  final String date;
  final String location;
  final String country;
  final int deaths;
  final String activity;
  final String problem;
  const EawsIncident(this.date, this.location, this.country, this.deaths, this.activity, this.problem);
}

const _currentSeasonIncidents = [
  EawsIncident('2025-10-05', 'Tosc south slope', 'Slovenia', 3, 'Hiking', 'Wind slab'),
  EawsIncident('2025-11-01', 'Vertainspitze - Cima Vertana', 'Italy', 5, 'Mountaineering', 'Persistent weak layer'),
  EawsIncident('2025-11-27', 'Halasova jama', 'Slovakia', 1, 'Hiking', 'New snow'),
  EawsIncident('2025-11-29', 'Clot de les Abelletes', 'Andorra', 1, 'Mountaineering', 'Wind slab'),
  EawsIncident('2025-12-06', 'Zugspitze', 'Austria', 1, 'Mountaineering', 'Wind slab'),
  EawsIncident('2025-12-22', 'Col d\'Olen - Alagna Valsesia', 'Italy', 1, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2025-12-26', 'La Plagne', 'France', 1, 'Backcountry', 'Wind slab'),
  EawsIncident('2025-12-26', 'Valloire', 'France', 1, 'Backcountry', 'New snow'),
  EawsIncident('2025-12-26', 'Montgenevre', 'France', 1, 'Backcountry', 'New snow'),
  EawsIncident('2025-12-27', 'Punta Rocca, Marmolada', 'Italy', 1, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2025-12-29', 'Cima Riesernock - Vedrette di Ries', 'Italy', 1, 'Hiking', 'Wind slab'),
  EawsIncident('2025-12-29', 'Pico Tablato', 'Spain', 3, 'Backcountry', 'Wind slab'),
  EawsIncident('2025-12-31', 'Punta Suelza', 'Spain', 1, 'Hiking', 'Wind slab'),
  EawsIncident('2026-01-02', 'Bivacco Bonelli - lago Apsoi', 'Italy', 1, 'Backcountry', 'Wind slab'),
  EawsIncident('2026-01-02', 'Prealpi Venete - Piccole Dolomiti', 'Italy', 1, 'Mountaineering', 'Wind slab'),
  EawsIncident('2026-01-02', 'Monte Arbancie - Rocca Puyan', 'Italy', 1, 'Backcountry', 'Wind slab'),
  EawsIncident('2026-01-10', 'Point De La Pierre - Gressan', 'Italy', 1, 'Backcountry', 'Wind slab'),
  EawsIncident('2026-01-10', 'Beaufort', 'France', 1, 'Off-piste', 'Wind slab'),
  EawsIncident('2026-01-10', 'Val d\'Isere', 'France', 2, 'Off-piste', 'Wind slab'),
  EawsIncident('2026-01-11', 'Courchevel', 'France', 1, 'Off-piste', 'Wind slab'),
  EawsIncident('2026-01-11', 'La Plagne', 'France', 1, 'Off-piste', 'Wind slab'),
  EawsIncident('2026-01-11', 'Les Allues', 'France', 1, 'Off-piste', 'Wind slab'),
  EawsIncident('2026-01-13', 'Kreuzkogel / Goldbergbahn', 'Austria', 1, 'Off-piste', 'Wind slab'),
  EawsIncident('2026-01-13', 'Trou de Bougogne', 'Switzerland', 1, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-01-14', 'Mont Carre', 'Switzerland', 1, 'Off-piste', 'Persistent weak layer'),
  EawsIncident('2026-01-15', 'Pointe de Chemo', 'Switzerland', 2, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-01-15', 'Velilltal-Burkelkopf', 'Austria', 1, 'Off-piste', 'Persistent weak layer'),
  EawsIncident('2026-01-16', 'Piz Badus', 'Switzerland', 1, 'Backcountry', 'Wind slab'),
  EawsIncident('2026-01-17', 'Throneck', 'Austria', 4, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-01-17', 'Schmugglerscharte / Schusterkopf', 'Austria', 1, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-01-17', 'Schonfeldspitz', 'Austria', 3, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-01-18', 'Barranco de Puymestre', 'Spain', 1, 'Off-piste', 'Wind slab'),
  EawsIncident('2026-01-18', 'Barranc dera Laveja', 'Spain', 1, 'Backcountry', 'Wind slab'),
  EawsIncident('2026-01-18', 'Vallorcine', 'France', 1, 'Off-piste', 'Wind slab'),
  EawsIncident('2026-01-19', 'Val d\'Isere', 'France', 1, 'Off-piste', 'Persistent weak layer'),
  EawsIncident('2026-01-21', 'Schilthorn', 'Switzerland', 1, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-01-23', 'Saint-Colomban-des-Villards', 'France', 1, 'Backcountry', 'Wind slab'),
  EawsIncident('2026-01-26', 'Tignes', 'France', 1, 'Off-piste', 'New snow'),
  EawsIncident('2026-01-26', 'Puy-Saint-Andre', 'France', 1, 'Backcountry', 'New snow'),
  EawsIncident('2026-01-29', 'Circo de Ciboles', 'Spain', 2, 'Backcountry', 'Wind slab'),
  EawsIncident('2026-01-29', 'Cervieres', 'France', 1, 'Hiking', 'New snow'),
  EawsIncident('2026-01-30', 'La Roussette', 'Switzerland', 1, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-01-31', 'Cervieres', 'France', 1, 'Backcountry', 'New snow'),
  EawsIncident('2026-01-31', 'Piz Minor', 'Switzerland', 1, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-02-01', 'Forcella Tragonia - Sauris', 'Italy', 1, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-02-04', 'Monte Prasnig - Tarvisio', 'Italy', 1, 'Off-piste', 'New snow'),
  EawsIncident('2026-02-05', 'Vordere Schontaufspitze', 'Italy', 2, 'Off-piste', 'Persistent weak layer'),
  EawsIncident('2026-02-06', 'Monte Cardine - Val Loga', 'Italy', 1, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-02-06', 'Hockuchriz', 'Switzerland', 1, 'Off-piste', 'New snow'),
  EawsIncident('2026-02-06', 'Tupa', 'Slovakia', 2, 'Mountaineering', 'Persistent weak layer'),
  EawsIncident('2026-02-07', 'Colbricon', 'Italy', 1, 'Off-piste', 'Persistent weak layer'),
  EawsIncident('2026-02-07', 'Sas Da Les Undesc', 'Italy', 1, 'Off-piste', 'Persistent weak layer'),
  EawsIncident('2026-02-07', 'Val-Cenis', 'France', 1, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-02-07', 'Saint-Veran', 'France', 2, 'Backcountry', 'New snow'),
  EawsIncident('2026-02-07', 'Pizzo Meriggio - Albosaggia', 'Italy', 2, 'Backcountry', 'Persistent weak layer'),
  EawsIncident('2026-02-08', 'Plattinger - Kratzberger See', 'Italy', 1, 'Off-piste', 'Persistent weak layer'),
];

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

class TributeScreen extends StatefulWidget {
  const TributeScreen({super.key});

  @override
  State<TributeScreen> createState() => _TributeScreenState();
}

class _TributeScreenState extends State<TributeScreen> {
  String? _selectedActivity;

  static const _activityCategories = [
    'Backcountry',
    'Off-piste',
    'Mountaineering',
    'Hiking',
  ];

  List<EawsIncident> get _filteredIncidents {
    if (_selectedActivity == null) return _currentSeasonIncidents;
    return _currentSeasonIncidents
        .where((i) => i.activity == _selectedActivity)
        .toList();
  }

  int get _filteredDeathCount =>
      _filteredIncidents.fold<int>(0, (sum, i) => sum + i.deaths);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grandTotal = _seasons.fold<int>(0, (sum, s) => sum + s.total);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Tribute to Risk Takers',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  '\u{1F56F}',
                  style: TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  '$grandTotal lives lost',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'to avalanches in Europe (2017\u20132026)',
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Each number is a person who went to the mountains and never came back. Professionals, beginners, locals, tourists. The mountain does not care who you are.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white38,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // ── Season-by-season bar chart ──────────────────────
          _SectionTitle(title: 'FATALITIES BY SEASON', icon: Icons.bar_chart),
          ..._seasons.map((s) => _SeasonBar(season: s)),

          const SizedBox(height: 8),

          // ── Country breakdown for current season ─────────────
          _SectionTitle(
            title: 'THIS SEASON (2025/26) — ${_seasons.first.total} DEATHS',
            icon: Icons.public,
          ),
          _CountryBreakdown(data: _seasons.first.byCountry),

          const SizedBox(height: 8),

          // ── Current season incidents ─────────────────────────
          _SectionTitle(
            title: _selectedActivity == null
                ? 'INCIDENTS THIS SEASON'
                : '${_selectedActivity!.toUpperCase()} — $_filteredDeathCount DEATHS',
            icon: Icons.warning_amber_rounded,
          ),

          // Activity filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  count: _currentSeasonIncidents.fold<int>(0, (s, i) => s + i.deaths),
                  isSelected: _selectedActivity == null,
                  onTap: () => setState(() => _selectedActivity = null),
                ),
                ..._activityCategories.map((cat) {
                  final count = _currentSeasonIncidents
                      .where((i) => i.activity == cat)
                      .fold<int>(0, (s, i) => s + i.deaths);
                  return _FilterChip(
                    label: cat,
                    count: count,
                    isSelected: _selectedActivity == cat,
                    onTap: () => setState(() =>
                        _selectedActivity = _selectedActivity == cat ? null : cat),
                  );
                }),
              ],
            ),
          ),

          ..._filteredIncidents.map((i) => _IncidentTile(incident: i)),

          if (_filteredIncidents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                'No incidents in this category this season.',
                style: TextStyle(color: Colors.white24, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 8),

          // ── Isola 2000 ──────────────────────────────────────
          _SectionTitle(title: 'ISOLA 2000 — KNOWN FATALITIES', icon: Icons.terrain),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEF5350).withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.2)),
            ),
            child: const Text(
              'Death zones: Lombarde / Combe Grosse (Italian border) — extreme wind creates a wind-slab factory. Mene — steep and rocky, avalanches drag you over rocks causing fatal trauma before burial.',
              style: TextStyle(fontSize: 13, color: Color(0xFFEF5350), height: 1.5),
            ),
          ),
          ..._isolaIncidents.map((i) => _IsolaIncidentTile(incident: i)),

          const SizedBox(height: 16),

          // ── Source ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('https://www.avalanches.org/fatalities/');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Source: EAWS — avalanches.org'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white38,
                side: const BorderSide(color: Colors.white12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section title
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white38,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chip
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF7043).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF7043).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? const Color(0xFFFF7043) : Colors.white54,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF7043).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? const Color(0xFFFF7043) : Colors.white38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Season bar (horizontal bar chart row)
// ---------------------------------------------------------------------------

class _SeasonBar extends StatelessWidget {
  final SeasonData season;
  const _SeasonBar({required this.season});

  @override
  Widget build(BuildContext context) {
    const maxValue = 147.0; // 2017/18 peak
    final pct = season.total / maxValue;
    final barColor = season.total > 100
        ? const Color(0xFFEF5350)
        : season.total > 80
            ? const Color(0xFFFF7043)
            : season.total > 60
                ? const Color(0xFFFFB74D)
                : const Color(0xFF81C784);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              season.season,
              style: const TextStyle(fontSize: 12, color: Colors.white54, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 22,
                      decoration: BoxDecoration(
                        color: barColor.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '${season.total}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: barColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Country breakdown chips
// ---------------------------------------------------------------------------

class _CountryBreakdown extends StatelessWidget {
  final Map<String, int> data;
  const _CountryBreakdown({required this.data});

  @override
  Widget build(BuildContext context) {
    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final active = sorted.where((e) => e.value > 0).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: active.map((e) {
          final isHigh = e.value >= 10;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isHigh
                  ? const Color(0xFFEF5350).withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHigh
                    ? const Color(0xFFEF5350).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _countryFlag(e.key),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  e.key,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(width: 6),
                Text(
                  '${e.value}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isHigh ? const Color(0xFFEF5350) : Colors.white,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static String _countryFlag(String country) {
    const flags = {
      'France': '\u{1F1EB}\u{1F1F7}',
      'Italy': '\u{1F1EE}\u{1F1F9}',
      'Austria': '\u{1F1E6}\u{1F1F9}',
      'Switzerland': '\u{1F1E8}\u{1F1ED}',
      'Spain': '\u{1F1EA}\u{1F1F8}',
      'Norway': '\u{1F1F3}\u{1F1F4}',
      'Germany': '\u{1F1E9}\u{1F1EA}',
      'Slovakia': '\u{1F1F8}\u{1F1F0}',
      'Slovenia': '\u{1F1F8}\u{1F1EE}',
      'Andorra': '\u{1F1E6}\u{1F1E9}',
      'Poland': '\u{1F1F5}\u{1F1F1}',
      'Romania': '\u{1F1F7}\u{1F1F4}',
      'Finland': '\u{1F1EB}\u{1F1EE}',
      'Sweden': '\u{1F1F8}\u{1F1EA}',
      'Iceland': '\u{1F1EE}\u{1F1F8}',
      'Czechia': '\u{1F1E8}\u{1F1FF}',
      'UK': '\u{1F1EC}\u{1F1E7}',
    };
    return flags[country] ?? '\u{1F3D4}';
  }
}

// ---------------------------------------------------------------------------
// Current season incident tile
// ---------------------------------------------------------------------------

class _IncidentTile extends StatelessWidget {
  final EawsIncident incident;
  const _IncidentTile({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: incident.deaths >= 3
              ? const Color(0xFFEF5350).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Death count
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: incident.deaths >= 3
                  ? const Color(0xFFEF5350).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.06),
            ),
            child: Center(
              child: Text(
                '${incident.deaths}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: incident.deaths >= 3
                      ? const Color(0xFFEF5350)
                      : Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incident.location,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${incident.date}  \u2022  ${incident.country}  \u2022  ${incident.activity}',
                  style: const TextStyle(fontSize: 11, color: Colors.white38),
                ),
                const SizedBox(height: 2),
                Text(
                  incident.problem,
                  style: const TextStyle(fontSize: 11, color: Colors.white24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Isola incident tile
// ---------------------------------------------------------------------------

class _IsolaIncidentTile extends StatelessWidget {
  final FatalIncident incident;
  const _IsolaIncidentTile({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEF5350).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFFEF5350)),
              const SizedBox(width: 6),
              Text(
                '${incident.date} — ${incident.location}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF5350),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            incident.description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
