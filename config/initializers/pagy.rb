# config/initializers/pagy.rb
require 'pagy/extras/overflow'

Pagy::DEFAULT[:items] = 12
Pagy::DEFAULT[:overflow] = :last_page

# Include Pagy in controllers
ActiveSupport.on_load(:action_controller_api) do
  include Pagy::Backend
end