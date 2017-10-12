defmodule Salty.SecretBox.CloakTest do
  use ExUnit.Case

  # Alice and Bob used to own the key, but now it belongs to Bob.
  @alice_key "hUzGrIp91YZa9Hh2_jEiwmghkHfuRbPBBgtPMkN5gX0"
  @bob_key "QINgmF221y1WEg5-iyggMJNv-f370OnMwU6N3ZhgTIk"

  setup do
    Application.put_env(:cloak, Salty.SecretBox.Cloak,
      [
        default: true,
        tag: "SBX",
        keys: [
          %{tag: <<1>>, key: @alice_key},
          %{tag: <<2>>, key: @bob_key, default: true},
        ]
      ]
    )

    on_exit fn ->
      Application.delete_env(:cloak, Salty.SecretBox.Cloak)
    end
  end

  test "Clock.encrypt/1 and Clock.decrypt/1 encrypts and decrypts the given payload" do
    ciphertext = Cloak.encrypt("hello, world")
    assert <<"SBX", 2, _::binary>> = ciphertext
    assert Cloak.decrypt(ciphertext) == "hello, world"
  end

  test "Cloak.decrypt/1 decrypts a non-default key tag" do
    ciphertext = <<"SBX", 1>> <> Salty.SecretBox.encrypt(
      %{
        key: @alice_key,
        payload: "hello, world"
      }
    )

    assert Cloak.decrypt(ciphertext) == "hello, world"
  end

  test "Cloak.version/0 returns the default version" do
    assert Cloak.version() == <<"SBX", 2>>
  end
end
