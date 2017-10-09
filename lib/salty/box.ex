defmodule Salty.Box do
  @moduledoc """
  Asymmetric encryption using libsodium's crypto box.
  """

  @doc """
  Generate a new secret key.

  ## Examples

      iex> Salty.Box.generate_secret_key
      "NuPf7kaOvJrdETKI5PR7qV7KFTCzjX19QYBGTaPOAu4"

  """
  @spec generate_secret_key :: binary
  def generate_secret_key do
    secret_key = :enacl.randombytes(:enacl.box_secret_key_bytes)
    Base.url_encode64(secret_key, padding: false)
  end

  @doc """
  Generate a public key from the given `secret_key`.

  ## Examples

      iex> Salty.Box.generate_public_key(secret_key)
      "VU8_8ZV-njF3N7cB5YUkqWAZwRb88edvRb6J1GU230Q"

  """
  @spec generate_public_key(binary) :: binary
  def generate_public_key(secret_key) do
    {:ok, secret_key} = Base.url_decode64(secret_key, padding: false)

    filler = :binary.copy(<<0::8>>, 31)
    base_point = <<9::8, filler::binary>>
    public_key = :enacl.curve25519_scalarmult(secret_key, base_point)

    Base.url_encode64(public_key, padding: false)
  end

  @doc """
  Encrypt the given `message` with the given `secret_key` and `public_key`.
  The returned ciphertext will only be readable by the owner of the secret key
  or the owner of the public key.

  ## Examples

      iex> Salty.Box.encrypt(secret_key, public_key, "hello, world")
      "DE05lqAFZUK4p6sXsvQ8WT0UensYgHiHoWOJQAQ_dCWZrAXcwQdJbW-3FSz7RRmrVAwnyw"

  """
  @spec encrypt(binary, binary, binary) :: binary
  def encrypt(secret_key, public_key, message) do
    {:ok, secret_key} = Base.url_decode64(secret_key, padding: false)
    {:ok, public_key} = Base.url_decode64(public_key, padding: false)

    nonce = :enacl.randombytes(:enacl.box_nonce_size)
    ciphertext = :enacl.box(message, nonce, public_key, secret_key)

    Base.url_encode64(nonce <> ciphertext, padding: false)
  end

  @doc """
  Decrypt the given `message` with the given `secret_key` and `public_key`.
  Only ciphertext that were created using the secret key or the public
  key will be readable.

  ## Examples

      iex> Salty.Box.decrypt(secret_key, public_key, message)
      "hello, world"

  """
  @spec decrypt(binary, binary, binary) :: binary
  def decrypt(secret_key, public_key, message) do
    {:ok, secret_key} = Base.url_decode64(secret_key, padding: false)
    {:ok, public_key} = Base.url_decode64(public_key, padding: false)
    {:ok, combined} = Base.url_decode64(message, padding: false)

    nonce_size = :enacl.box_nonce_size
    <<nonce::binary-size(nonce_size), ciphertext::binary>> = combined
    {:ok, plaintext} = :enacl.box_open(ciphertext, nonce, public_key, secret_key)

    plaintext
  end
end
