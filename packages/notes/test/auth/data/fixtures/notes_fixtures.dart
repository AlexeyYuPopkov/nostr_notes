import 'package:nostr/model/user_keys.dart';

final class NotesFixtures {
  static const pin = '270';
  static const keys = UserKeys(
    privateKey:
        'd511ca0405176c93f5412c13b2f915b753ad5625c0db29fdf42a9cd2e66fa1ce',
    publicKey:
        '8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f',
  );

  static const eventJson1 = r'''
[
    "EVENT",
    "f5996f40-6622-11f0-b6aa-77622cb064581",
    {
        "content": "AnnU/0Et8TZDkMJKWjzxQRva1kH3gbtwEoVR/5r66SkYdQrajRgGXs4yA9dfD1v/9gpsgHU3VRKuhbjqqtO+6asuw+I8sOXqIPKTtQ5h9HSK8/RpOb059d4N06lAs/QXnEPDel+4YOuw8b6MoJrqovTHi53uiJEPAFFXhmzBVomt/ZLsA41/LOJRInsIU3RtMkfw0pG8JAuNwyo6jDiGgyyKCvd7iyi0vSJSNMKLPAAzW93rIZtFegHBUoxKBOf7YFJTgmVDEjiZtvTrtfQwvn4HoT5vT94YFhnyX1Usok/yUSdK7cxF0nIOIikZGAfo3cicFLfOm1AHkD7YQ5GzONpCwM3U/mekGWHrcbgAN9/L8kxANIk0Mnu4i25V57fWQbbImpjRYUMFv3pVwkQzBRjh8oYMAr6YkbiAtl8CZWFlwHB/WTYKw+gvSuR+b52I6LTCujELEPUFoaKFixyu6L16wgyJrzcDSAbe1YQFwfpzaHsHkTX1qlZnCN58FJrCS6sMjsbDV/MSh8E6pJDhDn/4/yF0LHcFiv/EGrs6KJf9U3h9vHpNtQHMg9M72TVO0tIW8cImly5vrQ0LSFlR/Muab3BUjcTHmyCXGuj/RxmHxdeict5ajUeXZlMrKMgaEsX6zscg2eVpX4iJl9aVia58BNsXOf9v4ZSe1yVSyVuDEU5owFxHX72ozI7YRTaI1dobfKdLIihTL9sSuQ/SDE+dvy5rxrGT4gvU3zhD2mgnHMkQfRmQdgvKwih/neAft1U8dg5eSLnNh3FF1l+LSFzRnYLKaB5aojhgCV846auoewn9xdDsxdfwuUU15BwQCbK6tEJmT6Q5ofZKEJgZ6tYrLMMgREsrcOdKVvxEUkR9GNXP2iViKXGPRck+QkL/jjVTe33/EdCEXQ1pOpm8h1PjYGXTsWJzaTTphae0eybUA2I=",
        "created_at": 1780644645,
        "id": "a826d76e943cab49f4d10cbc7c609e8b2f34c1f215ac4db7d4a55af96aa57dbd",
        "kind": 30023,
        "pubkey": "8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f",
        "sig": "1c7fdaaa6a3d9bbb4c4b9437e1079c0077ef329805bf519145b7f6fbc463d4c877b7b9b7efc1637dc21b8e3322da029f17b015272b15729a1607ebc24ed30253",
        "tags": [
            ["client", "996e10ba"],
            ["t", "996e10ba"],
            ["d", "06e492d0-22c9-11f1-b2b7-af1d94bcfeaf"],
            ["p", "8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f"],
            ["summary", "AgA75nMioUyWltO2Y3Cjr5sz1r3pLvDTIf/wGrejOtBg26v6q+EJUBQ1cfBHJk1OR3SpQjOv1ny5LsZw7tSByKqn4Qbyv+mRCUb/RkTtEXHSEE8H76Q/jJAzbrXyCANFnuQoZX3i6Y3sSrxwEX6GIQQZdVlnW8DRS+NZBiz7mT1epwu8Vw1187gAmQDWTBvNPXflNFF81MwnYkqK2TcGhl1zHA=="],
            ["updated_at", "1773838222"],
            ["labels", "At1vZM5263zzJ3ho1nC4bP4g7Y2DPdSG764Aqb8s9lMRbThGN08b81cR2Hnel3IH5/HD4AY8+5GZivECh9B2viV2sLcbcCKdcUmYLNDXDbfXIrQrnk1BYQES4thfcUGUhCLc"]
        ]
    }
]
''';

  static const event1Content = r'''
# 🔐 My Passwords

> ⚠️ **Warning:** Never store real passwords in plain text. 

## Work Accounts

### Email
```
j8$kL2#mNpQ9@xR
```

### Cloud Storage
```
Tr0p!cal_Sunr1se#42
```

### VPN
```
Gz&7vWn*Yf3bKm!q
```

### Banking App
```
$ecur3_V4ult_88&Zx
```

---

## Password Strength Guide

| Strength | Length | Example |
|----------|--------|---------|
| 🔴 Weak | < 8 | `pass123` |
| 🟡 Medium | 8–12 | `Spr!ng2026` |
| 🟢 Strong | 13–20 | `j8$kL2#mNpQ9@xR` |
| 🔵 Fort Knox | 20+ | `5h&Tm*Lp!kR3@wQ9$zXv` |''';

  static const event1Summary = r'''🔐 My Passwords

> ⚠️ Warning: Never store real passwords in plain text. 

 Work Accounts''';

  static const event1Labels = r'["security"]';

  static const eventJson2 = r'''
[
    "EVENT",
    "f5996f40-6622-11f0-b6aa-77622cb064581",
    {
        "content": "AuoYbYaME453YpHOAoYX6IjLrZoedMF5fqRqQHB/rOGBS0t2t+cxZxhDAZHMcc2JE52fjxlnK6eAeLgSnxAiMPVLDZNGhRZG0eDi4G7bJ1OagRfG7kexnTHQ8vNaPmrYnUjvYqqU5T7krpzbUUgO+AxE2pRA2P+O4lyuwqu806hNlhdcAGRNEHjlO8OxqnUJHvRzWj2ICp37yCDwNclJTeJjyuFOcngINOdIjwAZvz/HyW80zKKw2Wd9ERM1CyXkbB2kYDfKknGmLfQhIDre7v2uAlvaNPtPq3XXefesctpSrSqmvobyw1jHbSx3LiThqXkXTDn4p0ao49SO7aXU2E6AQnSiMkcYSOiQoKKJbV8rFVvxmUZbQQeHgTGdp83AWJBqwfhU17KE7Jz/KIkTgO5bSM9cfEEs3DSJsvVT+PRJgcbohSrfwn333z+epjfdSagETVRvkJbinI3H98V3dWZT4CaT7L63dtKowb6EjkVtmLgFXhES/wrt7UOlbUbdPjUWPEGDdTTIghnSZhFqQD4vU4MPMi2nz17WEPF1bIhCJVBCnAHeiGjvdmfaHkbuqPJiaEzPKSehY8BCd7SZhrBjDop/bdNPoOS7lQhgb26+xWThDZkvLYE5oacDfKtXyrlRx6GW9lfYes5vJtfq5612llTtATYyz3SMUoxFPgvyDoRWe+8GkmzG4arVbwqPFGW9+3UfJYRX9ZP9I9rXHQ9p5I5rNnxhUJNewcUnVT5SNGRuznKUTjZk06dJXF/G1dID0mUgyUhhGjsAjo+VXCQXwBCarDjBee4V1FeiWC1ObHWeNT9GUGRJUSvivQ4uSdEjYg5DfsIuBDpUsZWjPdWagkn0on1YmtPsmkRMS5JErGrOswGkffCCjoBUM/4EUdEHHZwSNp+5cdBqM5ggwbKri2Z6RMmPHLW5uN4DQJjuHReEQvinEL25hgP4Z2/pjtV5i1zW2ozfnfzgqjyUoDTcfS1i1ZNLwbbJWzKYtKzzxSq+7c5PKcsrqp0OzMHaW1K/eRQn6PsiNAfCQhjfh9ld3YodeXnlt42peNEgZHy8xMFkpLXQgugPPwSnLIoJpjqf/AwrpizGg68/Xql7TFrgACIV4Dkrhxnkxf/oCtloeyr/RtwfI+CASEvN3N9xN/TOTQ7SdwvOAgxkM5gO1FrJANX3Nd5qFphZwsg4O9174d/j9OADeGOgs/lsN/yPpiFsf3kqeyc6tuZNeAjA4YMpwmhZqqnHygjcc8rSg7ozqQ5VG7SsUp1Lazrb9Idd5uw3",
        "created_at": 1773838550,
        "id": "abd1e0dd92bdd51e7b08f56822b72177ea8e4b303f3817865f44beccdc193ea4",
        "kind": 30023,
        "pubkey": "8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f",
        "sig": "9ce2838add32633e84aee2c2153b19e5ecb22454b017097c904dd601e7bdf681edc62fc785700d7bf73422494d4bb40b0d57acc5ea10b11c039b9672bf0ba88e",
        "tags": [
            ["client", "996e10ba"],
            ["t", "996e10ba"],
            ["d", "ca980f90-22c9-11f1-b2b7-af1d94bcfeaf"],
            ["p", "8c78952169177d4fba467bee54029da5877ef4ffdaf10192baa74044a914df8f"],
            ["summary", "AuMYFFgcKKNRWMCCdy7Yawy6vEnHAf4bdJ3xXH3eigXLVwQxtHm2Jjt7Umucj5fRaU5a8zbrY9ZnGJyZtZcuriQkjC6B0288vYzqeKQ1fOLjof00JEUmozWAYQXRpde8j9Oz30QOXNBuv46HA0PzcYD4O0l7Q15Z5AvqnYxLFFNrxli0Wyk+2O41bSddhSZqlwtBMY1N3YfxRXotOPI11ia0+usrWbGixZrx43wLWjuLS2Wk+6duv2LqCTjtQEgm0IIT"]
        ]
    }
]''';

  static const event2Content = r'''# 📚 Atomic Habits — James Clear

**Rating:** ⭐⭐⭐⭐⭐

A practical guide to building good habits and breaking bad ones.

## Key Takeaways

1. **1% better every day** — small changes compound into remarkable results
2. **Focus on systems, not goals** — you don't rise to the level of your goals, you fall to the level of your systems
3. **The Four Laws of Behavior Change:**
   - Make it *obvious*
   - Make it *attractive*
   - Make it *easy*
   - Make it *satisfying*

## Favorite Quotes

> "Every action you take is a vote for the type of person you wish to become."

> "You do not rise to the level of your goals. You fall to the level of your systems."

## My Action Items

- [x] Set up a morning routine tracker
- [x] Remove phone from the bedroom
- [ ] Read 20 pages daily for 30 days
- [ ] Start a weekly review habit''';

  static const event2Summary = r'''📚 Atomic Habits — James Clear

Rating: ⭐⭐⭐⭐⭐

A practical guide to building good habits and b''';
}
