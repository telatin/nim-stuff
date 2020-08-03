import jester

routes:
  get "/":
    resp "This is awesome!"
  post "/":
    resp "Form received, thanks"

  get "/login":
    resp ""
  post "/hello/@user":
    resp "Hello, " & @"user"

