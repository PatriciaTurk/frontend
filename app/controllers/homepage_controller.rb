class HomepageController < ApplicationController
  before_action :set_expiry

  def index
    set_slimmer_headers(
      template: "homepage",
      remove_search: true,
    )

    setup_content_item("/")

    @homepage = HomepagePresenter.new
    render locals: { full_width: true }
  end
end
