$LOAD_PATH.unshift File.join(File.dirname(__FILE__), *%w(lib))

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
require 'mail_store'

DB_PATH = File.dirname(__FILE__)
DB_FILE = DB_PATH + '/mail.db'
MAILDIR_PATH = File.dirname(__FILE__) + '/maildir'

$mail_store = MailStore.new(
  :maildir => MAILDIR_PATH,
  :db => {:adapter => 'sqlite3', :database => DB_FILE }
)

set :views, File.dirname(__FILE__) + '/templates'

helpers do
  def mail_link(text, id)
    %(<a href="/mail/#{ URI.escape(id.to_s) }">#{ h(text) }</a>)
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
  @mails = $mail_store.sync!.all(:order => 'date_sent desc')
  erb :index
end

get '/mail/:id' do
  @mail = $mail_store.find_mail_by_id(params[:id])
  erb :mail
end
