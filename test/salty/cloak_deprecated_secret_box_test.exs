defmodule Salty.Cloak.Deprecated.SecretBoxTest do
  use ExUnit.Case

  # Alice and Bob used to own the key, but now it belongs to Bob.
  @alice_key "hUzGrIp91YZa9Hh2_jEiwmghkHfuRbPBBgtPMkN5gX0"
  @bob_key "QINgmF221y1WEg5-iyggMJNv-f370OnMwU6N3ZhgTIk"

  @alice_config [module_tag: "SBX", tag: <<1>>, key: @alice_key]
  @bob_config [module_tag: "SBX", tag: <<2>>, key: @bob_key]

  test "SecretBox.encrypt/2 raises runtime error for deprecation" do
    assert_raise RuntimeError, fn ->
      Salty.Cloak.Deprecated.SecretBox.encrypt("hello, world", @alice_config)
    end
  end

  test "Cloak.decrypt/2 decrypts a ciphertext" do
    ciphertext =
      <<"SBX", 1>> <>
        Salty.SecretBox.encrypt(%{
          key: @alice_key,
          payload: "hello, world"
        })

    assert Salty.Cloak.Deprecated.SecretBox.decrypt(ciphertext, @alice_config) ==
             {:ok, "hello, world"}
  end

  test "SecretBox.decrypt/2 returns error if ciphertext tag do not matched" do
    ciphertext =
      <<"SBX", 1>> <>
        Salty.SecretBox.encrypt(%{
          key: @alice_key,
          payload: "hello, world"
        })

    assert Salty.Cloak.Deprecated.SecretBox.decrypt(ciphertext, @bob_config) == :error
  end

  test "SecretBox.can_decrypt?/2 returns whether the ciphertext is decryptable" do
    ciphertext =
      <<"SBX", 1>> <>
        Salty.SecretBox.encrypt(%{
          key: @alice_key,
          payload: "hello, world"
        })

    assert Salty.Cloak.Deprecated.SecretBox.can_decrypt?(ciphertext, @alice_config)
    refute Salty.Cloak.Deprecated.SecretBox.can_decrypt?(ciphertext, @bob_config)

    refute Salty.Cloak.Deprecated.SecretBox.can_decrypt?(
             ciphertext,
             module_tag: "BLAH",
             tag: <<1>>,
             key: @alice_key
           )
  end
end
