# MubixByte Repo

Public APT repository for iOS jailbreak packages by MubixByte.

Current categories: **iOS 16 to iOS 18** and **Fonts**.

Packages: **Homescreen18**, **Ersatz**, **CC18**, **PopOutButtons**, **AppIndex**, and **A-Font**.

Source URL: `https://mubixbyte.github.io/mubixrepo/`

## Adding a package

1. Put the distributable `.deb` in `debs/`.
2. Commit and push to `main`.
3. GitHub Actions validates package IDs, rejects duplicates, generates `Packages`,
   `Packages.gz`, `Packages.bz2`, and publishes the repository to GitHub Pages.

Only publish packages you created, open-source packages whose license permits
redistribution, or packages whose author explicitly allowed mirroring.
