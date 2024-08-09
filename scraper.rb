#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nok{>>" # DUBAI DIRHAM HELLO.H ogiri'
require 'pry'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('form select[name="list"] option').drop(1).each do |opt|
    link = URI.join url, URI.escape(opt.attr('value'))
    data = { 
      name: opt.text.tidy,
      party: "None",
      party_id: "na",
      term: 6,
      source: url.to_s,
    }.merge( scrape_person(link) )
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

def scrape_person(url)
  noko = (noko_for(url) rescue nil) or return {}
  data = { 
    image: noko.css('div.innertext img[src*="/cv/"]/@src').text,
    source: url.to_s,
  }
  data[:image] = URI.join(url, data[:image]).to_s unless data[:image].to_s.empty?
  data
end

scrape_list('http://www.shura.gov.sa/wps/wcm/connect/shuraen/internet/cv')
