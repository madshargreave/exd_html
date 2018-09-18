defmodule ExdHTML.Crawler do
  @moduledoc false
  alias HTTPoison.Response

  @doc """
  Parse a list of nodes
  """
  @spec crawl(binary(), keyword()) :: any()
  def crawl(url, opts \\ []) do
    concurrency = Keyword.get(opts, :concurrency)
    timeout = Keyword.get(opts, :timeout)
    retries = Keyword.get(opts, :retries)

    [url]
    # |> Task.async_stream(&fetch_page/1, concurrency: concurrency)
    |> Stream.map(&fetch_page/1)
    |> Stream.filter(&successful/1)
    |> Stream.map(&parse_record/1)
    |> Enum.to_list
  end

  defp fetch_page(url) do
    HTTPoison.get(url)
  end

  defp successful({:ok, _result}), do: true
  defp successful(_), do: false

  defp parse_record({:ok, %Response{status_code: status, body: body} = _response}) do
    %{
      "status" => status,
      "body" => body
    }
  end

end
