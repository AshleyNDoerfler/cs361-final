#!/usr/bin/env ruby

# Assembles track JSON
class Track

  attr_reader :points, :name

  def initialize(points, name=nil)
    @name = name
    segment_points = []
    points.each do |point_group|
      segment_points.append(TrackSegment.new(point_group))
    end

    @points = segment_points
  end

  # Creates and return a JSON string
  def to_json()
    json = '{' + '"type": "Feature", '

    if @name != nil
      json+= '"properties": {' + '"title": "' + @name + '"' + '},'
    end

    json += '"geometry": {' + '"type": "MultiLineString",' + '"coordinates": ['

    # Loop through all the segment objects
    @points.each_with_index do |s, index|
      if index > 0
        json += ","
      end

      json += '['
      
      # Loop through all the points in the segment
      points = ''
      s.coordinates.each do |c|

        if points != ''
          points += ','
        end

        # Add the coordinate
        points += '[' + "#{c.get_lon()},#{c.get_lat()}"

        if c.elevation != nil
          points += ",#{c.get_elevation()}"
        end

        points += ']'
      end

      json += points + ']'
    end

    json + ']}}'
  end

end

# List of points
class TrackSegment

  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

end

# Latitude/longitude pair with optional elevation
class Point

  attr_reader :lat, :lon, :elevation

  def initialize(lon, lat, elevation=nil)
    @lon = lon
    @lat = lat
    @elevation = elevation
  end

  def get_lat
    return @lat
  end

  def get_lon
    return @lon
  end

  def get_elevation
    return @elevation
  end

end

# Point of latitude/longitude pairs with optional elevation, name, and type
class Waypoint < Point

attr_reader :name, :type

  def initialize(lon, lat, elevation=nil, name=nil, type=nil)
    super(lon, lat, elevation)
    @name = name
    @type = type
  end

  def get_name
    return @name
  end

  def get_type
    return @type
  end

  def to_json(indent=0)

    json = '{"type": "Feature",' + '"geometry": {"type": "Point","coordinates": ' + "[#{@lon},#{@lat}"

    if elevation != nil
      json += ",#{@elevation}"
    end

    json += ']},'

    # Add properties to the json if they exist
    if name != nil or type != nil
      json += '"properties": {'

      if name != nil
        json += '"title": "' + @name + '"'
      end

      if type != nil

        if name != nil
          json += ','
        end

        json += '"icon": "' + @type + '"'
      end

      json += '}'
    end

    json += "}"
    return json

  end

end

# Contains waypoints and points
class World

  attr_reader :name, :features

  def initialize(name, things)
    @name = name
    @features = things
  end

  def add_feature(f)
    @features.append(t)
  end

  # Creates and return a GeoJSON string
  def to_geojson(indent=0)

    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end

        if f.class == Track
            s += f.to_json
        elsif f.class == Waypoint
            s += f.to_json
        end

    end

    s + "]}"
  end

end

def main()

  waypoint_1 = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  waypoint_2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")

  # Create track segments for tracks
  track_segment_1 = [
    Point.new(-122, 45),
    Point.new(-122, 46),
    Point.new(-121, 46),
  ]

  track_segment_2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  track_segment_3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  track_1 = Track.new([track_segment_1, track_segment_2], "track 1")
  track_2 = Track.new([track_segment_3], "track 2")

  world = World.new("My Data", [waypoint_1, waypoint_2, track_1, track_2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

