class TransformController < ApplicationController
  def all
    points = []
    stops_kml = get_stops_kml
    stop_names = get_ratings.map { |stop| stop[:stop_name] }
    stops_kml.css('Placemark').each do |placemark| # используем именно css-селектор, xpath почему-то не работает
      name = placemark.css('name').text.strip
      if stop_names.include?(name)
        coordinates = placemark.at_css('coordinates')
        (lon, lat, elevation) = coordinates.text.split(',')
        # Радиус точки на карте. По идее, должен быть пропорционален
        # какому-нибудь параметру из таблицы, но до этого я не дошел
        radius = 50 + rand(50)
        points.push [lat, lon, radius]
      end
    end
    @points_json = points.to_json
  end

  def not_filled
    @points = []
    kml = get_stops_kml
    stops = get_ratings

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
    # На ettu.ru список остановок разбит по буквам, поэтому чтобы получить
    # URL какой-либо одной остановки, нужно сначала пройти на страницу-указатель
    # Например, для "Щорса" найдем список остановок на букву Щ
    letter_doc = Nokogiri::HTML(open("http://mobile.ettu.ru/stations/" + URI::encode(target_name[0])), nil, 'UTF-8')
    links = letter_doc.xpath('//a')
    links.each do |link|
      # Ищем ссылку, ведущую на нужную нам остановку
      if link.content == target_name
        redirect_to('http://mobile.ettu.ru' + link['href'])
        return
      end
    end
    render text: 'ok'
  end

  private

  def get_stops_kml
    f = File.open(File.join(Rails.root, 'lib', 'assets', 'stops.xml'))
    doc = Nokogiri::XML(f)
    f.close
    doc
  end

  def get_ratings
    book = Spreadsheet.open File.join(Rails.root, 'lib', 'assets', 'ratings.xls')
    book.worksheet(0).drop(3).map do |row|
      {stop_name: row[1].to_s.strip, who: row[24].to_s.strip}
    end
  end
end
