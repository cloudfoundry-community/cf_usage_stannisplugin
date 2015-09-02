require 'action_view'

class Stannis::Plugin::AwsSnapshots::RDS::SnapshotStatus
  include ActionView::Helpers::DateHelper
  def initialize(fog_rds, instance_id)
    @fog_rds = fog_rds
    @instance_id = instance_id
  end

  def latest_snapshot
    @fog_rds.snapshots.all(identifier: @instance_id).
      sort {|s1, s2| s1.created_at <=> s2.created_at}.last
  end

  def stannis_data(snapshot)
    if snapshot
      Stannis::Client::DeploymentData.new(
        "RDS snapshot #{@instance_id}",
        "#{time_ago_in_words(snapshot.created_at)} ago"
      )
    else
      Stannis::Client::DeploymentData.new(
      "RDS snapshot #{@instance_id}", "missing", "down")
    end
  end
end
