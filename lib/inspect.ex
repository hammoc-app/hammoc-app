defimpl Inspect, for: Weaver.Tree do
  import Inspect.Algebra

  def inspect(tree, opts) do
    ast =
      case tree.ast do
        {:document, _ast} -> [:document]
        ast -> ast |> Tuple.to_list() |> Enum.take(2)
      end

    concat([
      "#Weaver.Tree",
      to_doc(
        %{
          ast: ast ++ ["..."],
          data: tree.data,
          cursor: tree.cursor,
          count: tree.count,
          gap: tree.gap
        },
        opts
      )
    ])
  end
end

defimpl Inspect, for: ExTwitter.Model.Tweet do
  import Inspect.Algebra

  def inspect(tweet, opts) do
    concat(["#Tweet", to_doc(%{author: tweet.user.screen_name, text: tweet.full_text}, opts)])
  end
end

defimpl Inspect, for: ExTwitter.Model.User do
  import Inspect.Algebra

  def inspect(user, opts) do
    concat(["#User<", to_doc(user.screen_name, opts), ">"])
  end
end
