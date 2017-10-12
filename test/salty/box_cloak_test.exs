defmodule Salty.Box.CloakTest do
  use ExUnit.Case

  # Alice and Bob are good friends.
  @alice_secret_key "NuPf7kaOvJrdETKI5PR7qV7KFTCzjX19QYBGTaPOAu4"
  @bob_public_key "1MV78_LqSCKetEfr9aoi0sMIXdsywfJgTyUDPPYiiRM"

  # Eventually Alice break up with Bob and start sharing her secrets with Eve.
  @eve_public_key "Cc7JgYap0RDkNgl-q9WPEaHHXaxvI1jsTvw_Q6obOAQ"

  setup do
    Application.put_env(:cloak, Salty.Box.Cloak,
      [
        default: true,
        tag: "BOX",
        keys: [
          %{tag: <<1>>, secret_key: @alice_secret_key, public_key: @bob_public_key},
          %{tag: <<2>>, secret_key: @alice_secret_key, public_key: @eve_public_key, default: true},
        ]
      ]
    )

    on_exit fn ->
      Application.delete_env(:cloak, Salty.Box.Cloak)
    end
  end

  test "Clock.encrypt/1 and Clock.decrypt/1 encrypts and decrypts the given payload" do
    ciphertext = Cloak.encrypt("hello, world")
    assert <<"BOX", 2, _::binary>> = ciphertext
    assert Cloak.decrypt(ciphertext) == "hello, world"
  end

  test "Cloak.decrypt/1 decrypts a non-default key tag" do
    ciphertext = <<"BOX", 1>> <> Salty.Box.encrypt(
      %{
        secret_key: @alice_secret_key,
        public_key: @bob_public_key,
        payload: "hello, world"
      }
    )

    assert Cloak.decrypt(ciphertext) == "hello, world"
  end

  test "Cloak.version/0 returns the default version" do
    assert Cloak.version() == <<"BOX", 2>>
  end
end
