class AuthorityLookup
  cattr_accessor :authorities

  def self.find_snac_from_slug(slug)
    area = Frontend.mapit_api.area_for_code("govuk_slug", slug)
    puts "====================="
    puts area
    pp area['codes']
    puts "====================="
    area['codes']['ons']
  rescue GdsApi::HTTPNotFound
    nil
  end
end
