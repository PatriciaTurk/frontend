class LicenceDetailsPresenter
  attr_reader :licence, :authority_slug, :interaction

  def initialize(licence, authority_slug = nil, interaction = nil)
    @licence = licence
    @authority_slug = authority_slug
    @interaction = interaction
  end

  def present?
    licence.present?
  end

  def local_authority_specific?
    licence_details["location_specific"]
  end

  def licence_authority_specific?
    !licence_details["location_specific"]
  end

  def has_any_actions?
    # puts "=========== in has_any_actions"
    # puts "authority ===> #{authority.inspect}"
    authority && authority["actions"].present?
  end

  def uses_licensify(chosen_action = action)
    return false unless authority

    chosen_action_info = authority.dig("actions", chosen_action)
    if chosen_action_info.present?
      chosen_action_info.any? { |link| link && link['uses_licensify'] }
    else
      false
    end
  end

  def uses_authority_url(chosen_action = action)
    return false unless authority

    chosen_action_info = authority.dig("actions", chosen_action)
    if chosen_action_info.present?
      chosen_action_info.any? { |link| link && link['uses_authority_url'] }
    else
      false
    end
  end

  def action
    return nil unless interaction
    raise RecordNotFound unless authority["actions"].key?(interaction)

    interaction
  end

  def offered_by_county?
    licence_details["is_offered_by_county"]
  end

  def single_licence_authority_present?
    licence_authority_specific? && authority
  end

  def multiple_licence_authorities_present?
    licence_authority_specific? && authorities.size > 1
  end

  def authorities
    authorities_from_api_response
  end

  def authority
    # puts "the authority slug is ===> #{authority_slug}"
    # puts "========================="
    # puts "authorities #{authorities}"
    # puts "========================="
    if authority_slug
      authorities.detect { |a| a["slug"] == authority_slug }
    elsif authorities.size == 1
      authorities_from_api_response.first
    elsif authorities.size > 1 && local_authority_specific?
      authorities_from_api_response.first
    end
  end

private

  def licence_details
    return {} unless licence

    {
      "location_specific" => licence["isLocationSpecific"],
      "is_offered_by_county" => licence["isOfferedByCounty"],
      "availability" => licence["geographicalAvailability"],
      "authorities" => authorities_from_api_response,
    }
  end

  def authorities_from_api_response
    if licence && licence['issuingAuthorities']
      licence['issuingAuthorities'].map { |authority|
        {
          'name' => authority['authorityName'],
          'slug' => authority['authoritySlug'],
          'contact' => authority['authorityContact'],
          'actions' => authority['authorityInteractions'].inject({}) { |actions, (key, links)|
            actions[key] = links.map { |link|
              {
                'url' => link['url'],
                'introduction' => link['introductionText'],
                'description' => link['description'],
                'payment' => link['payment'],
                'uses_authority_url' => (link['usesAuthorityUrl'] == true),
                'uses_licensify' => (link['usesLicensify'] == true)
              }
            }
            actions
          }
        }
      }
    else
      []
    end
  end
end
