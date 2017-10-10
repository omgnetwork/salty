defmodule Salty.Utils do
  @spec get_config(atom, module) :: Map
  def get_config(app, module) do
    Application.get_env(app, module)
    |> Keyword.get(:keys)
    |> Enum.find(fn(key) -> key.default end)
  end

  @spec get_config(atom, module, String.t) :: Map
  def get_config(app, module, tag) do
    Application.get_env(app, module)
    |> Keyword.get(:keys)
    |> Enum.find(fn(key) -> key.tag == tag end)
  end
end
