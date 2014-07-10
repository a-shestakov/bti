class TransformController < ApplicationController
  def all
    points = []
    trams_xml = get_trams_kml
    stop_names = get_stops.map { |stop| stop[:stop_name] }
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
    kml = get_trams_kml
    stops = get_stops

    unfilled_stop_names = stops.select { |stop| stop[:who].to_s == '' }.map { |stop| stop[:stop_name] }

    all_kml_point_names = []
    kml.css('Placemark').each do |placemark|
      name = placemark.css('name').text.strip
      if unfilled_stop_names.include?(name)
        (lon, lat, elevation) = placemark.at_css('coordinates').text.split(',')
        @points.push({lat: lat, lon: lon, name: name})
      end
      all_kml_point_names.push(name)
    end

    @unfilled_not_on_map = (unfilled_stop_names - all_kml_point_names)
    @points_json = @points.to_json
  end

  def redirect_to_ettu
    require 'open-uri'
    target_name = URI::decode(params[:name])
    letter_doc = Nokogiri::HTML(open("http://mobile.ettu.ru/stations/" + URI::encode(target_name[0])), nil, 'UTF-8')
    links = letter_doc.xpath('//a')
    links.each do |link|
      if link.content == target_name
        redirect_to('http://mobile.ettu.ru' + link['href'])
        return
      end
    end
    render text: 'ok'
  end

  private

  def get_trams_kml
    f = File.open(File.join(Rails.root, 'lib', 'assets', 'trams.xml'))
    doc = Nokogiri::XML(f)
    f.close
    doc
  end

  def get_stops
    book = Spreadsheet.open File.join(Rails.root, 'lib', 'assets', 'BTI_bigdata_2.xls')
    book.worksheet(0).drop(3).map do |row|
      {stop_name: row[1].to_s.strip, who: row[24].to_s.strip}
    end
  end
end
