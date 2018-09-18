defmodule Exd.Plugin.HTML do
  @doc false
  defmacro __using__(_opts) do
    quote do
      import Exd.Plugin.Helpers
      alias ExdHTML.{Parser, Crawler}

      defhelper {:html_crawl, url}, do: Crawler.crawl(url)
      defhelper {:html_crawl, url, opts}, do: Crawler.crawl(url, opts)
      defhelper {:html_parse, string}, do: Parser.parse_document(string)
      defhelper {:html_parse_list, node, selector}, do: Parser.parse_list(node, selector)
      defhelper {:html_parse_text, node, selector}, do: Parser.parse_text(node, selector)

    end
  end
end
