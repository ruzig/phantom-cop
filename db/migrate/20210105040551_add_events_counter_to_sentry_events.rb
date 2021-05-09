class AddEventsCounterToSentryEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :sentry_events, :events_counter, :integer, default: 0
  end
end
