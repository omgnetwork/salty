defmodule Salty.Cloak.Deprecated.BoxTest do
  use ExUnit.Case

  # Alice and Bob are good friends.
  @alice_secret_key "NuPf7kaOvJrdETKI5PR7qV7KFTCzjX19QYBGTaPOAu4"
  @bob_public_key "1MV78_LqSCKetEfr9aoi0sMIXdsywfJgTyUDPPYiiRM"
  @alice_bob_config [
    module_tag: "BOX",
    tag: <<1>>,
    secret_key: @alice_secret_key,
    public_key: @bob_public_key
  ]

  # Eventually Alice break up with Bob and start sharing her secrets with Eve.
  @eve_public_key "Cc7JgYap0RDkNgl-q9WPEaHHXaxvI1jsTvw_Q6obOAQ"
  @alice_eve_config [
    module_tag: "BOX",
    tag: <<2>>,
    secret_key: @alice_secret_key,
    public_key: @eve_public_key
  ]

  test "Clock.encrypt/2 raises runtime error for deprecation" do
    assert_raise RuntimeError, fn ->
      Salty.Cloak.Deprecated.Box.encrypt("hello, world", @alice_bob_config)
    end
  end

  test "Box.decrypt/2 decrypts a ciphertext" do
    ciphertext =
      <<"BOX", 1>> <>
        Salty.Box.encrypt(%{
          secret_key: @alice_secret_key,
          public_key: @bob_public_key,
          payload: "hello, world"
        })

    assert Salty.Cloak.Deprecated.Box.decrypt(ciphertext, @alice_bob_config) ==
             {:ok, "hello, world"}
  end

  test "Box.decrypt/2 returns error if ciphertext tag do not matched" do
    ciphertext =
      <<"BOX", 1>> <>
        Salty.Box.encrypt(%{
          secret_key: @alice_secret_key,
          public_key: @bob_public_key,
          payload: "hello, world"
        })

    assert Salty.Cloak.Deprecated.Box.decrypt(ciphertext, @alice_eve_config) == :error
  end

  test "Box.can_decrypt?/2 returns whether the ciphertext is decryptable" do
    ciphertext =
      <<"BOX", 1>> <>
        Salty.Box.encrypt(%{
          secret_key: @alice_secret_key,
          public_key: @bob_public_key,
          payload: "hello, world"
        })

    assert Salty.Cloak.Deprecated.Box.can_decrypt?(ciphertext, @alice_bob_config)
    refute Salty.Cloak.Deprecated.Box.can_decrypt?(ciphertext, @alice_eve_config)

    refute Salty.Cloak.Deprecated.Box.can_decrypt?(
             ciphertext,
             module_tag: "BLAH",
             tag: <<1>>,
             secret_key: @alice_secret_key,
             public_key: @bob_public_key
           )
  end
end
