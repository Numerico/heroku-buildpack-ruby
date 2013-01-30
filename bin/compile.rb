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
texlivehome=bdir+"/.texlive"
texlivecache=cdir+"/.texlive"
path=texlivehome+"/bin/x86_64-linux"
profiled=bdir+"/.profile.d/texlive.sh"
# Prepare the various paths TODO if not exist
Dir.mkdir(texlivehome, 0777)
Dir.mkdir(texlivecache, 0777)
Dir.mkdir(File.dirname(profiled), 0777)
#
if File.exist?(texlivecache+"/"+version) and version == `cat #{texlivecache}/#{version}` then
  puts "Installing TeX Live #{version} from cache"
  #cp -R $TEXLIVE_CACHE/* $TEXLIVE_HOME
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
  `tar xzf -C #{texlivehome}`
  
  
  # Make sure the cache is empty
  #rm -rf $TEXLIVE_CACHE/*
  # Store a copy of it in the cache so it doesn't have to be fetched again
  #cp -R $TEXLIVE_HOME/* $TEXLIVE_CACHE
  # Store the version for later
  #echo $VERSION > $TEXLIVE_CACHE/VERSION
  
  
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