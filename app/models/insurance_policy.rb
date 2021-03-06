class InsurancePolicy < ActiveRecord::Base
  # Scopes
  named_scope :by_policy_type, lambda {|policy_type|
    {:conditions => {:policy_type => policy_type}}
  }

  # Associations
  belongs_to :insurance
  belongs_to :patient

  # Validations
#  validates_presence_of :insurance

  def to_s
    s = "#{policy_type}: #{insurance.to_s}"
    s += " ##{number}" unless number.blank?

    return s
  end
end
