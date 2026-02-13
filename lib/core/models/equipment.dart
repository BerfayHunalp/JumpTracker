// ---------------------------------------------------------------------------
// Equipment (Matos) model
// ---------------------------------------------------------------------------

enum EquipmentType {
  materiel('Equipment', 0xFF4FC3F7),
  protection('Protection', 0xFFFF7043),
  securite('Safety', 0xFF81C784);

  final String label;
  final int colorValue;

  const EquipmentType(this.label, this.colorValue);
}

enum EquipmentZone {
  tete('Head'),
  torse('Torso'),
  dos('Back'),
  mains('Hands'),
  jambes('Legs'),
  pieds('Feet');

  final String label;

  const EquipmentZone(this.label);
}

class Equipment {
  final String id;
  final String name;
  final String icon;
  final EquipmentType type;
  final EquipmentZone zone;
  final String why;
  final String detail;

  const Equipment({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.zone,
    this.why = '',
    this.detail = '',
  });
}

// ---------------------------------------------------------------------------
// Full equipment catalog — backcountry skiing focused
// ---------------------------------------------------------------------------

class EquipmentCatalog {
  static const all = [
    // ---- HEAD ----
    Equipment(
      id: 'casque_mips',
      name: 'MIPS Helmet',
      icon: '\u26D1',
      type: EquipmentType.protection,
      zone: EquipmentZone.tete,
      why: 'Rotational energy dissipation during oblique head impacts.',
      detail: 'Internal shell moves independently — prevents concussions.',
    ),
    Equipment(
      id: 'masque',
      name: 'Ski Goggles',
      icon: '\u{1F97D}',
      type: EquipmentType.protection,
      zone: EquipmentZone.tete,
      why: 'UV protection, wind & snow — visibility in all conditions.',
      detail: 'Photochromic or double lens, S1-S3 categories.',
    ),

    // ---- TORSO ----
    Equipment(
      id: 'veste_recco',
      name: 'RECCO Jacket',
      icon: '\u{1F9E5}',
      type: EquipmentType.securite,
      zone: EquipmentZone.torse,
      why: 'Passive reflector for rescue detection under avalanche.',
      detail: 'Always active, zero battery, secondary safety net.',
    ),
    Equipment(
      id: 'thermique_haut',
      name: 'Thermal Top',
      icon: '\u{1F455}',
      type: EquipmentType.materiel,
      zone: EquipmentZone.torse,
      why: 'First layer against skin — evacuates sweat and retains heat.',
      detail: 'Merino wool or technical synthetic. Never cotton.',
    ),
    Equipment(
      id: 'dva',
      name: 'Avalanche Kit (DVA + Shovel + Probe)',
      icon: '\u{1F4E1}',
      type: EquipmentType.securite,
      zone: EquipmentZone.torse,
      why: 'Mandatory off-piste — only way to be found alive under avalanche.',
      detail: 'Complete kit: transceiver + metal shovel + 240cm probe. Worn under vest.',
    ),

    // ---- BACK ----
    Equipment(
      id: 'dorsale',
      name: 'D3O Back Protector',
      icon: '\u{1F6E1}',
      type: EquipmentType.protection,
      zone: EquipmentZone.dos,
      why: 'Falls on ice/rails hit the spine hard.',
      detail: 'Soft D3O vest, hardens on impact, flexible when moving.',
    ),
    Equipment(
      id: 'sac_airbag',
      name: 'Airbag Backpack',
      icon: '\u{1F392}',
      type: EquipmentType.securite,
      zone: EquipmentZone.dos,
      why: 'Airbag keeps you on surface in avalanche.',
      detail: 'Often integrated with back protection. Holds DVA + shovel + probe.',
    ),

    // ---- HANDS ----
    Equipment(
      id: 'gants',
      name: 'Gore-Tex Gloves',
      icon: '\u{1F9E4}',
      type: EquipmentType.protection,
      zone: EquipmentZone.mains,
      why: 'Prevents frostbite, maintains dexterity for grabs.',
      detail: 'Gore-Tex + PrimaLoft/Thinsulate, long wrist to cover sleeve.',
    ),
    Equipment(
      id: 'batons',
      name: 'Ski Poles',
      icon: '\u{1F3BF}',
      type: EquipmentType.materiel,
      zone: EquipmentZone.mains,
      why: 'Essential for balance, turns, and pushing on flat.',
      detail: 'Size: standing with elbow at 90\u00B0 when pole planted. Aluminum or carbon.',
    ),

    // ---- LEGS ----
    Equipment(
      id: 'genouillere',
      name: 'Knee Brace (ZAMST ZK-7)',
      icon: '\u{1F9B5}',
      type: EquipmentType.protection,
      zone: EquipmentZone.jambes,
      why: 'Lateral resin/carbon braces prevent drawer motion and rotation (ACL).',
      detail: 'Mechanically replaces tired ligaments. Must be tight.',
    ),
    Equipment(
      id: 'thermique_bas',
      name: 'Thermal Bottom',
      icon: '\u{1FA73}',
      type: EquipmentType.materiel,
      zone: EquipmentZone.jambes,
      why: 'Protects knee from cold (cold stiffens joints = injury risk).',
      detail: 'Merino or synthetic tights worn under ski pants.',
    ),

    // ---- FEET ----
    Equipment(
      id: 'chaussures',
      name: 'Ski Boots (Flex 130 Cabrio)',
      icon: '\u{1F462}',
      type: EquipmentType.materiel,
      zone: EquipmentZone.pieds,
      why: 'Flex 130 for ~80kg — 3-piece Cabrio design = progressive flex.',
      detail: 'Dalbello Lupo, Lange XT3, or Full Tilt. Rubber sole for walking.',
    ),
    Equipment(
      id: 'semelles',
      name: 'Custom Insoles',
      icon: '\u{1F9B6}',
      type: EquipmentType.materiel,
      zone: EquipmentZone.pieds,
      why: 'Collapsing feet = tibia rotation = knee twisting = meniscus pain.',
      detail: 'Custom molding in-store (30 min). Feet locked in place.',
    ),
    Equipment(
      id: 'chaussettes',
      name: 'Thermal Socks',
      icon: '\u{1F9E6}',
      type: EquipmentType.materiel,
      zone: EquipmentZone.pieds,
      why: 'Keep feet dry and warm all day.',
      detail: 'Knee-height, thin. Merino ideal. ONE pair only (2 = cuts circulation).',
    ),
    Equipment(
      id: 'skis_camox',
      name: 'Freeride Skis',
      icon: '\u{1F3BF}',
      type: EquipmentType.materiel,
      zone: EquipmentZone.pieds,
      why: '97mm waist — soft and gentle, smooths terrain, protects knee.',
      detail: 'Black Crows Camox, Faction Prodigy, or similar. 175-181cm.',
    ),
    Equipment(
      id: 'fixations',
      name: 'Bindings (Pivot Style)',
      icon: '\u2699',
      type: EquipmentType.materiel,
      zone: EquipmentZone.pieds,
      why: 'Turntable heel piece — indestructible, protects ACL in torsion.',
      detail: 'LOOK Pivot 15/18. DIN: 8 or 9 to start.',
    ),
  ];

  /// Preconfigured backcountry skiing profile — items typically owned.
  static const backcountryDefaults = {
    'casque_mips': true,
    'masque': true,
    'veste_recco': true,
    'thermique_haut': true,
    'dva': true,
    'dorsale': true,
    'sac_airbag': true,
    'gants': true,
    'batons': true,
    'genouillere': true,
    'thermique_bas': true,
    'chaussures': true,
    'semelles': true,
    'chaussettes': true,
    'skis_camox': true,
    'fixations': true,
  };

  static List<Equipment> byZone(EquipmentZone zone) =>
      all.where((e) => e.zone == zone).toList();

  static List<Equipment> byType(EquipmentType type) =>
      all.where((e) => e.type == type).toList();
}
