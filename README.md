# Kifayat — website

The public site for the **Kifayat** Android app. Three pages, no build step, no
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
| No advertising, analytics or tracking | No analytics or ad SDK is ever added. **Adding a crash reporter changes this page** — a reporter collects diagnostics and must be disclosed |
| Ledger encrypted on device | SQLCipher stays enabled, key stays in the Keystore |
| Android backup disabled | `android:allowBackup="false"` stays in the manifest |
| Everything travels over HTTPS | The app keeps refusing non-HTTPS URLs |
| Biometrics never leave the device | Auth stays delegated to Android |
| Notifications scheduled locally, no push service | No FCM or other push provider is added |
| Only Supabase touches the data | No second processor is introduced |
| Permission table | The manifest's permission set matches the table exactly |
| Deletion removes the account server-side first | The delete RPC keeps its server-first ordering |

The permission table and the "what we don't collect" list are the two that rot
fastest, because adding one plugin can invalidate either.
