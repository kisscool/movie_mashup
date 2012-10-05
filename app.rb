# vim: set softtabstop=2 shiftwidth=2 expandtab :
# (c) 2012 KissCool

require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'open-uri'
require 'hpricot'

MOVIES_RAW = '1336006 1462758 1680138 0071853 1618372 1653913 0089469 0093779 0780645 1650042 1411232 1855232 2130142 1524134 2005164 1259521 0089885 1336608 0368226 1080767 0086567 0418819'
MOVIES = MOVIES_RAW.split

# entry point
class App < Sinatra::Base
  # some kind of magic
  before do
    content_type :html, 'charset' => 'utf-8'
  end

  ############ Indexes
  #
  get '/' do
    @program = {}
    MOVIES.each do |value|
      url = "http://www.imdb.com/title/tt#{value}"
      doc = Hpricot(open(URI.escape(url)))
      #name = (doc/"//meta[@name='title']").first['content']
      #image_src = (doc/"//link[@rel='image_src']").first['href']
      #img = (doc/"//td[@id='img_primary']"/"//img[@itemprop='image']").first.to_html
      stats = (doc/"//div[@id='title-overview-widget']"/"//td[@id='overview-top']").first.to_html
      css = (doc/"//link[@rel='stylesheet']").to_html

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
        'css'   => css
      }
    end
    haml :index
  end

  # this is the new shit, baby
  get '/stylesheet.css' do
    content_type 'text/css', :charset => 'utf-8'
    sass :stylesheet
  end

end 
