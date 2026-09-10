# montea-web

Die öffentliche Seite zu Montea - eine Datei, `index.html`, ohne Baulauf und
ohne Abhängigkeiten. Im Browser öffnen genügt, um sie anzusehen.

**Dieses Repo ist öffentlich. Der Quelltext von Montea liegt woanders und
bleibt privat.** Hier steht nichts, was nicht jeder sehen darf.

## Warum ein eigenes Repo

GitHub Pages gibt es im Free-Plan nur für **öffentliche** Repos. Das
Produktrepo ist privat und soll es bleiben - also liegt die Seite hier. (Mit
GitHub Pro ginge Pages auch aus einem privaten Repo; für eine Seite ohne
Geheimnisse lohnt das nicht.)

## Vor dem ersten Veröffentlichen

Eintragen ist genau eines: die **Mailadresse**. Sie steht dreimal im Abschnitt
*Demo beantragen* als `demo@montea.example` - einmal im Knopf, zweimal in der
Zeile darunter. Der Hinweisblock oben in `index.html` sagt es auch.

```bash
# Entwicklungsrechner, bash, root of sourcetree
grep -n "demo@montea.example" index.html
```

## Veröffentlichen

> **Wo:** Entwicklungsrechner · `bash` · root of sourcetree

```bash
# Entwicklungsrechner, bash, root of sourcetree
git init -b main
git add .
git commit -m "Seite"
git remote add origin https://github.com/BENUTZER/montea-web.git
git push -u origin main
```

Danach im Repo unter *Settings → Pages*: **Source** auf „Deploy from a branch",
Branch `main`, Ordner `/ (root)`. Nach ein bis zwei Minuten steht sie unter
`https://BENUTZER.github.io/montea-web/`.

Ansehen ohne all das - aus WSL heraus im Windows-Browser:

```bash
# Entwicklungsrechner, bash, root of sourcetree
explorer.exe index.html
```

## Ausgabe abgleichen

Die Versionsnummer steht an drei Stellen in `index.html` - im Versionsband
(`Aktuellste Version`), im Betreff der Update-Mailadresse daneben und in der
Fusszeile. `version-sync.sh` holt die aktuelle Ausgabe aus **Montea-2** und
traegt alle drei ein.

```bash
# Entwicklungsrechner, bash, root of sourcetree
./version-sync.sh            # holen und eintragen
./version-sync.sh --pruefen  # nur melden, ob die Seite hinterherhinkt
./version-sync.sh 2.2.0      # von Hand setzen
```

Woher die Nummer kommt, in dieser Reihenfolge:

1. **GitHub-API**, wenn `GH_TOKEN` gesetzt ist: der veroeffentlichte Release,
   ersatzweise der neueste Tag.
2. **Lokaler Klon** unter `~/repos/Montea-2` (anders via `MONTEA_REPO`): der
   neueste Tag. Das greift ohne Token, aber nur auf dem Entwicklungsrechner.

### Automatisch

`.github/workflows/ausgabe-abgleichen.yml` laeuft taeglich, laesst sich unter
*Actions* von Hand starten und committet die neue Nummer selbst. Dafuer ist
einmalig einzurichten:

1. Auf github.com unter *Settings → Developer settings → Personal access tokens
   → Fine-grained tokens* ein Token anlegen, **Repository access** nur auf
   `Montea-2`, **Permissions → Contents: Read-only**.
2. Hier im Repo unter *Settings → Secrets and variables → Actions* als
   `MONTEA_TOKEN` hinterlegen.

Der eingebaute `GITHUB_TOKEN` reicht nicht - er kommt an das private Repo
nicht heran.

Soll die Seite **sofort beim Release** nachziehen statt erst in der Nacht, ruft
Montea-2 den Ablauf hier an. In dessen Release-Workflow (Token mit Schreibrecht
auf `montea-web`, Contents: Read and write):

```yaml
- name: Seite nachziehen lassen
  run: |
    curl -fsS -X POST \
      -H "Authorization: Bearer ${{ secrets.WEB_TOKEN }}" \
      -H "Accept: application/vnd.github+json" \
      https://api.github.com/repos/buehlpa/montea-web/dispatches \
      -d '{"event_type":"montea-release"}'
```

## Warum es hier nichts herunterzuladen gibt

Das ist eine Entscheidung, keine Lücke.

Solange Montea kein Herausgeberzertifikat trägt, meldet Windows bei jedem
Start „Unbekannter Herausgeber", und in Betrieben mit Endpoint-Schutz wandert
der unsignierte Datendienst gern in Quarantäne. Wer die Datei **anonym** lädt,
steht damit allein da und klickt weg - und niemand erfährt davon. Wer sie aus
der Hand bekommt, mit zwei vorbereitenden Sätzen, kommt durch.

Dazu kommt: Die Demo braucht ohnehin eine Lizenzdatei, die von Hand
ausgestellt wird. Die Mail muss also so oder so geschrieben werden. Der
Antrag ist damit kein zusätzlicher Aufwand, sondern derselbe - und der Kontakt
bleibt.

**Was sich ändert, sobald das Zertifikat da ist:** Dann kann ein Download
dazukommen. Die Seite ist darauf vorbereitet - es wäre ein Abschnitt mit zwei
Karten, der Rest bleibt.

## Was die Seite bewusst nicht tut

**Kein Formular, kein Worker, keine Datenbank.** Ein `mailto` mit
vorbereitetem Betreff und Rumpf tut dasselbe und braucht nichts, was laufen
muss.

**Keine Zählung, kein Analysewerkzeug.** Es gibt nichts einzublenden und
niemanden zu verfolgen - das erspart auch die Datenschutzerklärung, die sonst
dazugehörte.

**Keine Schriftdateien im Repo.** IBM Plex kommt von Google Fonts; fällt das
aus, greift die Systemschrift, und die Seite sieht nur etwas anders aus.
