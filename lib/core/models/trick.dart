enum TrickCategory { spin, flip, grab, freestyle, other }

class Trick {
  final String name;
  final TrickCategory category;

  const Trick(this.name, this.category);
}

class TrickCatalog {
  static const spins = [
    Trick('180', TrickCategory.spin),
    Trick('360', TrickCategory.spin),
    Trick('540', TrickCategory.spin),
    Trick('720', TrickCategory.spin),
    Trick('900', TrickCategory.spin),
    Trick('1080', TrickCategory.spin),
    Trick('Switch 180', TrickCategory.spin),
    Trick('Switch 360', TrickCategory.spin),
    Trick('Switch 540', TrickCategory.spin),
  ];

  static const flips = [
    Trick('Backflip', TrickCategory.flip),
    Trick('Frontflip', TrickCategory.flip),
    Trick('Misty Flip', TrickCategory.flip),
    Trick('Cork 540', TrickCategory.flip),
    Trick('Cork 720', TrickCategory.flip),
    Trick('Rodeo 540', TrickCategory.flip),
    Trick('Rodeo 720', TrickCategory.flip),
    Trick('D-Spin', TrickCategory.flip),
  ];

  static const grabs = [
    Trick('Mute', TrickCategory.grab),
    Trick('Indy', TrickCategory.grab),
    Trick('Stalefish', TrickCategory.grab),
    Trick('Melon', TrickCategory.grab),
    Trick('Tail Grab', TrickCategory.grab),
    Trick('Nose Grab', TrickCategory.grab),
    Trick('Japan', TrickCategory.grab),
    Trick('Truck Driver', TrickCategory.grab),
    Trick('Blunt', TrickCategory.grab),
  ];

  static const freestyle = [
    Trick('Spread Eagle', TrickCategory.freestyle),
    Trick('Daffy', TrickCategory.freestyle),
    Trick('Iron Cross', TrickCategory.freestyle),
    Trick('Helicopter', TrickCategory.freestyle),
    Trick('Safety', TrickCategory.freestyle),
    Trick('Method', TrickCategory.freestyle),
  ];

  static const other = [
    Trick('Straight Air', TrickCategory.other),
    Trick('Butter', TrickCategory.other),
    Trick('Shifty', TrickCategory.other),
  ];

  static const allByCategory = {
    'Spins': spins,
    'Flips': flips,
    'Grabs': grabs,
    'Freestyle': freestyle,
    'Other': other,
  };
}

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
