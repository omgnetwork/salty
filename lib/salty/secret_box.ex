defmodule Salty.SecretBox do
  @moduledoc """
  Symmetric-key encryption using libsodium's secret box.
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
  Encrypt the given `payload` with the given `key`.

  ## Examples

  To encrypt a plaintext using a key generated from
  `Salty.SecretBox.generate_key/0`:

      iex> Salty.SecretBox.encrypt(%{key: key, payload: "hello, world"})
      "HDNg7zwwGejt9qWe8UbvQZFIMCGbO2L841Z4Pwh9Vhi-vKCCdILYlDy5RkHB"

  """
  @spec encrypt(Map) :: binary
  def encrypt(%{key: key, payload: payload}) do
    key = Salty.Utils.decode_key(key, :enacl.secretbox_key_size)
    nonce = :enacl.randombytes(:enacl.secretbox_nonce_size)
    ciphertext = :enacl.secretbox(payload, nonce, key)

    Base.url_encode64(nonce <> ciphertext, padding: false)
  end

  @doc """
  Decrypt the given `payload` with the given `key`.

  ## Examples

      iex> Salty.SecretBox.decrypt(%{key: key, payload: payload})
      "hello, world"

  """
  @spec decrypt(Map) :: binary
  def decrypt(%{key: key, payload: payload}) do
    key = Salty.Utils.decode_key(key, :enacl.secretbox_key_size)

    nonce_size = :enacl.secretbox_nonce_size
    case Base.url_decode64(payload, padding: false) do
      {:ok, <<nonce::binary-size(nonce_size), ciphertext::binary>>} ->
        case :enacl.secretbox_open(ciphertext, nonce, key) do
          {:ok, plaintext} -> plaintext
          {:error, _} -> raise Salty.ValidationError
        end
      _ -> raise Salty.PayloadError, message: "invalid payload: #{payload}"
    end
  end
end
