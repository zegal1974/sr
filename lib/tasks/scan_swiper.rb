require "nokogiri"
require "open-uri"
require "cgi"
require "json"
require "faraday"

CHR_LIST_URL = "https://bbs.mihoyo.com/sr/wiki/channel/map/17/18"

def get_characters
  doc = Nokogiri::HTML(URI.open(CHR_LIST_URL))
  scan_characters doc
end

def scan_characters(doc)
  characters = []
  doc.search(".large-model-card").each do |c|
    # ['data-src']
    link = c.search("a").first["src"]
    icon = c.search("large-model-card__icon").first["data-src"]
    name = c.search(".large-model-card__name").first.content.strip
    character = get_character link
    character["icon"] = icon
    character["name"] = name
    characters << character
  end
  characters
end

def get_character(link)
  doc = Nokogiri::HTML(URI.open(CHR_LIST_URL))
  p doc
  character = scan_character doc
end

def scan_character(doc)
  character = {}
  p doc.search(".obc-tmp-character__box .name").first

  properties = doc.search(".obc-tmp-character__property .obc-tmp-character__wrap .obc-tmp-character__item .obc-tmp-character__value")
  p properties
  if !(properties.nil? or properties.empty?)
    character["category"] = properties[0].content.strip
    character["property"] = properties[1].content.strip
    character["faction"] = properties[2].content.strip
    character["region"] = properties[3].content.strip
  end

  character["level-titles"] = doc.search(".obc-tmpl__switch-btn-list li.obc-tmpl__switch-btn").map { |li| li.content.strip }
  character["level-properties"] = []
  levels = doc.search(".obc-tmpl__switch-list .obc-tmpl__switch-item table").each do |table|
    properties = {}
    table.search("tr td.h3").each do |h|
      key = h.content.strip
      value = h.next.search('.obc-tmpl__icon-text-num .class="obc-tmpl__icon-text"').content.strip
      properties[key] = value
    end
    character["level-properties"] << properties
  end
  character
end

# p get_character "https://bbs.mihoyo.com/sr/wiki/content/317/detail?bbs_presentation_style=no_header"

CHR_JSON_URL = "https://api-static.mihoyo.com/common/blackboard/sr_wiki/v1/content/info?app_sn=sr_wiki&content_id="

def get_character_json(id)
  path = CHR_LIST_URL + "#{id}"
  # URI.open(, redirect: false) do |f|
  #   json = JSON.parse(f.read)
  #   p json.message
  # end
  response = Faraday.get(path, headers: { "Content-Type" => "application/json" })
  p response.body
  #
  #
end

p get_character_json 317
