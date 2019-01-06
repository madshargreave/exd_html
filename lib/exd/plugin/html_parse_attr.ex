defmodule Exd.Plugin.HTMLParseAttr do
  @moduledoc """

  """
  use Exd.UDF

  @impl true
  def name do
    :html_parse_attr
  end

  @impl true
  def eval([markup, attr, selector]) do
    result = ExdHTML.Parser.parse_attr(markup, attr, selector)
    {:ok, result}
  end

end
