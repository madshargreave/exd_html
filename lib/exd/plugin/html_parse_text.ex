defmodule Exd.Plugin.HTMLParseText do
  @moduledoc """

  """
  use Exd.UDF

  @impl true
  def name do
    :html_parse_text
  end

  @impl true
  def eval([markup, selector]) do
    result = ExdHTML.Parser.parse_text(markup, selector)
    {:ok, result}
  end

end
