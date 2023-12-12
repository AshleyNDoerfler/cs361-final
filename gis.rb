#!/usr/bin/env ruby

# List of Track segments
class Track

  attr_reader :segments, :segment_objects, :name

  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |s|
      segment_objects.append(TrackSegment.new(s))
    end

    @segments = segment_objects
  end


  def get_track_json()
    j = '{'
    j += '"type": "Feature", '
    if @name != nil
      j+= '"properties": {'
      j += '"title": "' + @name + '"'
      j += '},'
    end
    j += '"geometry": {'
    j += '"type": "MultiLineString",'
    j += '"coordinates": ['

    # Loop through all the segment objects
    @segments.each_with_index do |s, index|
      if index > 0
        j += ","
      end

      j += '['

      # Loop through all the coordinates in the segment
      tsj = ''
      s.coordinates.each do |c|

        if tsj != ''
          tsj += ','
        end

        # Add the coordinate
        tsj += '['
        tsj += "#{c.lon},#{c.lat}"

        if c.elevation != nil
          tsj += ",#{c.elevation}"
        end

        tsj += ']'
      end

      j+=tsj
      j+=']'
    end

    j + ']}}'
  end

end

# list of latitude/longitude pairs with optional elevation
class TrackSegment

  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

end

# latitude/longitude pair with optional elevation
class Point

  attr_reader :lat, :lon, :elevation

  def initialize(lon, lat, elevation=nil)
    @lon = lon
    @lat = lat
    @elevation = elevation
  end

end

# point of latitude/longitude pairs with optional elevation, name, and type
class Waypoint

attr_reader :lat, :lon, :elevation, :name, :type

  def initialize(lon, lat, elevation=nil, name=nil, type=nil)
    @lat = lat
    @lon = lon
    @elevation = elevation
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)

    j = '{"type": "Feature",'

    j += '"geometry": {"type": "Point","coordinates": '
    j += "[#{@lon},#{@lat}"

    if elevation != nil
      j += ",#{@elevation}"
    end

    j += ']},'

    # Add properties to the json if they exist
    if name != nil or type != nil
      j += '"properties": {'

      if name != nil
        j += '"title": "' + @name + '"'
      end

      if type != nil

        if name != nil
          j += ','
        end

        j += '"icon": "' + @type + '"'
      end

      j += '}'
    end

    j += "}"
    return j

  end

end

# Contains waypoints and tracks
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
            s += f.get_track_json
        elsif f.class == Waypoint
            s += f.get_waypoint_json
        end

    end

    s + "]}"
  end

end

def main()

  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")

  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  t = Track.new([ts1, ts2], "track 1")
  t2 = Track.new([ts3], "track 2")

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

