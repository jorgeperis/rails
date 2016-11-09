require 'simplecov'
SimpleCov.start

require 'rails'
require 'yaml'
require 'active_record'
require 'globalize'
require 'globalize/active_record'
require 'globalize/active_record/migration'
require 'translation'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Schema.define do
  self.verbose = false

  [:posts, :articles].each do |table_name|
    create_table table_name, :force => true do |t|
      t.string     :title_fr
      t.string     :title_en
      t.string     :title_nl
      t.string     :content_fr
      t.string     :content_en
      t.string     :content_nl
      t.datetime   :published_at
      t.timestamps :null => false
    end
  end
end

class Post < ActiveRecord::Base
  translated_field :title
  translated_field :content
end

class Article < ActiveRecord::Base
  translates :title, :content
end

Article.create_translation_table! :title => :string, :content => :string

RSpec.configure do |config|
  config.before :each do
    Post.destroy_all
    Article.destroy_all

    TranslationIO.configure do |config|
      config.verbose                   = -1
      config.test                      = true
      config.source_locale             = :en
      config.target_locales            = []
      config.ignored_key_prefixes      = []
      config.localization_key_prefixes = []
      config.yaml_locales_path         = File.join('tmp', 'config', 'locales')
      config.metadata_path             = 'tmp/config/locales/.translation_io'
    end

    TranslationIO::Content.configure do |config|
      config.source_locale  = 'fr'
      config.target_locales = ['en', 'nl']
      config.storage        = :suffix
    end

    if File.exist?('tmp')
      FileUtils.rm_r('tmp')
    end

    FileUtils.mkdir_p('tmp')
  end
end
