#!/bin/bash
# Выкладка портфолио: копия в albumchik-site/vika, минификация CSS/JS/HTML, коммит и пуш обоих репо.
set -e
SRC="$HOME/projects/vika-portfolio"
DST="$HOME/projects/albumchik-site/vika"
ESB="$HOME/projects/mary-vision/node_modules/.bin/esbuild"
MSG="${1:-vika: обновление}"
cd "$SRC"
git add -A && git commit -qm "$MSG" || true
git push -q || true
rsync -a --delete --exclude kp/ --exclude jkp2.json --exclude .git --exclude deploy.sh "$SRC/" "$DST/"
for f in "$DST"/assets/*.css; do "$ESB" "$f" --minify --log-level=error --outfile="$f.tmp" --allow-overwrite && mv "$f.tmp" "$f"; done
for f in "$DST"/assets/*.js; do "$ESB" "$f" --minify --log-level=error --outfile="$f.tmp" --allow-overwrite && mv "$f.tmp" "$f"; done
python3 - "$DST" <<'PY'
import sys,glob,re
for f in glob.glob(sys.argv[1]+'/*.html'):
    s=open(f).read()
    s=re.sub(r'<!--(?!\[).*?-->','',s,flags=re.S)
    s=re.sub(r'\n[ \t]+','\n',s); s=re.sub(r'\n{2,}','\n',s)
    open(f,'w').write(s)
PY
cd "$HOME/projects/albumchik-site"
git add -A && (git commit -qm "$MSG" || true) && git push -q
git log --oneline -1
