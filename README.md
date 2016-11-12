# Sabayon Automated Repository Kit (sark)

This project provides the tools required to automatically build Sabayon
Entropy repositories, including the
[Sabayon Community Repositories](https://sabayon.github.io/community-website/).

## Getting Started

For local development, you will need some additional dependencies not yet
available in entropy.

If using bash, you can use `scripts/bootstap.sh` to install all necessary
dependencies locally (no root requured). This will do the following things:
- Set environment variables to use `.bundle` directory to store dependencies
- Install App::Cpanminus and Local::Lib
- Install Dist::Zilla and all necessary plugins
- Install all sark dependencies

```bash
source scripts/bootstrap.sh
```

## Running Tests

```bash
dzil test
```

