defmodule Salty.Box.Cloak do
  @behaviour Cloak.Cipher
  @module __MODULE__

  def encrypt(plaintext) do
    config = Salty.Utils.get_config(:cloak, @module)
    config.tag <> Salty.Box.encrypt(
      %{
        secret_key: config.secret_key,
        pubic_key: config.public_key,
        payload: plaintext
      }
    )
  end

  def decrypt(<<tag::binary-1, ciphertext::binary>>) do
    config = Salty.Utils.get_config(:cloak, @module, tag)
    Salty.Box.decrypt(
      %{
        secret_key: config.secret_key,
        public_key: config.public_key,
        payload: ciphertext
      }
    )
  end

  def version do
    Salty.Utils.get_config(:cloak, @module).tag
  end
end
