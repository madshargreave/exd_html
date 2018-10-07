defmodule ExdHTML.PluginTest do
  use ExUnit.Case
  import Exd.Query.Builder

  alias Exd.Query
  alias Exd.Repo

  @plugins [
    Exd.Plugin.HTMLParseList,
    Exd.Plugin.HTMLParseText,
    Exd.Plugin.HTMLParseAttr
  ]

  setup do
    Application.put_env(:exd, :plugins, @plugins)
    :ok
  end

  describe "html_crawl/1" do
    test "it returns page" do
      rows =
        from r in fetch("https://coinmarketcap.com"),
        select: %{
          row: unnest(html_parse_list(r.body, "table#currencies > tbody > tr"))
        }

      coins =
        from r in subquery(rows),
        select: %{
          name: html_parse_text(r.row, ".currency-name-container"),
          slug: regex(html_parse_attr(r.row, "href", ".currency-name-container"), ~r/\/currencies\/([\-a-zA-Z0-9]+)\/$/),
          symbol: html_parse_text(r.row, ".currency-symbol"),
          price: cast(html_parse_attr(r.row, "data-usd", "a.price"), :float),
          marketcap: cast(html_parse_attr(r.row, "data-usd", ".market-cap"), :float),
          volume: cast(html_parse_attr(r.row, "data-usd", ".volume"), :float)
        }

      top_coins =
        from c in subquery(coins),
        where: c.marketcap > 30_000_000_000,
        select: c

      details =
        from r in fetch(
          interpolate("https://coinmarketcap.com/currencies/?/", args.symbol)
        ),
        select: %{
          website: replace(
            regex(
              html_parse_attr(r.body, "href", ".details-panel-item--links > li:nth-child(2) a"),
              ~r/https?:\/\/([a-zA-Z0-9\-\.]+\.[a-z]+)/
            ),
            "www",
            ""
          ),
          explorer: html_parse_attr(r.body, "href", ".details-panel-item--links > li:nth-child(4) a")
        }

      alexa =
        from r in fetch(interpolate("https://www.alexa.com/siteinfo/?", args.website)),
        select: %{
          alexa_global: cast(html_parse_text(r.body, ".globleRank metrics-data"), :integer)
        }

      final =
        from c in subquery(top_coins),
        join: d in details, on: d.symbol = c.symbol,
        join: a in alexa, on: a.website = c.website,
        select: merge(c, d, a)

      assert [
        %{
          marketcap: 113783675523.0,
          name: "Bitcoin",
          price: 6578.40789304,
          slug: "bitcoin",
          symbol: "BTC",
          volume: 4126182192.98,
          alexa_global: 14019,
          website: "...",
          explorer: "..."
        },
        %{
          marketcap: 23731849182.5,
          name: "Ethereum",
          price: 232.038863278,
          slug: "ethereum",
          symbol: "ETH",
          volume: 2098614651.97,
          alexa_global: 14019,
          website: "...",
          explorer: "..."
        }
      ] = Repo.all(final)
    end
  end

end
