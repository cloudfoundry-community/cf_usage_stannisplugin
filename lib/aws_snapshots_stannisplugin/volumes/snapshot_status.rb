require 'action_view'

class Stannis::Plugin::AwsSnapshots::Volumes::SnapshotStatus
  include ActionView::Helpers::DateHelper

  def initialize(fog_compute, description_regexp)
    @fog_compute = fog_compute
    @description_regexp = description_regexp
  end

  def latest_snapshot
    @fog_compute.snapshots.
      select {|s| s.description =~ @description_regexp }.
      sort {|s1, s2| s1.created_at <=> s2.created_at}.last
  end

  def stannis_data(snapshot)
    if snapshot
      Stannis::Client::DeploymentData.new(
        "Volume snapshot #{snapshot.description}",
        "#{time_ago_in_words(snapshot.created_at)} ago"
      )
    else
      Stannis::Client::DeploymentData.new(
      "Volume snapshot #{@description_regexp.inspect}", "missing", "down")
    end
  end
end
