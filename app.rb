# vim: set softtabstop=2 shiftwidth=2 expandtab :
# (c) 2012 KissCool

require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'open-uri'
require 'hpricot'
require 'base64'
require File.join(File.dirname(__FILE__), './threadpool.rb')

# IMDB movie IDs
MOVIES_RAW = '1336006 1462758 1680138 0071853 1618372 1653913 0089469 0093779 0780645 1650042 1411232 1855232 1524134 2005164 0368226 0418819 1500906 1362058 2396429 1438176 1525366 1783732 0100258 1931533 1606339 0096256 2170584'
MOVIES = MOVIES_RAW.split

# entry point
class App < Sinatra::Base
  before do
    content_type :html, 'charset' => 'utf-8'
  end

  ############ Indexes
  #
  get '/' do
    @program = {}
    # This *is* very very dirty, don't do this at home kids
    # This makes us dependent of those webservers that permit the use of threads
    # in the ruby app
    pool = ThreadPool.new(5)
    MOVIES.each do |value|
      pool.dispatch(value) do |value|
        url = "http://www.imdb.com/title/tt#{value}"
        doc = Hpricot(open(URI.escape(url)))
        #name = (doc/"//meta[@name='title']").first['content']
        #img = (doc/"//td[@id='img_primary']"/"//img[@itemprop='image']").first.to_html
        stats = (doc/"//div[@id='title-overview-widget']"/"//td[@id='overview-top']").first.to_html
        css = (doc/"//link[@rel='stylesheet']").to_html
        # Another dirty trick
        # I do not want to babysit a temporary file cache, so I grab pictures,
        # directory encode them in base64 and serve them from the base64 string
        # option a for a small thumbnail
        #image_src = (doc/"//link[@rel='image_src']").first['href']
        #img_base64 = Base64.encode64(open(image_src).string)
        # option b for a large picture
        image_src = (doc/"//td[@id='img_primary']"/"//img[@itemprop='image']")
        if image_src.nil? or image_src.count == 0
          img_base64=''
        else
          img_base64 = Base64.encode64(open(image_src.first['src']).to_a.join)
        end

        #url_img = "http://www.movieposterdb.com/movie/#{value}/"
        #doc_img = Hpricot(open(URI.escape(url_img)))
        #img_tag = (doc_img/"//td[@class='poster']"/"//img")
        #if img_tag.nil? or img_tag.count == 0
        #  img=''
        #else
        #  img = img_tag.first['data-original']
        #end

        @program[value] = {
          'url'   => url,
          'stats' => stats,
          'css'   => css,
          'img'   => img_base64
        }
      end
    end
    pool.shutdown
    haml :index
  end

end 
