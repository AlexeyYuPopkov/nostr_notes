import 'dart:math';

enum PassStyle { dicewareStyle, randomStyle }

final class GenPassUsecase {
  const GenPassUsecase();

  String execute(PassStyle style) {
    switch (style) {
      case PassStyle.dicewareStyle:
        return _generateDicewarePassword();
      case PassStyle.randomStyle:
        return _generateRandomPassword();
    }
  }

  // 200 words → ~7.6 bits/word. A larger pool than the original 20 words
  // (~4.3 bits/word) meaningfully raises diceware-style entropy without
  // changing the generation shape (still 2 words + separators + number).
  static const _words = [
    'Raccoon',
    'Tiger',
    'Salmon',
    'Wolf',
    'Beaver',
    'Owl',
    'Fox',
    'Bear',
    'Zebra',
    'Panda',
    'Hawk',
    'Kitten',
    'Badger',
    'Eagle',
    'Otter',
    'Lynx',
    'Moose',
    'Rabbit',
    'Squirrel',
    'Boar',
    'Falcon',
    'Heron',
    'Sparrow',
    'Robin',
    'Raven',
    'Crow',
    'Swan',
    'Duck',
    'Goose',
    'Turkey',
    'Peacock',
    'Parrot',
    'Dolphin',
    'Whale',
    'Shark',
    'Turtle',
    'Frog',
    'Toad',

    'Lizard',
    'Gecko',
    'Iguana',
    'Cobra',
    'Viper',
    'Python',
    'Puma',
    'Cougar',
    'Jaguar',
    'Leopard',
    'Cheetah',
    'Lion',
    'Hyena',
    'Jackal',
    'Coyote',
    'Elk',
    'Deer',
    'Antelope',
    'Bison',
    'Buffalo',
    'Camel',
    'Llama',
    'Alpaca',
    'Donkey',
    'Mule',
    'Horse',
    'Pony',
    'Goat',
    'Sheep',
    'Lamb',
    'Piglet',
    'Hedgehog',
    'Mole',
    'Shrew',
    'Bat',
    'Ferret',

    'Weasel',
    'Skunk',
    'Chipmunk',
    'Marmot',
    'Gopher',
    'Vole',
    'Mountain',
    'River',
    'Forest',
    'Meadow',
    'Valley',
    'Canyon',
    'Desert',
    'Island',
    'Ocean',
    'Lagoon',
    'Glacier',
    'Volcano',
    'Boulder',
    'Pebble',
    'Cliff',
    'Cave',
    'Waterfall',
    'Prairie',
    'Jungle',
    'Tundra',
    'Comet',
    'Planet',
    'Nebula',
    'Galaxy',
    'Meteor',
    'Asteroid',
    'Aurora',
    'Thunder',

    'Lightning',
    'Rainbow',
    'Sunrise',
    'Sunset',
    'Twilight',
    'Horizon',
    'Blizzard',
    'Cyclone',
    'Tempest',
    'Whirlwind',
    'Ember',
    'Cinder',
    'Frost',
    'Icicle',
    'Crystal',
    'Diamond',
    'Emerald',
    'Sapphire',
    'Ruby',
    'Topaz',
    'Amber',
    'Quartz',
    'Granite',
    'Marble',
    'Copper',
    'Bronze',
    'Silver',
    'Golden',
    'Platinum',
    'Titanium',
    'Cobalt',
    'Nickel',

    'Maple',
    'Willow',
    'Cedar',
    'Birch',
    'Oak',
    'Pine',
    'Bamboo',
    'Fern',
    'Clover',
    'Thistle',
    'Lavender',
    'Jasmine',
    'Daisy',
    'Tulip',
    'Orchid',
    'Lotus',
    'Cactus',
    'Mango',
    'Papaya',
    'Coconut',
    'Cherry',
    'Peach',
    'Apricot',
    'Walnut',
    'Almond',
    'Pecan',
    'Hazel',
    'Ginger',
    'Cinnamon',
    'Saffron',
    'Crimson',
    'Scarlet',
    'Indigo',
    'Violet',
    'Azure',

    'Turquoise',
    'Magenta',
    'Charcoal',
    'Ivory',
    'Ebony',
    'Coral',
    'Lilac',
    'Mauve',
    'Olive',
    'Khaki',
    'Beige',
    'Maroon',
    'Navy',
    'Teal',
    'Cyan',
    'Lantern',
    'Compass',
    'Anchor',
    'Harbor',
    'Voyage',
    'Journey',
    'Odyssey',
    'Beacon',
    'Summit',
    'Pinnacle',
  ];

  static const _specials = '@#\$%&*!?';

  String _generateDicewarePassword({
    int wordCount = 2,
    bool addNumber = true,
    bool addSpecial = true,
  }) {
    final rand = Random.secure();

    final parts = List.generate(
      wordCount,
      (_) => _words[rand.nextInt(_words.length)],
    );

    var password = parts.join(
      addSpecial ? _specials[rand.nextInt(_specials.length)] : '',
    );

    if (addNumber) {
      final number = rand.nextInt(90) + 10; // 10..99
      password +=
          (addSpecial ? _specials[rand.nextInt(_specials.length)] : '') +
          number.toString();
    }

    return password;
  }

  String _generateRandomPassword({
    int length = 16,
    bool useUpper = true,
    bool useLower = true,
    bool useDigits = true,
    bool useSpecial = true,
  }) {
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    const special = '!@#\$%^&*()-_=+[]{}<>?';

    String chars = '';
    if (useUpper) chars += upper;
    if (useLower) chars += lower;
    if (useDigits) chars += digits;
    if (useSpecial) chars += special;

    if (chars.isEmpty) {
      throw ArgumentError('Нужно выбрать хотя бы один тип символов');
    }

    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
