defmodule Salty.SecretBoxTest do
  use ExUnit.Case

  # Alice and Bob are good friends, but everyone does have secrets.
  @alice_key "hUzGrIp91YZa9Hh2_jEiwmghkHfuRbPBBgtPMkN5gX0"
  @bob_key "QINgmF221y1WEg5-iyggMJNv-f370OnMwU6N3ZhgTIk"

  test "generate_key/0 generates an encryption key" do
    key = Salty.SecretBox.generate_key()
    {:ok, key_bytes} = Base.url_decode64(key, padding: false)
    assert byte_size(key) == 43
    assert byte_size(key_bytes) == :enacl.secretbox_key_size()
  end

  test "encrypt/1 and decrypt/1 encrypts and decrypts the given payload" do
    ciphertext = Salty.SecretBox.encrypt(%{key: @alice_key, payload: "hello, world"})
    plaintext = Salty.SecretBox.decrypt(%{key: @alice_key, payload: ciphertext})
    assert plaintext == "hello, world"
  end

  test "encrypt/1 and decrypt/1 errors if key is invalid base64" do
    ciphertext = Salty.SecretBox.encrypt(%{key: @alice_key, payload: "hello, world"})

    assert_raise Salty.KeyError, fn ->
      Salty.SecretBox.decrypt(%{key: "invalid", payload: ciphertext})
    end
  end

  test "encrypt/1 and decrypt/1 errors if key is invalid" do
    ciphertext = Salty.SecretBox.encrypt(%{key: @alice_key, payload: "hello, world"})

    assert_raise Salty.ValidationError, fn ->
      Salty.SecretBox.decrypt(%{key: @bob_key, payload: ciphertext})
    end
  end

  test "decrypt/1 errors if payload is invalid" do
    assert_raise Salty.PayloadError, fn ->
      Salty.SecretBox.decrypt(%{key: @alice_key, payload: "a"})
    end
  end
end
