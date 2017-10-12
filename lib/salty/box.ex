defmodule Salty.Box do
  @moduledoc """
  Asymmetric-key encryption using libsodium's crypto box.
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
    secret_key = Salty.Utils.decode_key(secret_key, :enacl.box_secret_key_bytes)

    filler = :binary.copy(<<0::8>>, 31)
    base_point = <<9::8, filler::binary>>
    public_key = :enacl.curve25519_scalarmult(secret_key, base_point)

    Base.url_encode64(public_key, padding: false)
  end

  @doc """
  Encrypt the given `payload` with the given `secret_key` and `public_key`.
  The returned ciphertext will only be readable by the owner of the secret key
  or the owner of the public key.

  ## Examples

      iex> Salty.Box.encrypt(%{
      ...>   secret_key: secret_key,
      ...>   public_key: public_key,
      ...>   payload: "hello, world",
      ...> })
      "DE05lqAFZUK4p6sXsvQ8WT0UensYgHiHoWOJQAQ_dCWZrAXcwQdJbW-3FSz7RRmrVAwnyw"

  """
  @spec encrypt(Map) :: binary
  def encrypt(%{secret_key: secret_key, public_key: public_key, payload: payload}) do
    secret_key = Salty.Utils.decode_key(secret_key, :enacl.box_secret_key_bytes)
    public_key = Salty.Utils.decode_key(public_key, :enacl.box_public_key_bytes)

    nonce = :enacl.randombytes(:enacl.box_nonce_size)
    ciphertext = :enacl.box(payload, nonce, public_key, secret_key)

    Base.url_encode64(nonce <> ciphertext, padding: false)
  end

  @doc """
  Decrypt the given `ciphertext` with the given `secret_key` and `public_key`.
  Only ciphertext that were created using the secret key or the public
  key will be readable.

  ## Examples

      iex> Salty.Box.decrypt(%{
      ...>   secret_key: secret_key,
      ...>   public_key: public_key,
      ...>   payload: payload,
      ...> })
      "hello, world"

  """
  @spec decrypt(Map) :: binary
  def decrypt(%{secret_key: secret_key, public_key: public_key, payload: payload}) do
    secret_key = Salty.Utils.decode_key(secret_key, :enacl.box_secret_key_bytes)
    public_key = Salty.Utils.decode_key(public_key, :enacl.box_public_key_bytes)

    nonce_size = :enacl.box_nonce_size
    case Base.url_decode64(payload, padding: false) do
      {:ok, <<nonce::binary-size(nonce_size), ciphertext::binary>>} ->
        case :enacl.box_open(ciphertext, nonce, public_key, secret_key) do
          {:ok, plaintext} -> plaintext
          {:error, _} -> raise Salty.ValidationError
        end
      _ -> raise Salty.PayloadError, message: "invalid payload: #{payload}"
    end
  end
end
