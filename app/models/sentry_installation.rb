class SentryInstallation < ApplicationRecord
  has_many :sentry_projects,
           foreign_key: :installation_id,
           primary_key: :installation_id,
           dependent: :destroy
end
