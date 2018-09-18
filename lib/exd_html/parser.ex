defmodule ExdHTML.Parser do
  @moduledoc false

  @doc """
  Parse entire document as HTML
  """
  @spec parse_document(binary()) :: ExdHTML.html_node()
  def parse_document(string) do
    [
      Floki.parse(string)
    ]
  end

  @doc """
  Parse a list of nodes
  """
  @spec parse_list(ExdHTML.html_node(), ExdHTML.selector()) :: [ExdHTML.html_node()]
  def parse_list(node, selector) when is_binary(node), do: parse_list(Floki.parse(node), selector)
  def parse_list(node, selector) do
    node
    |> Floki.find(selector)
  end

  @doc """
  Parse and extract the text of a node
  """
  @spec parse_text(ExdHTML.html_node(), ExdHTML.selector()) :: binary()
  def parse_text(node, selector) do
    node
    |> Floki.find(selector)
    |> Floki.text
    |> String.trim
  end

end
