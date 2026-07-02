# silverbullet-api-gateway

HTTP server that appends POST data to [SilverBullet](https://silverbullet.md/) pages via the `/.fs/<page>` API.

## Routes

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/` | Accepts form data, appends to configured SilverBullet page |
| `GET` / other | `/` | Returns `405 Method Not Allowed` (healthcheck) |

## Usage

```
# from the notes host itself
curl -X POST -d "data=HelloWorld!" http://localhost:8080/

# from anywhere on the tailnet
curl -X POST -d "data=HelloWorld!" http://notes.fluffy-rooster.ts.net:8080/

# use -F for multipart form data
curl -X POST -F "data=HelloWorld!" http://localhost:8080/
```

`data` field is read via `r.FormValue()` — supports both `application/x-www-form-urlencoded` (`-d`) and `multipart/form-data` (`-F`).

## Page Routing (v0.2.0)

Optional `page` form param controls target page:

| `page` value | Resolves to |
|-------------|-------------|
| `inbox` | `SB_INBOX_PAGE` env var (default: `inbox`) |
| `journal` | `SB_JOURNAL_PATTERN` with `[DATE]` → `YYYY-MM-DD` (default: `Journal/[DATE].md`) |
| anything else | literal page name |
| *omitted* | `SB_PAGE` env var (default page) |

```
# send to journal (creates Journal/2026-06-28.md)
curl -X POST -d "data=log entry&page=journal" http://localhost:8080/

# send to inbox
curl -X POST -d "data=todo item&page=inbox" http://localhost:8080/

# send to specific page
curl -X POST -d "data=recipe notes&page=recipes/bread" http://localhost:8080/
```

## Sending Markdown

Space/newline chars in markdown need encoding. **Recommend `--data-urlencode`** — curl handles encoding:

```
curl -X POST --data-urlencode "data=# My Title" http://localhost:8080/
```

For multiline markdown, pipe from a file:

```
curl -X POST --data-urlencode "data@some-file.md" http://localhost:8080/
```

For inline newlines with shell `$''`:

```
curl -X POST --data-urlencode "data="$'# Title\n\n- item 1\n- item 2'"" http://localhost:8080/
```

The raw text is appended to the SilverBullet page. With `DATA_PATTERN` set, magic variables apply formatting around it.

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SB_URL` | yes | — | SilverBullet instance URL |
| `SB_TOKEN` | **yes** | — | SilverBullet API auth token (Bearer) |
| `SB_PAGE` | yes | — | Default page when no `page` form param |
| `DATA_PATTERN` | no | (none) | Template for formatting appended data |
| `SEPARATOR` | no | `\n` | String between appended entries |
| `SB_JOURNAL_PATTERN` | no | `Journal/[DATE].md` | Template for `page=journal` |
| `SB_INBOX_PAGE` | no | `inbox` | Page name for `page=inbox` |

**Note:** v0.2.0 requires `SB_TOKEN` — API calls use Bearer auth on `/.fs/<page>` endpoints.

## Magic Variables (DATA_PATTERN)

| Variable | Expands to |
|----------|------------|
| `[TEXT]` | The `data` field from POST request |
| `[DATE]` | Current timestamp (`2006-01-02 15:04:05`) |
| `[SEPARATOR]` | The `SEPARATOR` env value |
| `[TAB]` | Tab character (`\t`) |

### DATA_PATTERN examples

- `- [ ] [TEXT] ([DATE])` → checklist item with timestamp
- `**[TEXT]**` → bold text only
- `[TEXT][SEPARATOR]` → text followed by separator

When `DATA_PATTERN` is unset or empty, the raw `data` field is appended as-is.

## Behavior

- `GET /.fs/<page>` to check if page exists
- If 404 → `PUT /.fs/<page>` with `data + separator` (creates page)
- If 200 → `PUT /.fs/<page>` with `current + separator + data` (appends)
