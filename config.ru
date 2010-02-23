require "mailsink"

Sinatra::Application.default_options.merge!(
  :run => false
)
run Sinatra::Application

