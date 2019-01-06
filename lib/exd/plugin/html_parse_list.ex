defmodule Exd.Plugin.HTMLParseList do
  @moduledoc """

  """
  use Exd.UDF

  @impl true
  def name do
    :html_parse_list
  end

  @impl true
  def eval([markup, selector]) do
    result = ExdHTML.Parser.parse_list(markup, selector)
    {:ok, result}
  end

end
