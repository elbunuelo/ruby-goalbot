class CancelGoalSearch
  @queue = :incidents

  def self.perform(incident_id)
    incident = Incident.find(incident_id)
    incident.search_suspended = true
    incident.save
  end
end
