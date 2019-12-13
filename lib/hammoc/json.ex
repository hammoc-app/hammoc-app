require Protocol

Protocol.derive(Jason.Encoder, ExTwitter.Model.Tweet)
Protocol.derive(Jason.Encoder, ExTwitter.Model.User)
