defmodule Salty.SecretBox do
  @moduledoc """
  Symmetric encryption using libsodium's secret box.
  """

  @doc """
  Generate a new secret key.

  ## Examples

      iex> Salty.SecretBox.generate_key
      "j6fy7rZP9ASvf1bmywWGRjrmh8gKANrg40yWZ-rSKpI"

  """
  @spec generate_key :: binary
  def generate_key do
    key = :enacl.randombytes(:enacl.secretbox_key_size)
    Base.url_encode64(key, padding: false)
  end

  @doc """
  Encrypt the given `message` with the given `key`.

  ## Examples

  To encrypt a plaintext using a key generated from
  `Salty.SecretBox.generate_key/0`:

      iex> Salty.SecretBox.encrypt(key, "hello, world")
      "HDNg7zwwGejt9qWe8UbvQZFIMCGbO2L841Z4Pwh9Vhi-vKCCdILYlDy5RkHB"

  """
  @spec encrypt(binary, binary) :: binary
  def encrypt(key, message) do
    {:ok, key} = Base.url_decode64(key, padding: false)
    nonce = :enacl.randombytes(:enacl.secretbox_nonce_size)
    ciphertext = :enacl.secretbox(message, nonce, key)

    Base.url_encode64(nonce <> ciphertext, padding: false)
  end

  @doc """
  Decrypt the given `message` with the given `key`.

  ## Examples

      iex> Salty.SecretBox.decrypt(key, message)
      "hello, world"

  """
  @spec decrypt(binary, binary) :: binary
  def decrypt(key, message) do
    {:ok, key} = Base.url_decode64(key, padding: false)
    {:ok, combined} = Base.url_decode64(message, padding: false)

    nonce_size = :enacl.secretbox_nonce_size
    <<nonce::binary-size(nonce_size), ciphertext::binary>> = combined
    {:ok, plaintext} = :enacl.secretbox_open(ciphertext, nonce, key)

    plaintext
  end
end
