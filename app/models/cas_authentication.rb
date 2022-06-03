class CasAuthentication < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :cas_authenticatable, :recoverable, :timeoutable
  include DatabaseAuthenticatable
  include CurrentCasAuthentication

  belongs_to :cas_user,   polymorphic: true
  belongs_to :advisor, 	  class_name: 'Goxygene::User',       foreign_key: 'cas_user_id', optional: true
  belongs_to :consultant, class_name: 'Goxygene::Consultant', foreign_key: 'cas_user_id', optional: true
  belongs_to :prospecting_datum, class_name: 'Goxygene::ProspectingDatum', foreign_key: 'cas_user_id', optional: true

  scope :advisor_prenom_ordered, 	  -> {includes(:advisor).order('users.prenom asc')}
  scope :active_user, 				      -> { where(active: true) }

  delegate :tier, to: :cas_user

  alias_attribute :email, :login
  alias_attribute :reset_password_sent_at, :reset_password_send_at
  # alias_attribute :reset_password_sent_at, :reset_password_send_at

  validates_uniqueness_of :login
  validates_presence_of :login

  def send_reset_password_instructions_for_consultant
    token = set_reset_password_token

    DeviseMailer.reset_password_instructions_for_consultant(self, token, {}).deliver_later

    token
  end

  def send_reset_password_instructions_for_prospect
    token = set_reset_password_token

    DeviseMailer.reset_password_instructions_for_prospect(self, token, {}).deliver_later

    token
  end

  # This method cloud be called from anywhere and resource.
  # Fix: NoMethodError Exception: protected method `set_reset_password_token'
  def set_reset_password_token_for
    set_reset_password_token
  end

  def self.current_tier
    CasAuthentication.current_cas_authentication.tier
  end
end
