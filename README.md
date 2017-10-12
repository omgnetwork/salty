# Salty

Elixir wrapper for [enacl](https://github.com/jlouis/enacl) and [libsodium](https://download.libsodium.org/doc/).

## Requirements

Installation of Salty require the following library to be installed:

* [libsodium](https://download.libsodium.org/doc/) **must** be installed on your machine.

## Installation

Add `salty` to your hex dependencies:

```
defp deps do
  [{:salty, git: "ssh://git@phabricator.omisego.io/source/salty.git"}]
end
```

Then run `mix deps.get` and you're done.

## Usage

Salty supports both symmetric-key encryption (SecretBox) and asymetric-key encryption (Box) with optional integration with [Cloak](https://github.com/danielberkompas/cloak/) for use in Ecto applications.

### Symmetric-key encryption

Symmetric-key encryption is an encryption that uses the **same key** to encrypt and decrypt the data. In this scheme, in order for Alice and Bob to send each other a message, they both will have to share the same key. No one else can decrypt the message without knowing the key.

```
iex> key = Salty.SecretBox.generate_key
"j6fy7rZP9ASvf1bmywWGRjrmh8gKANrg40yWZ-rSKpI"
iex> payload = Salty.SecretBox.encrypt(%{key: key, payload: "hello, world"})
"HDNg7zwwGejt9qWe8UbvQZFIMCGbO2L841Z4Pwh9Vhi-vKCCdILYlDy5RkHB"
iex> Salty.SecretBox.decrypt(%{key: key, payload: payload})
"hello, world"
```

### Using with Cloak

Salty symmetric-key encryption can be used as a cipher for [Cloak](https://github.com/danielberkompas/cloak/) and supports key migration via multiple key tags the same way `Cloak.AES.CTR` does:

```
config :cloak, Salty.SecretBox.Cloak,
  tag: "SBX",
  default: true,
  keys: [
    %{tag: <<1>>, key: "..."},
    %{tag: <<2>>, key: "...", default: true},
  ]
```

### Asymmetric-key encryption

Asymetric-key encryption is an encryption that uses **two different keys** for each party. For Alice to send Bob a message in this scheme, the message need to be encrypted with Alice's private key and Bob's public key, and for Bob to decrypt the message, Bob will need to decrypt the message with his own private key and Alice's public key. An attacker cannot decrypt the message without first obtaining private key of either Alice or Bob.

```
iex> alice_secret_key = Salty.Box.generate_secret_key
"NuPf7kaOvJrdETKI5PR7qV7KFTCzjX19QYBGTaPOAu4"
iex> alice_public_key = Salty.Box.generate_public_key(alice_secret_key)
"VU8_8ZV-njF3N7cB5YUkqWAZwRb88edvRb6J1GU230Q"
iex> bob_secret_key = Salty.Box.generate_secret_key
"FuhDx6EifCK_EudsBq1fp0RkcE2tASodXaUz85xgjoA"
iex> bob_public_key = Salty.Box.generate_public_key(bob_secret_key)
"1MV78_LqSCKetEfr9aoi0sMIXdsywfJgTyUDPPYiiRM"
iex> payload = Salty.Box.encrypt(%{
...>   secret_key: alice_secret_key,
...>   public_key: bob_public_key,
...>   payload: "hello, world"
...> })
"sigKcp3CuC3cW0Fio_MQ4SjkDH10KQh2fYVFSoouSgaOZxArzgGTUmraXxU_8gl0fjsEnA"
iex> Salty.Box.decrypt(%{
...>   secret_key: bob_secret_key,
...>   public_key: alice_public_key,
...>   payload: payload
...> })
"hello, world"
```

### Using with Cloak

Salty asymmetric-key encryption can be used as a cipher for [Cloak](https://github.com/danielberkompas/cloak/) and supports key migration via multiple key tags the same way `Cloak.AES.CTR` does:

```
config :cloak, Salty.Box.Cloak,
  tag: "BOX",
  default: true,
  keys: [
    %{tag: <<1>>, public_key: "...", secret_key: "..."},
    %{tag: <<2>>, public_key: "...", secret_key: "...", default: true},
  ]
```
