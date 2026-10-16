# devkaltech/kifayat: redirects only

The Kifayat website moved to **https://kifayat.com.pk** in October 2026. Its
source is now [`mehrwise/kifayat-site`](https://github.com/mehrwise/kifayat-site),
deployed by Cloudflare Pages.

What GitHub Pages still serves here, at `devkaltech.github.io/kifayat/`, is one
page per old URL, each sending the visitor to the same path on the new domain.
The query and fragment are carried across, so a confirmation link from an old
email still lands on `/confirmed/` with whatever Supabase appended.

Keep it until no old link can reasonably still be in use, then turn GitHub
Pages off.
