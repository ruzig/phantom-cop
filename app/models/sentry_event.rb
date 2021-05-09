class SentryEvent < ApplicationRecord
  belongs_to :sentry_project,
             foreign_key: :project_id,
             primary_key: :project_id
end
