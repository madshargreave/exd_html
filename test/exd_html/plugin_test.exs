defmodule ExdHTML.PluginTest do
  use ExUnit.Case

  alias Exd.Query
  alias Exd.Repo

  defmodule MyPlugin do
    use Exd.Plugin.String
    use Exd.Plugin.Integer
    use Exd.Plugin.Boolean
    use Exd.Plugin.HTML
  end

  setup do
    Application.put_env(:exd, :plugin, MyPlugin)
    :ok
  end

  @html """
    <html>
    <body>
      <h1 class="header">Coin Table</h1>
      <table id="coins">
        <tbody>
          <tr>
            <td class="name">bitcoin</td>
            <td class="symbol">btc</td>
          </tr>
          <tr>
            <td class="name">ethereum</td>
            <td class="symbol">eth</td>
          </tr>
        </tbody>
      </table>
    </body>
    </html>
  """

  describe "html_crawl/1" do
    test "it returns page" do
      assert [
        %{
          title: "Top 100 Cryptocurrencies by Market Capitalization"
        }
      ] ==
        Query.new
        |> Query.from("html", {:html_crawl, "'https://coinmarketcap.com'"})
        |> Query.select(%{
          title: {:html_parse_text, "html.body", "'h1.text-center.h2'"}
        })
        |> Repo.stream
        |> Enum.to_list
    end
  end

  describe "html_parse_list/1" do
    test "it extracts text from node" do
      assert [
        %{name: "bitcoin", symbol: "btc"},
        %{name: "ethereum", symbol: "eth"}
      ] ==
        Query.new
        |> Query.from("rows", {:html_parse_list, "'#{@html}'", "'table#coins > tbody > tr'"})
        |> Query.select(%{
          name: {:html_parse_text, "rows", "'.name'"},
          symbol: {:html_parse_text, "rows", "'.symbol'"}
        })
        |> Repo.stream
        |> Enum.to_list
    end
  end

  describe "html_parse_text/1" do
    test "it extracts text from html string" do
      assert [
        %{name: "Coin Table"}
      ] ==
        Query.new
        |> Query.from("html", {:html_parse, "'#{@html}'"})
        |> Query.select(%{
          name: {:html_parse_text, "html", "'h1.header'"}
        })
        |> Repo.stream
        |> Enum.to_list
    end
  end

end

alias Exd.Query

coins = {
  :html_crawl,
  "https://coinmarketcap.com",
  [
    concurrency: 1
  ]
}

details = {
  :source,
  {
    :html_crawl,
    {:replace, "https://coinmarketcap.com/currencies/{{symbol}}", symbol: "args.symbol"},
    [
      concurrency: 5,
      timeout: 5000,
      retries: 3
    ]
  },
  [
    symbol: {:string, required: true}
  ]
}

query =
  Query.new
  |> Query.from("coins", coins)
  |> Query.select({:html_parse_list, "coins.document", "table#currencies tr"})

query =
  Query.new
  |> Query.from("coins", query)
  |> Query.join("details", details, symbol: "coins.symbol")
  |> Query.select(%{
    name: {:html_parse_text, "coins", ".currency-name-name"},
    symbol: {:html_parse_text, "coins", ".currency-symbol-name"},
    marketcap: {:html_parse_currency, "coins", ".currency-marketcap-name"},
    price: {:html_parse_currency, "coins", ".currency-price-name"},
    twitter_followers: {:html_parse_integer, "details.content", ".stats > .twitter_followers"},
    reddit_subs: {:html_parse_integer, "details.content", ".stats > .reddit_subs"}
  })

query =
  Query.new
  |> Query.from("coins", query)
  |> Query.where("coins.marketcap", :>, 100_000_000)
  |> Query.into("top-coins")
