import 'package:flutter/widgets.dart';

/// Brand icon glyphs generated from `tool/accs_icons_src/*.svg` (simple-icons,
/// curated subset, plus a few manually sourced marks) via fantasticon into
/// `assets/fonts/accs_icons.ttf`.
///
/// The source SVGs live under `tool/`, not `assets/`, and are never listed
/// in `pubspec.yaml`'s `assets:` — only the compiled `.ttf` ships with the
/// app.
///
/// Regenerate with:
/// ```
/// npx fantasticon tool/accs_icons_src --output <out> --name accs_icons \
///   --font-types ttf woff woff2 --asset-types json html css --normalize \
///   --font-height 1000
/// ```
/// then copy `accs_icons.ttf` here and, if the set of icons (not just their
/// artwork) changed, regenerate this file from the accompanying
/// `accs_icons.json` codepoint map (key -> Dart identifier: camelCase,
/// leading digits spelled out — e.g. `1password` -> `onePassword`).
final class AccsIcons {
  const AccsIcons._();

  static const String _fontFamily = 'AccsIcons';

  static const IconData airbnb = IconData(0xf167, fontFamily: _fontFamily);
  static const IconData aliexpress = IconData(0xf166, fontFamily: _fontFamily);
  static const IconData amazon = IconData(0xf165, fontFamily: _fontFamily);
  static const IconData americanexpress = IconData(0xf164, fontFamily: _fontFamily);
  static const IconData apple = IconData(0xf163, fontFamily: _fontFamily);
  static const IconData applemusic = IconData(0xf162, fontFamily: _fontFamily);
  static const IconData asana = IconData(0xf161, fontFamily: _fontFamily);
  static const IconData atlassian = IconData(0xf160, fontFamily: _fontFamily);
  static const IconData bankofamerica = IconData(0xf15f, fontFamily: _fontFamily);
  static const IconData binance = IconData(0xf15e, fontFamily: _fontFamily);
  static const IconData bitbucket = IconData(0xf15d, fontFamily: _fontFamily);
  static const IconData bitwarden = IconData(0xf15c, fontFamily: _fontFamily);
  static const IconData bluesky = IconData(0xf15b, fontFamily: _fontFamily);
  static const IconData bookingdotcom = IconData(0xf15a, fontFamily: _fontFamily);
  static const IconData box = IconData(0xf159, fontFamily: _fontFamily);
  static const IconData cashapp = IconData(0xf158, fontFamily: _fontFamily);
  static const IconData chase = IconData(0xf157, fontFamily: _fontFamily);
  static const IconData coinbase = IconData(0xf156, fontFamily: _fontFamily);
  static const IconData confluence = IconData(0xf155, fontFamily: _fontFamily);
  static const IconData discord = IconData(0xf154, fontFamily: _fontFamily);
  static const IconData docker = IconData(0xf153, fontFamily: _fontFamily);
  static const IconData doordash = IconData(0xf152, fontFamily: _fontFamily);
  static const IconData dropbox = IconData(0xf151, fontFamily: _fontFamily);
  static const IconData duolingo = IconData(0xf150, fontFamily: _fontFamily);
  static const IconData ebay = IconData(0xf14f, fontFamily: _fontFamily);
  static const IconData epicgames = IconData(0xf14e, fontFamily: _fontFamily);
  static const IconData etsy = IconData(0xf14d, fontFamily: _fontFamily);
  static const IconData expedia = IconData(0xf14c, fontFamily: _fontFamily);
  static const IconData expressvpn = IconData(0xf14b, fontFamily: _fontFamily);
  static const IconData facebook = IconData(0xf14a, fontFamily: _fontFamily);
  static const IconData figma = IconData(0xf149, fontFamily: _fontFamily);
  static const IconData github = IconData(0xf148, fontFamily: _fontFamily);
  static const IconData gitlab = IconData(0xf147, fontFamily: _fontFamily);
  static const IconData gmail = IconData(0xf146, fontFamily: _fontFamily);
  static const IconData google = IconData(0xf145, fontFamily: _fontFamily);
  static const IconData googledrive = IconData(0xf144, fontFamily: _fontFamily);
  static const IconData googlemaps = IconData(0xf143, fontFamily: _fontFamily);
  static const IconData hubspot = IconData(0xf142, fontFamily: _fontFamily);
  static const IconData icloud = IconData(0xf141, fontFamily: _fontFamily);
  static const IconData instagram = IconData(0xf140, fontFamily: _fontFamily);
  static const IconData jira = IconData(0xf13f, fontFamily: _fontFamily);
  static const IconData kakaotalk = IconData(0xf13e, fontFamily: _fontFamily);
  static const IconData khanacademy = IconData(0xf13d, fontFamily: _fontFamily);
  static const IconData klarna = IconData(0xf13c, fontFamily: _fontFamily);
  static const IconData lastpass = IconData(0xf13b, fontFamily: _fontFamily);
  static const IconData line = IconData(0xf13a, fontFamily: _fontFamily);
  static const IconData linkedIn = IconData(0xf139, fontFamily: _fontFamily);
  static const IconData lyft = IconData(0xf138, fontFamily: _fontFamily);
  static const IconData mailchimp = IconData(0xf137, fontFamily: _fontFamily);
  static const IconData mastercard = IconData(0xf136, fontFamily: _fontFamily);
  static const IconData mastodon = IconData(0xf135, fontFamily: _fontFamily);
  static const IconData messenger = IconData(0xf134, fontFamily: _fontFamily);
  static const IconData microsoft = IconData(0xf133, fontFamily: _fontFamily);
  static const IconData monzo = IconData(0xf132, fontFamily: _fontFamily);
  static const IconData n26 = IconData(0xf131, fontFamily: _fontFamily);
  static const IconData netflix = IconData(0xf130, fontFamily: _fontFamily);
  static const IconData nordvpn = IconData(0xf12f, fontFamily: _fontFamily);
  static const IconData notion = IconData(0xf12e, fontFamily: _fontFamily);
  static const IconData npm = IconData(0xf12d, fontFamily: _fontFamily);
  static const IconData okx = IconData(0xf12c, fontFamily: _fontFamily);
  static const IconData onePassword = IconData(0xf168, fontFamily: _fontFamily);
  static const IconData paypal = IconData(0xf12b, fontFamily: _fontFamily);
  static const IconData pinterest = IconData(0xf12a, fontFamily: _fontFamily);
  static const IconData playstation = IconData(0xf129, fontFamily: _fontFamily);
  static const IconData proton = IconData(0xf128, fontFamily: _fontFamily);
  static const IconData protonmail = IconData(0xf127, fontFamily: _fontFamily);
  static const IconData reddit = IconData(0xf126, fontFamily: _fontFamily);
  static const IconData revolut = IconData(0xf125, fontFamily: _fontFamily);
  static const IconData robinhood = IconData(0xf124, fontFamily: _fontFamily);
  static const IconData shopify = IconData(0xf123, fontFamily: _fontFamily);
  static const IconData signal = IconData(0xf122, fontFamily: _fontFamily);
  static const IconData slack = IconData(0xf121, fontFamily: _fontFamily);
  static const IconData snapchat = IconData(0xf120, fontFamily: _fontFamily);
  static const IconData spotify = IconData(0xf11f, fontFamily: _fontFamily);
  static const IconData squarespace = IconData(0xf11e, fontFamily: _fontFamily);
  static const IconData steam = IconData(0xf11d, fontFamily: _fontFamily);
  static const IconData stripe = IconData(0xf11c, fontFamily: _fontFamily);
  static const IconData target = IconData(0xf11b, fontFamily: _fontFamily);
  static const IconData telegram = IconData(0xf11a, fontFamily: _fontFamily);
  static const IconData threads = IconData(0xf119, fontFamily: _fontFamily);
  static const IconData tiktok = IconData(0xf118, fontFamily: _fontFamily);
  static const IconData trello = IconData(0xf117, fontFamily: _fontFamily);
  static const IconData trezor = IconData(0xf116, fontFamily: _fontFamily);
  static const IconData tripadvisor = IconData(0xf115, fontFamily: _fontFamily);
  static const IconData twitch = IconData(0xf114, fontFamily: _fontFamily);
  static const IconData uber = IconData(0xf113, fontFamily: _fontFamily);
  static const IconData ubereats = IconData(0xf112, fontFamily: _fontFamily);
  static const IconData udemy = IconData(0xf111, fontFamily: _fontFamily);
  static const IconData venmo = IconData(0xf110, fontFamily: _fontFamily);
  static const IconData viber = IconData(0xf10f, fontFamily: _fontFamily);
  static const IconData visa = IconData(0xf10e, fontFamily: _fontFamily);
  static const IconData vk = IconData(0xf10d, fontFamily: _fontFamily);
  static const IconData wechat = IconData(0xf10c, fontFamily: _fontFamily);
  static const IconData wellsfargo = IconData(0xf10b, fontFamily: _fontFamily);
  static const IconData whatsapp = IconData(0xf10a, fontFamily: _fontFamily);
  static const IconData wise = IconData(0xf109, fontFamily: _fontFamily);
  static const IconData wix = IconData(0xf108, fontFamily: _fontFamily);
  static const IconData wordpress = IconData(0xf107, fontFamily: _fontFamily);
  static const IconData x = IconData(0xf106, fontFamily: _fontFamily);
  static const IconData youtube = IconData(0xf105, fontFamily: _fontFamily);
  static const IconData youtubemusic = IconData(0xf104, fontFamily: _fontFamily);
  static const IconData zelle = IconData(0xf103, fontFamily: _fontFamily);
  static const IconData zendesk = IconData(0xf102, fontFamily: _fontFamily);
  static const IconData zoom = IconData(0xf101, fontFamily: _fontFamily);

  /// Every glyph keyed by its simple-icons slug (as stored e.g. in
  /// `LoginItem.image`), for runtime lookup and for iterating all icons.
  static const Map<String, IconData> bySlug = {
    'airbnb': airbnb,
    'aliexpress': aliexpress,
    'amazon': amazon,
    'americanexpress': americanexpress,
    'apple': apple,
    'applemusic': applemusic,
    'asana': asana,
    'atlassian': atlassian,
    'bankofamerica': bankofamerica,
    'binance': binance,
    'bitbucket': bitbucket,
    'bitwarden': bitwarden,
    'bluesky': bluesky,
    'bookingdotcom': bookingdotcom,
    'box': box,
    'cashapp': cashapp,
    'chase': chase,
    'coinbase': coinbase,
    'confluence': confluence,
    'discord': discord,
    'docker': docker,
    'doordash': doordash,
    'dropbox': dropbox,
    'duolingo': duolingo,
    'ebay': ebay,
    'epicgames': epicgames,
    'etsy': etsy,
    'expedia': expedia,
    'expressvpn': expressvpn,
    'facebook': facebook,
    'figma': figma,
    'github': github,
    'gitlab': gitlab,
    'gmail': gmail,
    'google': google,
    'googledrive': googledrive,
    'googlemaps': googlemaps,
    'hubspot': hubspot,
    'icloud': icloud,
    'instagram': instagram,
    'jira': jira,
    'kakaotalk': kakaotalk,
    'khanacademy': khanacademy,
    'klarna': klarna,
    'lastpass': lastpass,
    'line': line,
    'linkedIn': linkedIn,
    'lyft': lyft,
    'mailchimp': mailchimp,
    'mastercard': mastercard,
    'mastodon': mastodon,
    'messenger': messenger,
    'microsoft': microsoft,
    'monzo': monzo,
    'n26': n26,
    'netflix': netflix,
    'nordvpn': nordvpn,
    'notion': notion,
    'npm': npm,
    'okx': okx,
    '1password': onePassword,
    'paypal': paypal,
    'pinterest': pinterest,
    'playstation': playstation,
    'proton': proton,
    'protonmail': protonmail,
    'reddit': reddit,
    'revolut': revolut,
    'robinhood': robinhood,
    'shopify': shopify,
    'signal': signal,
    'slack': slack,
    'snapchat': snapchat,
    'spotify': spotify,
    'squarespace': squarespace,
    'steam': steam,
    'stripe': stripe,
    'target': target,
    'telegram': telegram,
    'threads': threads,
    'tiktok': tiktok,
    'trello': trello,
    'trezor': trezor,
    'tripadvisor': tripadvisor,
    'twitch': twitch,
    'uber': uber,
    'ubereats': ubereats,
    'udemy': udemy,
    'venmo': venmo,
    'viber': viber,
    'visa': visa,
    'vk': vk,
    'wechat': wechat,
    'wellsfargo': wellsfargo,
    'whatsapp': whatsapp,
    'wise': wise,
    'wix': wix,
    'wordpress': wordpress,
    'x': x,
    'youtube': youtube,
    'youtubemusic': youtubemusic,
    'zelle': zelle,
    'zendesk': zendesk,
    'zoom': zoom,
  };
}
