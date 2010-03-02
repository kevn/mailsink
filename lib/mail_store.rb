require 'message'
require 'mail'
class MailStore
  
  attr_reader :db, :maildir
  
  def initialize(opts)
    ActiveRecord::Base.establish_connection(opts[:db])
    ActiveRecord::Base.logger = opts[:logger] || Logger.new(STDOUT)
    @maildir = opts[:maildir]
    FileUtils.mkdir_p @maildir
    Message.init_db
  end
  
  def sync!
    files.each do |f|
      unless Message.find_by_source(f)
        Message.create!(:source => f, :raw => File.read(file_from_id(f)))
      end
    end
    # Message.delete_all('source not in (?)', files)
    self
  end
  
  def find_mail_by_id(id)
    Message.find_by_id(id)
  end
  
  def all(opts = {})
    Message.all(opts)
  end
  
  def files
    Dir.glob("#{maildir}/*").map{|f| File.basename(f) }
  end
  
  def file_from_id(id)
    File.join(maildir, id.to_s)
  end
  
end
