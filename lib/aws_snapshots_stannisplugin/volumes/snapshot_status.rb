class Stannis::Plugin::AwsSnapshots::Volumes::SnapshotStatus
  def initialize(fog_compute, description_regexp)
    @fog_compute = fog_compute
    @description_regexp = description_regexp
  end

  def latest_snapshot
    @fog_compute.snapshots.
      select {|s| s.description =~ @description_regexp }.
      sort {|s1, s2| s1.created_at <=> s2.created_at}.last
  end
end
