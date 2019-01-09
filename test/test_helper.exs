ExUnit.start()

sandbox = Application.get_env(:hammoc, Hammoc.Repo)[:pool]
sandbox.mode(Hammoc.Repo, :manual)
