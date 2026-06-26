---
title: "Nostr as a backend out of the box: where it fits and where it doesn't"
published: false
description: "A hands-on review of Nostr as an out-of-the-box backend across real cases: notes, chats, feeds, communities, and organizations."
tags: nostr, decentralization, backend, webdev
# cover_image: upload the cover (1000x420) in the dev.to editor, or paste a URL here
# canonical_url: not needed — dev.to is the original home of this English version
---

> **TL;DR.** Nostr is a ready-to-use, decentralized backend: it gives you an event model, signatures, encryption, and sync through relays. For notes, private chats, and simple feeds it covers almost everything — with no server of your own. But once you need a smart feed, roles, hierarchies, or complex moderation, the protocol hits one basic limit: only the owner of a key can change an event. After that, the extra workarounds quickly cost more than they save. Below I look at real cases: where Nostr works well, and where it is better to think about a separate backend.

### Introduction
For a long time I wanted to build a simple cross-platform notes app.
The most important use case for me was storing sensitive information, such as passwords, crypto wallet addresses, and so on. Another key requirement was reliable sync between devices, in particular iOS, Android, and macOS.

But there was one big problem: for a long time I could not find a secure way to sync notes that did not depend on one specific provider.

Some time ago I happened to join a project built around the [Nostr](https://github.com/nostr-protocol/nips) protocol — that is how I first learned about it. For that project Nostr was, to be honest, not a great fit (you will see why later in the article). But for my notes task it turned out to be an almost perfect solution.

The goal of this article is to review the good and the bad cases of using the [Nostr](https://github.com/nostr-protocol/nips) protocol that I ran into myself. I also want to describe the tasks it is worth using for, and the tasks where you should look for other solutions.

### What the Nostr protocol is and how it works

The [Nostr](https://github.com/nostr-protocol/nips) protocol presents itself as a backend for building decentralized social networks that are hard to censor. But, as you will see below, it can be used for a wider range of tasks. That said, building a social network in the usual sense (with complex feed ranking and filtering, and good performance on complex post models) is, in my personal opinion, hard.

The [Nostr](https://github.com/nostr-protocol/nips) protocol is a set of rules (NIPs) for talking to a decentralized network of servers (relays). You talk to them over WebSockets. Each server keeps a database of events. An event is a record with a fixed structure; the client and the relay exchange it as a JSON object with a defined schema. A user can read and publish such events from one or more relays (and to one or more relays). Each event has an id — a hash of the event itself (more precisely, a SHA-256 of a serialized set of fields: `pubkey`, `created_at`, `kind`, `tags`, and `content`), not just of its content. So when you get the same event from different relays, the id is used to remove duplicates. Each event also has a signature. The signature is made from the event id and the sender's private key, and the JSON event has a field with the sender's public key. So to publish an event to one or more relays you need this key pair. (To read events you do not need any keys.)

It is easy to see that a key pair can also be used for asymmetric encryption. The spec describes common ways to encrypt chat messages — for example, the current [Encrypted Payloads (NIP-44)](https://github.com/nostr-protocol/nips/blob/master/44.md), which the [Private Direct Messages (NIP-17)](https://github.com/nostr-protocol/nips/blob/master/17.md) feature is built on. There is also an older [Encrypted Direct Message (NIP-04)](https://github.com/nostr-protocol/nips/blob/master/04.md): it is officially marked as deprecated and is not recommended for public, decentralized use (it uses unauthenticated encryption and leaks metadata).

Still, it is important to understand that NIP-44 is not the only option. The protocol does not force a specific algorithm: clients are free to agree on any compatible way to encrypt content. So for practical tasks — say, if you run your own private relay or solve a specific business task — NIP-04 with plain AES, or any other scheme you like, can be a good fit.


### Data model: events, `kind`, and tags

> If you already know Nostr (events, `kind`, tags, the `REQ` subscription model), feel free to skip this section and go straight to the cases.

Before we get to the cases, it makes sense to look a bit closer at how an event is built — we will keep coming back to it.

Any Nostr event is JSON that looks roughly like this:

```json
{
  "id": "1897f99...",
  "pubkey": "9c2e0a7...",
  "created_at": 1781787656,
  "kind": 1,
  "tags": [
    ["e", "737f50..."],
    ["p", "9c2e0a7..."]
  ],
  "content": "Hello, Nostr!",
  "sig": "41b737f50..."
}
```

The `kind` field is an integer that sets the *rough* meaning of an event, rather than a strict type. For example, `kind:0` is a user profile, `kind:1` is a short text note (a post), `kind:7` is a reaction (a like). It is important that this is an agreement, not a strict schema: the meaning of each `kind` is described in its NIP, and most NIPs have *draft* status — so these are conventions, not a fixed standard. The relay does not validate the structure of the content: the clients that agreed with each other are fully responsible for how a `kind` and the event format are read. You could say a `kind` is something like a "table" in a normal database, but without a strict schema and without server-side validation.

Besides meaning, `kind` also sets how the relay stores the event. The exact behavior depends on the number range (the ranges are defined in [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md)). In simple terms, events fall into:
- **regular** — range `1000–9999` (also `kind:1`, `kind:4`–`44`); they just pile up and overwrite nothing;
- **replaceable** — range `10000–19999` (also `kind:0` for a profile, `kind:3` for a contact list); the relay keeps only the newest version for a given author, and a new event replaces the old one;
- **addressable** (also called parameterized replaceable) — range `30000–39999`; the same as replaceable, but the "coordinates" for replacing also include the value of the `d` tag (see below). This is how updatable things with an identifier work — a long note (`kind:30023`), a community definition (`kind:34550`);
- **ephemeral** — range `20000–29999`; the relay does not have to store them at all (useful for signaling).

For addressable events the "coordinates" are the triple `kind:pubkey:d`, where `d` is the value of a special `["d", "..."]` tag — a stable identifier of the thing. The `a` tag points to such events using the `kind:pubkey:d` format (we will see this below).

The `tags` field is an array of arrays: the first item of each inner array is the tag name, and the rest are its values (`["e", "<event id>"]`, `["p", "<pubkey>"]`, and so on). Tags with single-letter names (`e`, `p`, `a`, `g`, `d`, …) are indexed by the relay, and you can filter queries by them — in a filter this is written as `#e`, `#p`, `#g` (this will be useful in the feed section).

Finally, about how events are requested. To get events, the client opens a subscription with a message like this:

```json
["REQ", "<subscription id>", { <filter> }, { <filter> }, ...]
```

A filter is a JSON object with fields like `authors`, `kinds`, `since`, `until`, `limit`, `#e`, `#g`. The relay returns all events that match at least one filter, and keeps the subscription open — it sends new matching events as they appear, until the client closes it with a `CLOSE` message. We will come back to filters and their limits.

### Notes

While I was building my app, I did not really think about what the word Nostr stands for. Nostr is an acronym: Notes and Other Stuff Transmitted by Relays.

So the idea of a notes app on top of this protocol was obvious. Nostr gives you sync, and it offers recommendations for strong asymmetric encryption — [Encrypted Payloads (Versioned)](https://github.com/nostr-protocol/nips/blob/master/44.md).

So Nostr is a very good fit for this task.

This is how my pet project appeared — **Private Notes (Nostr)**: a cross-platform notes app with end-to-end encryption on the device (NIP-44), signing with secp256k1, and storage on relays the user picks. No server, no accounts — just a key pair. You can try it right now:

- 🍎 **iOS:** [App Store](https://apps.apple.com/bg/app/private-notes-nostr/id6757975921)
- 🌐 **Web:** [alexeyyupopkov.github.io](https://alexeyyupopkov.github.io)
- 🤖 **Android:** [download the APK](https://alexeyyupopkov.github.io/downloads/nostr_notes-release.apk)
- 💻 **Source code:** [github.com/AlexeyYuPopkov/nostr_notes](https://github.com/AlexeyYuPopkov/nostr_notes)

The repository is open — if you find a bug or have an idea, feel free to open an [Issue](https://github.com/AlexeyYuPopkov/nostr_notes/issues), I will be glad to hear from you.

### Chats

Many small mobile apps have a chat feature. For most such projects the chat backend is a third-party service like [Twilio](https://www.twilio.com/), [Quickblox](https://quickblox.com/), or a cloud database such as [Firebase Realtime Database](https://firebase.google.com/docs/database/) or [Cloud Firestore](https://firebase.google.com/docs/firestore/). But this means extra costs for these subscriptions. In the second case you also need to design the database for chat data, and that means extra work and bugs. Nostr, on the other hand, gives you a ready backend that fits chats well. You can either use the many public relays that already work, or run your own on your own backend by downloading a popular implementation from GitHub.

One more thing worth mentioning is media content in chat messages. A Nostr event is always JSON with a fixed schema, and the protocol does not expect you to store binary data (images, files) inside an event. To solve this there is [NIP-96](https://github.com/nostr-protocol/nips/blob/master/96.md) — a standard that describes HTTP File Storage: a spec for file hosts compatible with Nostr. The client uploads a file to a NIP-96 server, gets a URL, and puts it in the event content. Public NIP-96 servers exist, and in general this works.

But in practice, if a project already uses central infrastructure (AWS S3, Firebase Cloud Storage, and so on), it is simpler and safer to store media there and just put a link in the Nostr event. It is a plain approach, but for most products it is a reasonable one.

For one-on-one (one2one) chats Nostr gives you everything out of the box. But for group chats there are limits in practice, and getting around them needs extra logic.

I would point out two such problems:
1) the performance of message encryption
2) group moderation

The first one is this. To use asymmetric encryption ([Encrypted Direct Message](https://github.com/nostr-protocol/nips/blob/master/04.md) or [Encrypted Payloads (Versioned)](https://github.com/nostr-protocol/nips/blob/master/44.md)), you have to encrypt the message separately for each user. As the number of group members grows, this can hurt both performance and the overall reliability of the approach. That said, from my own experience, for groups of 20 people or fewer I did not see real performance problems. I have read that up to 100 people should also be fine. At the same time, for extra reliability I would rather use central solutions outside the Nostr protocol to encrypt message content (even though that is less secure).

The second problem is moderating the group and adding or removing members. The existing solution, [Private Direct Messages](https://github.com/nostr-protocol/nips/blob/master/17.md), is basically a group conversation without a separate, managed group object. The group's metadata (name, and so on) is not stored as one thing; it is computed from the tags of the messages themselves, and the tags of the newest message "win". As a result, you cannot "hard" add or remove members, and in fact any member can redefine the group metadata — just by sending a new message with the tags they want. The root of the problem is in the base of the Nostr protocol: only the creator of an event can change it. So if you create an event — a chat room model — and link messages to it by a reference to the room, then only its creator can moderate that event. That means there is only one moderator. And even this solution is a bit artificial — I have not seen a NIP (a Nostr standard) for it.

There is also a solution to this problem — [NIP-29](https://github.com/nostr-protocol/nips/blob/master/29.md). It means running your own, separate relay for group moderation (though public relay-29 servers exist too, for example `wss://relay.groups.nip29.com`). The relay itself checks whether a moderator is allowed to change the group state. Such a relay is responsible only for the group state, not for the users' messages, which are stored on normal relays. But this is, rather, a central solution (otherwise you lose the single source of truth and risk getting out of sync).

Overall, relay-29 is a good central solution for group chats with roles and moderation, and it really works.

### Feed, posts

In my view, a social network is first of all posts, likes, comments, and reposts.

Let's try to figure out how well the Nostr protocol fits these goals and what the limits are. We already know that relays store event models and can return their JSON over WebSockets.
For clarity, here is an example of a possible post JSON:

```json
    {

        "created_at": 1781787656,
        "id": "1897f99...",
        "kind": 1,
        "pubkey": "9c2e0a7...",
        "content": "Some text...",
        "sig": "41b737f50...",
        "tags": [
			["e", "737f50..."],
			["e", "1897f..."],
			...,
			["a", "30023:f72...:abcd"],
			["a", "30023:er34...:abcd"],
			...,
			["g", "u4pr"],
			["g", "u4pru"]	
		]
    }
```

All tags are optional. Let's go over the ones in the example:
- `e` — a reference to another event by its `id`; used for threads, quotes, and replies
- `a` — a reference to an addressable (replaceable) event in the `kind:pubkey:d` format; in the example above these are references to `kind:30023` events (long posts / articles per [NIP-23](https://github.com/nostr-protocol/nips/blob/master/23.md)) by different authors
- `g` — a [geohash](https://en.wikipedia.org/wiki/Geohash) of the location the post is linked to; the longer the string, the more precise the coordinate (`u4pr` is a rough region, `u4pru` is a bit more precise)

Now, to understand the limits of Nostr, let's look at a few cases:
1) To show, for example, posts (usually `kind:1`) by specific authors (see `authors`) in a feed, you send a request:

```json
["REQ", "feed-sub-1", {
  "authors": ["9c2e0a7...", "pubkey1", "pubkey2", ...],
  "kinds": [1],
  "until": 1718700000,
  "limit": 20
}]
```

So far so good. With `until + limit` it is easy to set up time-based pagination here, and it will work reliably.

2) Now let's make it harder. Say we need to build a feed that shows posts by specific authors OR posts by users with a nearby location:

```json
["REQ", "feed-sub-2", {
  "authors": ["9c2e0a7...", "pubkey1", "pubkey2", ...],
  "kinds": [1],
  "until": 1718700000,
  "limit": 20
},
{
  "kinds": [1],
  "#g": ["u4pr"],
  "until": 1718700000,
  "limit": 20
}]
```

And here a problem shows up right away. Inside one filter object all conditions work as AND — that is, authors + kinds + until must all match for one event. But to get OR between "posts by the authors we want" and "posts with the geohash we want", you have to use two separate filters in an array. The relay then returns the union of both results.
And this is exactly where reliable `until+limit` pagination breaks. Each filter in the array is limited on its own: in a typical implementation the relay applies limit: 20 to each of the two filters separately (the exact behavior when merging results from several filters depends on the relay implementation), and then mixes the results. So imagine the first filter (by authors) collected 20 newer posts, and the second (by geohash) also collected 20, but older ones. The final output — after sorting by time and cutting to a common limit on the client — may take only part of one source and miss part of the other. On the next request the new `until` is computed from the oldest post you received. For one of the filters this `until` will be wrong: it will either cover already shown posts again, or skip part of the events that never reached the client. You get holes in the feed, and they add up with each new load.

A working but more time-consuming way is pagination through a time window (`since + until`) that grows step by step — it widens if too few events fall into it. This approach has its own downsides: an unpredictable number of requests to the relay for one feed page, trouble showing a loading indicator, and the risk of a long "freeze" during quiet periods.

A third problem comes up at the level of the geohash filter itself: matching the `g` tag works by exact string equality, not by prefix. If an event has only `["g", "u4pr"]` (a rough location), and the filter asks for `"#g": ["u4pruyd"]` (a more precise one), the relay will not return that event — even though `u4pruyd` is physically inside `u4pr`. People get around this by publishing several geohash tags of different length (all the prefixes) on one event. But then the client that makes the request has to list all the prefixes of the area it wants — this scales poorly and bloats the filter when you try to cover a wide area.

In the event model above you can see the `a` and `e` tags. With them you can link a post to some other event (for example, to another post, if the post is a comment on it — usually through an `e` tag, or a comment on some changeable event — through an `a` tag). The `e` and `a` tags are described in more detail in [NIP-01](https://github.com/nostr-protocol/nips/blob/master/01.md). A post can also have likes, which are usually done through `kind=7` events, and comments (`e`). To get the number of likes and comments and show them in the feed, you need to open subscriptions to the matching events and then count them. So after you get the post and learn its `id`, you send a request:

```json
["REQ", "post-stats-sub", {
  "kinds": [7, 1],
  "#e": ["1897f99..."]
}]
```

But likes and comments are far from the only things that can reference (or be referenced by) a given post. Through `e`/`a` tags, a post can be pointed to by reposts (`kind=6/16`), zap receipts (`kind=9735`), reactions with custom content besides likes, quotes inside other posts, and so on. For each kind of link you basically need a separate subscription with its own `kinds` filter, or a wider filter with no `kinds` limit, which you then have to filter and parse on the client. Already at this stage you can see that to fully show one post card in a feed you may need not one but a whole set of parallel requests to the relay.
There is also a less obvious danger here. Since `e`/`a` links are not limited by the protocol in any way, nothing stops events from referencing each other in a cycle — post A comments on post B, which itself is marked as a comment on post A (by accident, a client bug, or on purpose, as spam or an attack). A client that naively walks the tree of linked events (for example, to build a full thread) can fall into an endless loop if it does not add protection in advance — tracking the ids it has already visited, or limiting the recursion depth.

So while Nostr is a good fit for simple feeds, more complex ones can run into trouble: very greedy content loading and, as a result, a very large number of requests and poor performance.

As for the features we are used to in top social networks — a smart feed and many flexible filters — it seems you cannot build them with Nostr alone, without custom add-ons and without losing decentralization.

Then again, maybe it is better without a smart feed: it is not great that you often cannot find a post you liked a second time.

### Community
One of the features built on Nostr that I had to work with is [NIP-72](https://github.com/nostr-protocol/nips/blob/master/72.md).
In short, [NIP-72](https://github.com/nostr-protocol/nips/blob/master/72.md) is a NIP that describes moderated topic communities on top of normal Nostr events. A community is defined by an addressable event (`kind:34550`), which lists its moderators. Any user can publish a post that links to this community — that is, propose a publication in the community. But for a post to actually count as part of the community and show up in its feed, one of the moderators must publish a separate approval event (`kind:4550`). This event contains the original post in full and is signed by the moderator's key. When building the community feed, clients rely on these approval events, not on the posts with the tag. So selection and moderation here are fully on the side of public, verifiable signatures.

In principle, this works. But when a manager comes and says that any moderator should be able to moderate the community without the creator's approval, a problem appears. [NIP-72](https://github.com/nostr-protocol/nips/blob/master/72.md) does not assume that someone from the moderator list can edit the community definition itself. The moderator list in `kind:34550` is just `p` tags listed inside an event signed by its owner. Only the holder of the private key that originally signed it can change this event (and therefore the moderator list) — that is, the community creator, not any of the listed moderators. This is a direct result of a base Nostr limit: only the holder of the key that is authoritative for an event's state can edit or redefine that state, and the protocol does not split this authority into roles at all. Trying to solve this with Nostr alone, without going beyond the protocol, leads nowhere good in the end. In practice the problem was solved with a central add-on — an extra service that adds extra signatures to events on top of the protocol model. But even with this solution I was very unhappy both with the *communities* feature itself and with the final implementation.

### One more similar use case — organizations

I had to deal with this case too. Here is a short description of the task. There are organizations and sub-organizations, and posts and other similar events are published on their behalf. Only members can publish on behalf of an organization or sub-organization. Members have roles, and depending on the role they can invite other members.

Building this with Nostr alone is a doubtful idea. The protocol has no built-in model for roles, for an "organization → sub-organization" hierarchy, or for invitations; all it has is signing with one key as the only way to authorize. Here it is worth mentioning that Nostr did have a "native" way to delegate signing — [NIP-26 (Delegated Event Signing)](https://github.com/nostr-protocol/nips/blob/master/26.md), but it never caught on and is now marked as deprecated. So even the protocol's own delegation mechanism was, in the end, seen as a failure, and in practice the task is solved centrally — for example, with [keycast](https://github.com/erskingardner/keycast), a service for delegating signing in Nostr, made specially for team work with keys. But even keycast does not fully solve the task, in particular the problem of roles. To give teams control over who can sign what, its authors had to build their own system of policies and permissions around keys — something the protocol does not have. This says a lot: even a tool made specially for delegating signing ends up coming down to writing a full backend from scratch. So managing roles and an organization hierarchy will also need central solutions — and not only for delegating signing, but also separately for managing roles. The amount of such work is comparable to writing a separate backend for this task, and using Nostr as the backend, or even as part of it, looks unjustified here.

### Conclusions

If you go through all these cases — from notes and one2one chats to groups, feeds, and organizations — a fairly clear pattern appears.

Nostr really is a ready backend out of the box, and in two forms at once. It can be a fully decentralized solution based on a network of public relays. Or it can be a central one — if you run your own private relay and use the protocol just as a handy, ready format for data, sync, and authentication on top of your own infrastructure. The second option, by the way, is not as much of a compromise as it may seem: even if you give up decentralization, you still get a ready event model, signatures, encryption, and many ready client libraries. That is, you save time not only on infrastructure, but also on designing the communication protocol itself.

And for a number of tasks this solution really fits well — notes, chats (especially one2one), simple post feeds without claims to a complex feed. Here Nostr closes the classic problems (sync, encryption, identity) with almost no need to write your own backend at all.

But along the way I also collected a few lessons for myself.

**Do not try to build a full social network on the level of Facebook, or any top social network, on Nostr.** As soon as a smart feed, flexible filtering, role models with hierarchy, and other features long standard for top social networks come into play, the protocol starts to fall apart. Not because the NIP authors missed something, but because the model itself (a relay as a dumb store of signed events, with no server that has the full and sole right to complex business logic) is not made for this.

**Do not try to get around the protocol's limits.** The temptation to "stretch" Nostr to the business logic you need with custom add-ons — be it a synthetic moderator model, extra signatures on top of events, or third-party delegation services — is strong, and almost always technically possible. But, as the NIP-72 and organizations cases show, at some point these add-ons start to weigh more than the protocol they were meant to make simpler. And, more importantly, getting around the limits is not free. Besides losing decentralization and compatibility with the rest of the Nostr ecosystem (other clients, relays, NIPs), such add-ons are always one more surface for bugs — bugs in code that no one but you has tested at scale.

**Before you start building, weigh both paths honestly: use Nostr with add-ons, or think about a separate backend for the specific task.** Your own backend for roles, hierarchy, and moderation is written without looking back at someone else's protocol limits like "one key owner". It is often faster than building workarounds around Nostr — especially if the task fits the "signed events + relay" model poorly from the start.

The bottom line: Nostr is a great tool when the task lands in its "native" niche — and surprisingly awkward when you try to stretch it onto something it was not meant for. As with any tool, the main thing is to understand in advance which of these two groups your task falls into, instead of finding out after a month of work.

### The app from this article

[Private Notes (Nostr)](https://github.com/AlexeyYuPopkov/nostr_notes) is open source — you can look through the code to see the approach in practice.

---

*A Russian version of this article is available on Habr: [habr.com/ru/articles/1050348](https://habr.com/ru/articles/1050348/)*
