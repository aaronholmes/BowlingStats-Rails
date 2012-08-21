require 'cloudfiles' 
require 'mime/types'

cloudfiles_connection = CloudFiles::Connection.new(
  :username => ENV['RACK_USER'],
  :api_key => ENV['RACK_API']
)
cloudfiles_container = cloudfiles_connection.container(ENV['RACK_FILES'])

namespace :cdn do
  namespace :upload do
    desc "Upload all static assets"
    task :all => [:fonts, :images, :javascripts, :stylesheets, :third_party] do
    end

    desc "Upload font files to CDN"
    task :fonts do
      fonts = get_files('app/assets/fonts/**/*')
      fonts.each do |filename|
        headers = { 'Access-Control-Allow-Origin' =>  '*' }
        write_cloudfiles_file(cloudfiles_container, filename, headers)
      end
    end

    desc "Upload image files to CDN"
    task :images do
      assets = get_files('app/assets/images/**/*')
      assets.each { |filename| write_cloudfiles_file(cloudfiles_container, filename) }
    end

    desc "Upload javascript files to CDN"
    task :javascripts do
      assets = get_files('app/assets/javascripts/**/*')
      assets.each { |filename| write_cloudfiles_file(cloudfiles_container, filename) }
    end

    desc "Upload stylesheet files to CDN"
    task :stylesheets do
      assets = get_files('app/assets/stylesheets/**/*')
      assets.each { |filename| write_cloudfiles_file(cloudfiles_container, filename) }
    end

    desc "Upload third party files to CDN"
    task :third_party do
      assets = get_files('app/assets/jquery-ui/**/*', 'public/assets/jqzoom/**/*')
      assets.each { |filename| write_cloudfiles_file(cloudfiles_container, filename) }
    end
  end # :upload
end # :cdn

def write_cloudfiles_file(container, filename, headers = {}, check_md5 = true)
  type = MIME::Types.type_for(filename)
  type = type.empty? ? get_font_mime_type(filename) : type.first.content_type
  headers['Content-Type'] = type unless type.nil?
  name = cdn_file_path(filename)
  puts "Writing to CloudFiles: #{name} (#{type})"
  object = container.object_exists?(name) ? container.object(name) : container.create_object(name, true)
  object.load_from_filename(filename, headers, check_md5)
end

def get_files(*dir_names)
  assets = Array.new.tap do |ary|
    dir_names.each do |dir|
      Dir[dir].each do |file|
        next if File.ftype(file) == 'directory'
        ary << file
      end
    end
  end
  assets
end

def cdn_file_path(path)
  path.gsub(%r{^public/}, '')
end

def get_font_mime_type(filename)
  extname = File.extname(filename)
  case extname
  when '.ttf' then 'application/x-font-ttf'
  when '.otf' then 'application/x-opentype'
  when '.eot' then 'application/vnd.ms-fontobject'
  when '.woff' then 'application/x-font-woff'
  else
    nil
  end
end