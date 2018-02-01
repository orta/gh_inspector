$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'gh_inspector'

# A quite version of Evidence, so tests don't `puts`
class SilentEvidence
  def inspector_started_query(_query, _inspector); end

  def inspector_is_still_investigating(_query, _inspector); end

  def inspector_successfully_recieved_report(_report, _inspector); end

  def inspector_recieved_empty_report(_report, _inspector); end

  def inspector_could_not_create_report(_error, _query, _inspector); end
end

class NewSilentEvidence
  def inspector_started_query(_query, _inspector); end

  def inspector_is_still_investigating(_query, _inspector); end

  def inspector_successfully_received_report(_report, _inspector); end

  def inspector_received_empty_report(_report, _inspector); end

  def inspector_could_not_create_report(_error, _query, _inspector); end
end
