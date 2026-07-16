# Vapor API Docs

Source for [api.vapor.codes](https://api.vapor.codes) — the unified API reference for Vapor and its ecosystem.

It's a [Kiln](https://github.com/brokenhandsio/kiln) site that renders pre-built [DocC](https://www.swift.org/documentation/docc/) archives into the shared Vapor design system, with a module catalog, search, and per-package version switchers.

## Running locally

```sh
kiln serve   # build + preview at http://127.0.0.1:8080, rebuilding on change
kiln build   # build the static site into ./site
```

A build reuses the DocC archives already in `Content/archives` and only generates missing ones. Delete an archive (or the whole folder) to regenerate it on the next build.

## Adding or changing a package

Edit [`Sources/APIDocs/Packages.swift`](Sources/APIDocs/Packages.swift): each `APIPackage` is one repo, and each `PackageVersion` declares the modules it ships. See the [Kiln DocC docs](https://github.com/brokenhandsio/kiln) for the config API.
