class SentryProject < ApplicationRecord
  belongs_to :sentry_installation,
            foreign_key: :installation_id,
            primary_key: :installation_id
  has_many :sentry_events,
           foreign_key: :project_id,
           primary_key: :project_id,
           dependent: :destroy
end
