# Kifayat — website

The public site for the **Kifayat** Android app. Four pages, no build step, no
dependencies: plain HTML and one stylesheet, served by GitHub Pages.

It exists because Google Play requires two live, public URLs before the app can
be published:

| Page | Why Play requires it |
|---|---|
| [`/privacy/`](privacy/index.html) | Mandatory privacy policy URL for every app, and non-negotiable for anything handling financial data |
| [`/delete-account/`](delete-account/index.html) | Any app that creates accounts must offer a **web** deletion route, for users who have already uninstalled. The in-app path alone does not satisfy this |

`/` is a small landing page. It is not strictly required, but a deletion page
hanging off a site with nothing else on it looks disposable, and Play asks that
the deletion link be "relevant" and clearly tied to the app.

`/confirmed/` is where the Supabase signup confirmation email lands. Also not
Play-required — it exists because the default redirect went somewhere that did
not exist.

> **This repo must be public.** GitHub Free cannot publish Pages from a private
> repository. Nothing sensitive belongs here — it is only the website.

---

## Setup

### 1. Configure

The pages ship with `__PUBLISHER__` and `__CONTACT_EMAIL__` as literal
placeholders, so a half-configured site is obviously broken rather than quietly
wrong. Fill them in first:

```bash
./configure.sh "Your Developer Name" "your-contact@example.com"
```

- **Publisher name** must match the **Developer name** on your Play listing
  exactly. Play requires the deletion page to reference the app or developer as
  it appears on the store.
- **Contact email** goes on a public page permanently. Use an address you are
  happy for scrapers to find, not your personal one.

### 2. Push

```bash
git init
git add -A
git commit -m "Kifayat website: privacy policy and account deletion"
git branch -M main
git remote add origin https://github.com/<account>/kifayat.git
git push -u origin main
```

### 3. Turn on Pages

In the repo on GitHub: **Settings → Pages → Build and deployment**

- **Source:** Deploy from a branch
- **Branch:** `main`, folder `/ (root)`
- **Save**

The first deploy takes a minute or two. Your URLs are then:

```
https://<account>.github.io/kifayat/
https://<account>.github.io/kifayat/privacy
https://<account>.github.io/kifayat/delete-account
```

### 4. Verify before you paste them into Play Console

Play reviewers check that these load. Confirm all three yourself, on a phone as
well as a desktop:

- [ ] All three URLs return 200 and render
- [ ] No `__PUBLISHER__` or `__CONTACT_EMAIL__` text visible anywhere
- [ ] The contact email is real, monitored, and receives a test message
- [ ] The mailto button on the deletion page opens a mail client correctly
- [ ] Both light and dark mode look right
- [ ] Nothing overflows horizontally on a narrow screen

---

## Using a custom domain later

Buying a domain later does not require rebuilding anything:

1. Add a `CNAME` file at the repo root containing just the domain, e.g. `kifayat.app`
2. Point the domain's DNS at GitHub Pages
3. In **Settings → Pages**, set the custom domain and tick **Enforce HTTPS**
4. **Update the two URLs in Play Console** — the old `github.io` ones keep
   redirecting, but the listing should carry the real ones

Note that `.app` is an HSTS-preloaded TLD, so it is HTTPS-only. GitHub Pages
issues the certificate free.

---

## Keeping the policy honest

The privacy policy makes specific factual claims about the app. If any of these
stop being true, **the policy must be updated in the same change** — a privacy
policy that has drifted from the app is a Play policy violation and, in several
jurisdictions, a legal one.

Claims currently made, and what backs each:

| Claim on the page | What must stay true in the app |
|---|---|
| Transactions, amounts and notes are never sold or shared | The line held is **financial data**, not telemetry. `analytics_purity_test.dart` and `AnalyticsValue` having no `String` constructor are what keep it true. This replaced *"no usage analytics, no tracking"* on 2026-09-14: `firebase_analytics` and the advertising ID landed on 2026-08-29, and the claim was retired rather than patched. **The line now is an ad network inside the app** — that one stays never |
| No adverts inside the app | No ad SDK is ever added. Advertising *for* Kifayat, including the advertising ID and remarketing, is a different question and is allowed — see `docs/privacy-constitution.md` §2, which exists because these two are easy to conflate |
| Crash reports carry no financial data | `redact()` in `lib/src/utils/crash_reporter.dart` keeps rebuilding reports from a type and a `Failure.code` rather than filtering error text, and `test/utils/log_message_purity_test.dart` keeps passing. If either goes, this page is lying about the one thing it promises most specifically |
| Ledger encrypted on device | SQLCipher stays enabled, key stays in the Keystore |
| Android backup disabled | `android:allowBackup="false"` stays in the manifest |
| Everything travels over HTTPS | The app keeps refusing non-HTTPS URLs |
| Biometrics never leave the device | Auth stays delegated to Android |
| Notifications scheduled locally, no push service | No FCM or other push provider is added |
| Supabase, Firebase and Google Play are the only outside services | No **fourth** is introduced. Supabase and Crashlytics are processors; Firebase Analytics is not — Google uses that data for its own ends, so the policy says *shared*, and so does the Data safety card. `privacy_constitution_test.dart` fails on any new network-reaching package until the closed list in `docs/privacy-constitution.md` §3 is updated |
| Permission table | The **merged release** manifest's permission set matches the table exactly. Read it off a build, never from memory: `cd android && ./gradlew :app:processReleaseMainManifest`. It went from 6 entries to 13 on 2026-09-14 without one line of the app's own manifest changing — dependencies did it |
| Deletion removes the account server-side first | The delete RPC keeps its server-first ordering |

The permission table and the "what we don't collect" list are the two that rot
fastest, because adding one plugin can invalidate either.
