defmodule JsendTest do
  use ExUnit.Case
  doctest Jsend

  import Phoenix.ConnTest

  defp decode(conn) do
    {conn.status, conn.resp_body |> Jason.decode!()}
  end

  test "basic functionality" do
    data = "xxx"

    assert {200, %{"data" => nil, "status" => "ok"}} ===
             build_conn
             |> Jsend.ok(nil)
             |> decode

    assert {200, %{"data" => data, "status" => "ok"}} ===
             build_conn
             |> Jsend.ok(data)
             |> decode

    assert {201, %{"data" => data, "status" => "ok"}} ===
             build_conn
             |> Jsend.ok(201, data)
             |> decode

    assert {400, %{"data" => data, "status" => "fail"}} ===
             build_conn
             |> Jsend.fail(data)
             |> decode

    assert {404, %{"data" => data, "status" => "fail"}} ===
             build_conn
             |> Jsend.fail(:not_found, data)
             |> decode

    assert {403, %{"data" => data, "status" => "fail"}} ===
             build_conn
             |> Jsend.fail(403, data)
             |> decode

    message = "error!"

    assert {500, %{"message" => message, "status" => "error"}} ===
             build_conn
             |> Jsend.error(message)
             |> decode

    assert {501, %{"message" => message, "status" => "error"}} ===
             build_conn
             |> Jsend.error(501, message)
             |> decode

    assert {501, %{"message" => message, "data" => data, "status" => "error"}} ===
             build_conn
             |> Jsend.error(501, message, data)
             |> decode

    assert {501, %{"message" => message, "data" => %{"k" => "v"}, "status" => "error"}} ===
             build_conn
             |> Jsend.error(501, message, {:error, %{k: "v"}})
             |> decode

    assert {500, %{"message" => "some_atom", "status" => "error"}} ===
             build_conn
             |> Jsend.error(:internal_server_error, :some_atom)
             |> decode

    assert {500, %{"message" => "some_atom", "status" => "error"}} ===
             build_conn
             |> Jsend.error(:internal_server_error, {:error, :some_atom})
             |> decode

    assert {500, %{"message" => message, "status" => "error"}} ===
             build_conn
             |> Jsend.error(:internal_server_error, {:error, message})
             |> decode

    assert_raise ArgumentError,
                 "expected a string or an atom as the error message, got: {:not, :stringifiable, :message}",
                 fn ->
                   build_conn
                   |> Jsend.error(:internal_server_error, {:not, :stringifiable, :message})
                   |> decode
                 end

    # "Invalid …" does not show in production
    assert {500,
            %{
              "message" => message,
              "status" => "error",
              "data" => "invalid-json-data -- {:not, :jsonable, :detail}"
            }} ===
             build_conn
             |> Jsend.error(message, {:not, :jsonable, :detail})
             |> decode
  end
end
