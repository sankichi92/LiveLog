module Api::V1::ApplicationHelper
  include Api::V1::TokensHelper
  include SongsHelper # To include `sort_by_inst`, which is used in SongsController#show
end
