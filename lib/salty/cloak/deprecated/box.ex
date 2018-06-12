defmodule Salty.Cloak.Deprecated.Box do
  @behaviour Cloak.Cipher
  @module __MODULE__

  @impl Cloak.Cipher
  def encrypt(_plaintext, _opts) do
    raise RuntimeError, "#{inspect(@module)} is deprecated"
  end

  @impl Cloak.Cipher
  def decrypt(ciphertext, opts) do
    module_tag = Keyword.fetch!(opts, :module_tag)
    mt_len = String.length(module_tag)
    tag = Keyword.fetch!(opts, :tag)

    secret_key = Keyword.fetch!(opts, :secret_key)
    public_key = Keyword.fetch!(opts, :public_key)

    case ciphertext do
      <<^module_tag::binary-size(mt_len), ^tag::binary-1, ciphertext2::binary>> ->
        {:ok,
         Salty.Box.decrypt(%{
           secret_key: secret_key,
           public_key: public_key,
           payload: ciphertext2
         })}

      _ ->
        :error
    end
  end

  @impl Cloak.Cipher
  def can_decrypt?(ciphertext, opts) do
    module_tag = Keyword.fetch!(opts, :module_tag)
    mt_len = String.length(module_tag)
    tag = Keyword.fetch!(opts, :tag)

    case ciphertext do
      <<^module_tag::binary-size(mt_len), ^tag::binary-1, _::binary>> -> true
      _ -> false
    end
  end
end
