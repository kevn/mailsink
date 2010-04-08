require "mailsink"

Sinatra::Base.set(:run, false)
run Sinatra::Application

