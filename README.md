# Salty

Elixir wrapper for [enacl](https://github.com/jlouis/enacl) and [libsodium](https://download.libsodium.org/doc/).

## Requirements

Installation of Salty require the following library to be installed.

* [libsodium](https://download.libsodium.org/doc/) **must** be installed on your machine.

## Installation

Add `salty` to your hex dependencies:

```
defp deps do
  [{:salty, git: "ssh://git@phabricator.omisego.io/source/salty.git"}]
end
```