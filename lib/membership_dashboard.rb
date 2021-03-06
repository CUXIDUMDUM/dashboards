require 'active_support/all'
require_relative 'metrics_helper'

class MembershipDashboard < MetricsHelper

  def self.count
    response = load_metric("membership-count")
    response["value"]["total"]
  end

  def self.by_level
    response = load_metric("membership-count")

    levels = {}
    response["value"]["by_level"].each { |k,v| levels[k] = ((v.to_i / response["value"]["total"].to_f)*100).to_i.to_s }

    levels
  end

  def self.renewals
    response = load_metric("membership-renewals")

    one_month, quarter, six_months = [], [], []

    response["value"].each do |cat,metrics|
      metrics.each do |k,v|
        metric = { label: k.capitalize.pluralize, value: v }
        case cat
        when "4"
          one_month << metric
        when "13"
          quarter << metric
        when "26"
          six_months << metric
        end
      end
    end

    [
      {:title => "Next month", :items => one_month.compact },
      {:title => "Next quarter", :items => quarter.compact },
      {:title => "Next six months", :items => six_months.compact }
    ]
  end

end
