defmodule Salty.SecretBox.Cloak do
  @behaviour Cloak.Cipher
  @module __MODULE__

  def encrypt(plaintext) do
    config = Salty.Utils.get_config(:cloak, @module)
    config.tag <> Salty.SecretBox.encrypt(
      %{
        key: config.key,
        payload: plaintext
      }
    )
  end

  def decrypt(<<tag::binary-1, ciphertext::binary>>) do
    config = Salty.Utils.get_config(:cloak, @module, tag)
    Salty.SecretBox.decrypt(
      %{
        key: config.key,
        payload: ciphertext
      }
    )
  end

  def version do
    Salty.Utils.get_config(:cloak, @module).tag
  end
end
