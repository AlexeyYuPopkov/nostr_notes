# Store / catalogue artwork

Everything in `web/` is copied verbatim into `build/web/` and published to the
root of `AlexeyYuPopkov.github.io`, so a file dropped here is reachable at:

    https://alexeyyupopkov.github.io/preview/<file>

Those URLs are what external catalogues point at — currently the `thumb` and
`gallery` fields of the nostrapps.com listing. They are never requested by the
app itself, so their size costs nothing at runtime; only the deploy carries
them.

The deploy uses `keep_files: true`, so removing a file here does **not** remove
it from the published site — delete it in the Pages repo as well.

## What to put here

- `icon-256.png` — square app icon for the catalogue `thumb`.
- `shot-*.png` — screenshots for the `gallery`.

nostrapps.com lays the gallery out in a four-column grid at `width: 100%` with
no cropping, so aspect ratio is preserved: a portrait phone screenshot renders
narrow and very tall next to a landscape one. Mixing a couple of phone shots
with tablet or desktop ones keeps the row heights sane.
