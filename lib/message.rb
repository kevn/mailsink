require 'active_record'
require 'mail'
require 'delegate'
class Message < ActiveRecord::Base
  
  attr_accessible :source, :raw
  
  validates_presence_of :source, :raw, :on => :create
  before_create :extract_email_fields
  
  delegate :header_fields, :multipart?, :parts, :to => :parsed_mail
  
  def parsed_mail
    @parsed_mail ||= Mail.new(raw)
  end
  
  def extract_email_fields
    self.in_reply_to    = parsed_mail.in_reply_to,
    self.sender         = parsed_mail.sender,
    self.subject_prefix = parsed_mail.subject.split(':',2).first,
    self.subject        = parsed_mail.subject,
    self.date_sent      = parsed_mail.date.to_time.to_i,
    # self.date_received  = parsed_mail.date_received.to_i,
    # self.date_created   = parsed_mail.date_created,
    self.size           = raw.size
  end

  def self.init_db
    connection.execute <<-SQL
      CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source,
        raw BLOB,
        in_reply_to,
        sender,
        subject_prefix,
        subject,
        date_sent INTEGER,
        date_received INTEGER,
        date_created INTEGER,
        size INTEGER
      );
    SQL
  end

end
