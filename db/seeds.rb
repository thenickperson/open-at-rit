# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'nokogiri'
require 'open-uri'
require 'yaml'

# Based off of https://gist.github.com/toroidal-code/6235807

module LocationScraper
  HOURS_PAGE = 'http://www.rit.edu/fa/diningservices/content/hours-operation'

  def self.scrape
    doc = Nokogiri.HTML open HOURS_PAGE
    # doc.css('.field-item h3').map{ |location| location.content.strip }
    doc.css('h3 a').map do |node|
      if node.content == '' && node['id'] == node['name']
        title = node.next.to_s
        new_node = {
          # Prototype regex for matching locations and descriptions:
          # /(.+)\s+\(([^()]+)\)\s*/
          'name' => title.match(/\s*([^() ][^()]+[^() ])\s*/).captures.first,
          'hours' => {}
        }

        table =  next_node_with(node.parent, :name, 'table')
        rows =  table.search('tr')[1..-1]
        rows.each do |row|
          results = row.search('td//text()').map { |text|  text.to_s.strip }
          new_node['hours'][results.first] = results[1..-1]
        end

        new_node
      end
    end.compact
  end

  private

  def self.next_node_with(current, attribute, cond)
    current = current.next while current && current.send(attribute) != cond
    current
  end
end

locations = LocationScraper.scrape
puts locations.to_yaml
# Location.create! locations
