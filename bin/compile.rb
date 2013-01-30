#!/usr/bin/env ruby

require 'net/https'
require 'open-uri'
require 'zlib'

# sync output
$stdout.sync = true

bdir=ARGV[0]
cdir=ARGV[1]
bind=Dir.pwd
#
texlivehome=bdir+"/.texlive"
texlivecache=cdir+"/.texlive"
path=texlivehome+"/bin/x86_64-linux"
profiled=bdir+"/.profile.d/texlive.sh"
# Prepare the various paths TODO if not exist
if not File.exists?(texlivehome)
Dir.mkdir(texlivehome, 0777)
end
if not File.exists?(texlivecache)
Dir.mkdir(texlivecache, 0777)
end
if not File.exists?(File.dirname(profiled))
Dir.mkdir(File.dirname(profiled), 0777)
end
#
texlivedomain="heroku-buildpack-tex.s3.amazonaws.com"
#
http = Net::HTTP.new(texlivedomain, 443)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#version=`curl #{texlivedomain}/VERSION -s`
File.open('main/VERSION', 'w') {|f|
  http.get('/VERSION') do |str|
    f.write str
  end
}
version=File.read('main/VERSION')
puts "TexLive v."+version

#
texliveurl="#{texlivedomain}/texlive-#{version}.tar.gz"
#
if File.exist?(texlivecache+"/"+version) then
  oldversion=File.read('#{texlivecache}/#{version}')
  if version == oldversion then
    puts "Installing TeX Live #{version} from cache"
  end
  #cp -R $TEXLIVE_CACHE/* $TEXLIVE_HOME TODO
else
  if File.exist?(texlivecache+"/"+version) then
    puts "Upgrading to TeX Live #{version}"
  else
    puts "Fetching TeX Live #{version}"
  end
  
  #curl $TEXLIVE_URL -s -o - | tar xzf - -C $TEXLIVE_HOME
  open('main/tarball.tar', 'w') do |local_file|
    open("https://"+texliveurl) do |remote_file|
      local_file.write(Zlib::GzipReader.new(remote_file).read)
    end
  end
  #tar
  puts "texlivehome "+texlivehome.to_s
  system("tar xf main/tarball.tar -C ./#{texlivehome}")
  
  # Make sure the cache is empty
  #rm -rf $TEXLIVE_CACHE/*
  # Store a copy of it in the cache so it doesn't have to be fetched again
  #cp -R $TEXLIVE_HOME/* $TEXLIVE_CACHE
  # Store the version for later
  #echo $VERSION > $TEXLIVE_CACHE/VERSION
  File.open(texlivecache+"/VERSION", 'w') {|f| f.write(version) }
  
end


##########################
# comandante = Thread.new do
	# system "./texcompile #{ARGV[0]} #{ARGV[1]}"
# end
# comandante.join                
# puts "q pahah tex"
# #system "./texcompile #{ARGV[0]} #{ARGV[1]}"
# 
# $:.unshift File.expand_path("../../lib", __FILE__)
# require "language_pack"
# 
# if pack = LanguagePack.detect(ARGV[0], ARGV[1])
  # pack.log("compile") do
    # pack.compile
  # end
# end