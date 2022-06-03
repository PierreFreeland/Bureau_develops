module BureauConsultant
  module YoutubeVideoHelper
    def get_thumbnail_from_link(link)
      "https://img.youtube.com/vi/#{link}/1.jpg"
    end
  end
end