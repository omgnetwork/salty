defmodule Salty.Utils do
  @spec get_config(atom, module) :: Map
  def get_config(app, module) do
    Application.get_env(app, module)
    |> Keyword.get(:keys)
    |> Enum.find(fn(key) -> Map.has_key?(key, :default) && key.default end)
  end

  @spec get_config(atom, module, String.t) :: Map
  def get_config(app, module, tag) do
    Application.get_env(app, module)
    |> Keyword.get(:keys)
    |> Enum.find(fn(key) -> key.tag == tag end)
  end

  @spec decode_key(binary, integer) :: binary
  def decode_key(secret_key, key_size) do
    case Base.url_decode64(secret_key, padding: false) do
      {:ok, <<secret_key::binary-size(key_size)>>} -> secret_key
      _ -> raise Salty.KeyError
    end
  end
end
