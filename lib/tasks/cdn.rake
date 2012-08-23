require 'cloudfiles'
require 'mime/types'
require 'constants'




# encoding: utf-8
require 'rubygems'
require 'cloudfiles'
require 'mime/types'
require 'find'
require 'colored'

desc "refresh precompiled assets in the rackspace CloudFiles CDN"
task :asset_sync do

  
    cf = CloudFiles::Connection.new(
  :username => RACK_USER,
  :api_key => RACK_API
)
    asset_container = cf.container(RACK_FILES);

    pub_dir = Rails.root.join("public/")

    # Get File Lists
    cdn_files = asset_container.objects
    local_files = Find.find(pub_dir.join('assets')).map { |i| i }
    local_files[0] = pub_dir.join('assets').to_s

    to_delete = cdn_files.reject { |i| local_files.include?(pub_dir.join(i).to_s)}
    to_upload = local_files.reject { |i| cdn_files.include?(i[pub_dir.to_s.length..-1]) }

    #delete files that no longer exist
    to_delete.each do |f|
        if asset_container.delete_object(f)
            #puts "    ☓".red + " Deleted   -> " + f
        end
    end

    #upload fresh assets
    to_upload.each do |f|
        unless FileTest.directory?(f) # ignore directories
            relative_path = f[pub_dir.to_s.length..-1]
            #puts "    ↑".green + " Uploading -> " + relative_path
            file = open(f)
            types = MIME::Types.type_for(f)
            object = asset_container.create_object relative_path, true
            object.write file
            object.content_type = types[0].to_s
            file.close
        end
    end

    puts "    Deleted " + to_delete.size.to_s + " file(s)"
    puts "    Uploaded " + to_upload.size.to_s + " file(s)"

end

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