module Refinery
  module Blog
    include ActiveSupport::Configurable

    config_accessor :per_page, :per_admin_page,
                    :sharing_service, :comment_service

    self.per_page = 20
    self.per_admin_page = 20

  end
end
