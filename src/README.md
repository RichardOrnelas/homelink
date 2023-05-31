# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

## System Setup
- _Optional_ Install Homebrew
  ```
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'export PATH="/usr/local/sbin:$PATH"' >> ~/.zshrc
    source ~/.zshrc # If you see weird behavior, restart your terminal
    brew doctor
  ```
- Install `asdf`
  ```
    brew install coreutils curl git gpg gawk zsh yarn asdf
    echo -e "\n. $(brew --prefix asdf)/asdf.sh" >> ~/.zshrc
    echo 'legacy_version_file = yes' >> ~/.asdfrc
  ```
- Install Ruby
  ```
  asdf plugin add ruby
  asdf install ruby 3.2.2
  asdf global ruby 3.2.2
  ```
- Install PostGres
  ```
  asdf plugin add postgres
  asdf install postgres 13.2
  asdf global postgres 13.2
  $HOME/.asdf/installs/postgres/13.2/bin/pg_ctl -D $HOME/.asdf/installs/postgres/13.2/data -l logfile start
  ```
- Install Rails
  `gem install bundler rails`
- Bundle
  `bundle install`
- Setup Database
  `RAILS_ENV=development rails db:create db:migrate`






* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
