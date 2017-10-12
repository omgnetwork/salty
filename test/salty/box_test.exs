defmodule Salty.BoxTest do
  use ExUnit.Case

  # Alice and Bob are good friends.
  @alice_secret_key "NuPf7kaOvJrdETKI5PR7qV7KFTCzjX19QYBGTaPOAu4"
  @alice_public_key "VU8_8ZV-njF3N7cB5YUkqWAZwRb88edvRb6J1GU230Q"

  @bob_secret_key "FuhDx6EifCK_EudsBq1fp0RkcE2tASodXaUz85xgjoA"
  @bob_public_key "1MV78_LqSCKetEfr9aoi0sMIXdsywfJgTyUDPPYiiRM"

  # Eve, not so much.
  @eve_secret_key "wPaWxCi6heDTYsfP9TN3V6yxLH3FlLUjfVOa9X-RG2A"
  @eve_public_key "Cc7JgYap0RDkNgl-q9WPEaHHXaxvI1jsTvw_Q6obOAQ"

  test "generate_secret_key/0 generates a secret key" do
    secret_key = Salty.Box.generate_secret_key
    {:ok, secret_key_bytes} = Base.url_decode64(secret_key, padding: false)
    assert byte_size(secret_key) == 43
    assert byte_size(secret_key_bytes) == :enacl.box_secret_key_bytes
  end

  test "generate_public_key/1 generates a public key from secret key" do
    public_key = Salty.Box.generate_public_key(@alice_secret_key)
    {:ok, public_key_bytes} = Base.url_decode64(public_key, padding: false)

    assert public_key == @alice_public_key
    assert byte_size(public_key) == 43
    assert byte_size(public_key_bytes) == :enacl.box_public_key_bytes
  end

  test "generate_public_key/1 errors if secret key is invalid base64" do
    assert_raise ArgumentError, fn ->
      Salty.Box.generate_public_key("invalid")
    end
  end

  test "generate_public_key/1 errors if secret key is invalid" do
    assert_raise ArgumentError, fn ->
      Salty.Box.generate_public_key("dGVzdA")
    end
  end

  test "encrypt/1 and decrypt/1 encrypts and decrypts the given payload" do
    ciphertext = Salty.Box.encrypt(
      %{
        secret_key: @alice_secret_key,
        public_key: @bob_public_key,
        payload: "hello, world"
      }
    )

    plaintext = Salty.Box.decrypt(
      %{
        secret_key: @bob_secret_key,
        public_key: @alice_public_key,
        payload: ciphertext
      }
    )

    assert plaintext == "hello, world"
  end

  test "encrypt/1 and decrypt/1 errors if keys are invalid" do
    ciphertext = Salty.Box.encrypt(
      %{
        secret_key: @alice_secret_key,
        public_key: @bob_public_key,
        payload: "hello, world"
      }
    )

    assert_raise Salty.ValidationError, fn ->
      Salty.Box.decrypt(
        %{
          secret_key: @bob_public_key,
          public_key: @alice_public_key,
          payload: ciphertext
        }
      )
    end
  end

  test "encrypt/1 and decrypt/1 errors if keys are not the intended party" do
    ciphertext = Salty.Box.encrypt(
      %{
        secret_key: @alice_secret_key,
        public_key: @bob_public_key,
        payload: "hello, world"
      }
    )

    assert_raise Salty.ValidationError, fn ->
      Salty.Box.decrypt(
        %{
          secret_key: @eve_secret_key,
          public_key: @alice_public_key,
          payload: ciphertext
        }
      )
    end

    assert_raise Salty.ValidationError, fn ->
      Salty.Box.decrypt(
        %{
          secret_key: @bob_secret_key,
          public_key: @eve_public_key,
          payload: ciphertext
        }
      )
    end
  end

  test "encrypt/1 errors if secret key is invalid base64" do
    assert_raise ArgumentError, fn ->
      Salty.Box.encrypt(
        %{
          secret_key: "invalid",
          public_key: @bob_public_key,
          payload: "hello, world"
        }
      )
    end
  end

  test "encrypt/1 errors if secret key is invalid" do
    assert_raise ArgumentError, fn ->
      Salty.Box.encrypt(
        %{
          secret_key: "dGVzdA",
          public_key: @bob_public_key,
          payload: "hello, world"
        }
      )
    end
  end

  test "encrypt/1 errors if public key is invalid base64" do
    assert_raise ArgumentError, fn ->
      Salty.Box.encrypt(
        %{
          secret_key: @alice_secret_key,
          public_key: "invalid",
          payload: "hello, world"
        }
      )
    end
  end

  test "encrypt/1 errors if public key is invalid" do
    assert_raise ArgumentError, fn ->
      Salty.Box.encrypt(
        %{
          secret_key: @alice_secret_key,
          public_key: "dGVzdA",
          payload: "hello, world"
        }
      )
    end
  end

  test "decrypt/1 errors if secret key is invalid base64" do
    assert_raise ArgumentError, fn ->
      Salty.Box.decrypt(
        %{
          secret_key: "invalid",
          public_key: @alice_public_key,
          payload: "aDBai91GSGrCB5bKdyjD2CVZ_D1Kd1g3UohStf6O7wPFYO1FnGuUS9-v"
        }
      )
    end
  end

  test "decrypt/1 errors if secret key is invalid" do
    assert_raise ArgumentError, fn ->
      Salty.Box.decrypt(
        %{
          secret_key: "dGVzdA",
          public_key: @alice_public_key,
          payload: "aDBai91GSGrCB5bKdyjD2CVZ_D1Kd1g3UohStf6O7wPFYO1FnGuUS9-v"
        }
      )
    end
  end

  test "decrypt/1 errors if public key is invalid base64" do
    assert_raise ArgumentError, fn ->
      Salty.Box.decrypt(
        %{
          secret_key: @bob_secret_key,
          public_key: "invalid",
          payload: "aDBai91GSGrCB5bKdyjD2CVZ_D1Kd1g3UohStf6O7wPFYO1FnGuUS9-v"
        }
      )
    end
  end

  test "decrypt/1 errors if public key is invalid" do
    assert_raise ArgumentError, fn ->
      Salty.Box.decrypt(
        %{
          secret_key: @bob_secret_key,
          public_key: "dGVzdA",
          payload: "aDBai91GSGrCB5bKdyjD2CVZ_D1Kd1g3UohStf6O7wPFYO1FnGuUS9-v"
        }
      )
    end
  end
end
