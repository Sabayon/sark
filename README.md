# NAME

Sark - Sabayon Automatized Repository Kit

# SYNOPSIS

# DESCRIPTION

This project provides the tools required to automatically build Sabayon
Entropy repositories, including the
[Sabayon Community Repositories](https://sabayon.github.io/community-website/).

# GETTING STARTED

For local development, you will need some additional dependencies not yet
available in entropy. If using bash, you can use `tools/bootstap.sh` to
install all necessary dependencies locally (no root requured).

    source tools/bootstrap.sh

This will take care of the following things:

- Set environment variables to use `.bundle` directory to store dependencies
- Install [App::Cpanminus](https://metacpan.org/pod/App::Cpanminus) and [Local::Lib](https://metacpan.org/pod/Local::Lib)
- Install [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla)
- Install all `sark` dependencies

To remove any changes made by the bootstrap script, delete the `.bundle`
directory in the project root, and restart your shell.

# Running Tests

    dzil test
