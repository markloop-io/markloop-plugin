#!/usr/bin/env bash
# Build the OpenAI plugin package ("With MCP": skills + remote MCP server).
# Zips plugin/ into dist/markloop-openai-<version>.zip without the Claude-only
# files (.claude-plugin/, .mcp.json) and .DS_Store, after checking the package.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN="$ROOT/plugin"
DIST="$ROOT/dist"

fail() { echo "error: $*" >&2; exit 1; }

command -v zip >/dev/null || fail "zip is not installed"
command -v python3 >/dev/null || fail "python3 is not installed"

# Required files.
for f in plugin.json mcp.json README.md LICENSE; do
  [[ -f "$PLUGIN/$f" ]] || fail "missing plugin/$f"
done
compgen -G "$PLUGIN/skills/*/SKILL.md" >/dev/null || fail "no plugin/skills/*/SKILL.md"

# Forbidden in an OpenAI public submission.
[[ -e "$PLUGIN/.app.json" ]] && fail "plugin/.app.json is not allowed"
[[ -e "$PLUGIN/hooks" ]] && fail "plugin/hooks/ is not allowed"

# Manifest checks: JSON parses, listing limits, referenced paths exist,
# no apps/hooks, skills have name + description, no secrets in mcp.json.
VERSION="$(python3 - "$PLUGIN" <<'PY'
import json, pathlib, re, sys

root = pathlib.Path(sys.argv[1])
errors = []

def load(name):
    try:
        return json.loads((root / name).read_text(encoding="utf-8"))
    except Exception as e:  # noqa: BLE001
        errors.append(f"{name}: invalid JSON ({e})")
        return {}

manifest = load("plugin.json")
mcp = load("mcp.json")

version = manifest.get("version", "")
if not re.fullmatch(r"\d+\.\d+\.\d+", version):
    errors.append(f"plugin.json: version must be semver, got {version!r}")
if not re.fullmatch(r"[a-z0-9]+(-[a-z0-9]+)*", manifest.get("name", "")):
    errors.append("plugin.json: name must be lowercase letters, numbers and single hyphens")

openai = manifest.get("extensions", {}).get("com.openai", {})
for key in ("apps", "hooks"):
    if key in openai:
        errors.append(f"plugin.json: extensions.com.openai.{key} is not allowed")
ui = openai.get("interface", {})
limits = {"displayName": 30, "shortDescription": 30, "longDescription": 4000, "developerName": 80}
for key, limit in limits.items():
    value = ui.get(key)
    if not value:
        errors.append(f"interface.{key} is required")
    elif len(value) > limit:
        errors.append(f"interface.{key} is {len(value)} chars (max {limit})")
if not ui.get("category"):
    errors.append("interface.category is required")
prompts = ui.get("defaultPrompt", [])
if len(prompts) > 3 or len(set(prompts)) != len(prompts):
    errors.append("interface.defaultPrompt: at most 3 unique prompts")
for p in prompts:
    if len(p) > 128:
        errors.append(f"interface.defaultPrompt over 128 chars: {p!r}")
caps = ui.get("capabilities", [])
if len(caps) > 20 or any(len(c) > 120 for c in caps):
    errors.append("interface.capabilities: max 20 items, 120 chars each")
for key in ("websiteURL", "supportURL", "privacyPolicyURL", "termsOfServiceURL"):
    if not str(ui.get(key, "")).startswith("https://"):
        errors.append(f"interface.{key} must be an https URL")
color = ui.get("brandColor")
if color and not re.fullmatch(r"#[0-9a-fA-F]{6}", color):
    errors.append("interface.brandColor must be #RRGGBB")
for key in ("composerIcon", "composerIconDark", "logo", "logoDark"):
    path = ui.get(key)
    if path is None:
        continue
    if not path.startswith("./"):
        errors.append(f"interface.{key} must start with ./")
    elif not (root / path).is_file():
        errors.append(f"interface.{key}: {path} does not exist")
for path in ui.get("screenshots", []):
    if not (root / path).is_file():
        errors.append(f"interface.screenshots: {path} does not exist")

for name, server in mcp.get("mcpServers", {}).items():
    if server.get("headers"):
        errors.append(f"mcp.json: server {name} must not set headers")
    auth = server.get("extensions", {}).get("com.openai", {}).get("auth", {})
    client = auth.get("client", {})
    if client.get("mode") in ("dcr", "cimd") and set(client) - {"mode"}:
        errors.append(f"mcp.json: server {name} client mode {client['mode']} must not set client credentials")
    if "clientSecret" in json.dumps(server):
        errors.append(f"mcp.json: server {name} must not contain clientSecret")
if not mcp.get("mcpServers"):
    errors.append("mcp.json: no mcpServers")

for skill in sorted(root.glob("skills/*/SKILL.md")):
    text = skill.read_text(encoding="utf-8")
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    front = m.group(1) if m else ""
    if not re.search(r"^name:\s*\S", front, re.M) or not re.search(r"^description:\s*\S", front, re.M):
        errors.append(f"{skill.relative_to(root)}: frontmatter needs name and description")

if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
print(version)
PY
)" || fail "plugin checks failed (see above)"

OUT="$DIST/markloop-openai-$VERSION.zip"
mkdir -p "$DIST"
rm -f "$OUT"

(
  cd "$PLUGIN"
  zip -r -X -q "$OUT" . \
    -x ".claude-plugin/*" ".claude-plugin" ".mcp.json" "*.DS_Store" ".DS_Store"
)

# Check what went in.
LISTING="$(unzip -Z1 "$OUT")"
if grep -Eq '(^|/)\.claude-plugin(/|$)|(^|/)\.mcp\.json$|\.DS_Store$|(^|/)\.app\.json$|(^|/)hooks/' <<<"$LISTING"; then
  fail "the ZIP contains files it must not contain"
fi
for f in plugin.json mcp.json; do
  grep -qx "$f" <<<"$LISTING" || fail "$f is not at the ZIP root"
done

echo "Built $OUT"
unzip -l "$OUT"
