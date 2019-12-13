defmodule Weaver.Twitter.Client do
  @callback favorites(integer(), integer() | nil) :: list()
end
