# DOrc Terraform Stock Modules

Curated, versioned Terraform modules consumed by the
[DOrc](https://github.com/sefe/dorc) stock-module catalog
(browse-and-deploy wizard).

## How DOrc consumes this repo

Module source is **pulled at deploy time**: each catalog manifest in
`sefe/dorc` (`stock-modules-manifests/<name>-<version>.yaml`) pins

- `source.locator` → this repo's clone URL
- `source.ref` → an immutable tag `stock-modules/<name>/v<version>`
- module path convention → `stock-modules/<name>` (overridable via
  `source.subPath`)

The DOrc Terraform runner clones that tag and runs `stock-modules/<name>`
with wizard-supplied parameters. Nothing in this repo is deployed by merging
to `main` — only tagged refs are consumed.

## Layout

```
stock-modules/
  <module>/
    main.tf / variables.tf / outputs.tf / versions.tf
    README.md
    examples/basic/
```

## Releasing a module version

1. PR the module change to `main` (CI: terraform fmt/validate, tflint,
   secret-output lint).
2. Tag the released commit: `git tag stock-modules/<name>/v<X.Y.Z>` and push
   the tag. **Never move a published tag** — DOrc deploy audit records
   `name@version` and relies on the ref being immutable.
3. In `sefe/dorc`, add a new manifest `<name>-<X.Y.Z>.yaml` pointing at the
   new tag (existing manifests are immutable — the dorc CI enforces this).

## Module contract

See [docs/Terraform/MODULE-CONTRACT.md](https://github.com/sefe/dorc/blob/main/docs/Terraform/MODULE-CONTRACT.md)
in the DOrc repo: required `environment_tier`/naming inputs, no
`sensitive = false` on secret-pattern outputs, pinned provider versions, and
a working `examples/basic`.
