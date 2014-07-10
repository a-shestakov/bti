class TransformController < ApplicationController
  def all
    points = []
    trams_xml = get_trams_xml
    stop_names = get_stops.map{|stop| stop[:stop_name]}
    trams_xml.css('Placemark').each do |placemark|
      name = placemark.css('name').text.strip
      if stop_names.include?(name)
        coordinates = placemark.at_css('coordinates')
        (lon, lat, elevation) = coordinates.text.split(',')
        points.push [lat, lon, 50 + rand(50)]
      end
    end
    @points_json = points.to_json
  end

  def not_filled
    @points = []
    trams_xml = get_trams_xml
    stops = get_stops
    puts stops
    stop_names = stops.select{|stop| stop[:who].to_s == '' }.map{|stop| stop[:stop_name]}
    trams_xml.css('Placemark').each do |placemark|
      name = placemark.css('name').text.strip
      if stop_names.include?(name)
        coordinates = placemark.at_css('coordinates')
        (lon, lat, elevation) = coordinates.text.split(',')
        @points.push({lat: lat, lon: lon, name: name})
      end
    end
    @points_json = @points.to_json
  end

  private

  def get_trams_xml
    f = File.open(File.join(Rails.root, 'lib', 'assets', 'trams.xml'))
    doc = Nokogiri::XML(f)
    f.close
    doc
  end

  def get_stops
    book = Spreadsheet.open File.join(Rails.root, 'lib', 'assets', 'BTI_bigdata_2.xls')
    book.worksheet(0).map do |row|
      {stop_name: row[1].to_s.strip, who: row[24].to_s.strip}
    end
  end
end
