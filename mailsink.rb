require 'rubygems'
begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

require 'sinatra'
require 'mail'

MAILDIR_PATH = File.dirname(__FILE__) + '/maildir'

FileUtils.mkdir_p MAILDIR_PATH

set :views, File.dirname(__FILE__) + '/templates'

helpers do
  def mail_link(text, id)
    %(<a href="/mail/#{ URI.escape(id) }">#{ h(text) }</a>)
  end
  
  def email_body(body, content_type)
    case content_type
    when %r{text/plain}
      partial :plain_message_body, :locals => {:body => body}
    when %r{text/html}
      partial :html_message_body, :locals => {:body => body}
    else
      "(Not rendering #{content_type} email part)"
    end
  end
  
  def partial(*args)
    if args.last.is_a?(Hash)
      args.last.merge!(:layout => false)
    else
      args << {:layout => false}
    end
    erb(*args)
  end
  
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @files = Dir.glob("#{MAILDIR_PATH}/*").map{|f| File.basename(f)}.sort.reverse
  erb :index
end

get '/mail/:id' do
  @mail = Mail.read(MAILDIR_PATH + '/' + params[:id])
  erb :mail
end
