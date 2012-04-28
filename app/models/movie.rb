class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end

  def self.get_directors_movies(id)
    if not id
      nil
    else
      m = Movie.find(id)
      director = m.director
      if director and director != ""
        Movie.where(%Q{
            director = (?) and id not in (?)},
            director, [id])
      else
        nil
      end
    end
  end
end
