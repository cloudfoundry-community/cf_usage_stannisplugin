require 'action_view'

class Stannis::Plugin::AwsSnapshots::Volumes::SnapshotStatus
  include ActionView::Helpers::DateHelper

  def initialize(fog_compute)
    @fog_compute = fog_compute
  end

  def stannis_snapshot_data(description_regexp)
    snapshot = @fog_compute.snapshots.
      select {|s| s.description =~ description_regexp }.
      sort {|s1, s2| s1.created_at <=> s2.created_at}.last

    if snapshot
      Stannis::Client::DeploymentData.new(
        "Volume snapshot #{snapshot.description}",
        "#{time_ago_in_words(snapshot.created_at)} ago"
      )
    else
      Stannis::Client::DeploymentData.new(
      "Volume snapshot #{description_regexp.inspect}", "missing", "down")
    end
  end
end
