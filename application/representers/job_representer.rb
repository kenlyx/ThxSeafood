# frozen_string_literal: true

# Represents essential Collaborator information for API output
# USAGE:
#   collab = Repository::Collaborators.find_id(1)
#   CollaboratorRepresenter.new(collab).to_json
module ThxSeafood
  class JobRepresenter < Roar::Decorator
    include Roar::JSON

    property :name
    property :link
    property :company
    property :address
    property :addr_no_descript
    # property :description
    property :user_query
    property :lng
    property :lat
  end
end