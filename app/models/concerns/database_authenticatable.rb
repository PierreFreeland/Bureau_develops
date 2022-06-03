module DatabaseAuthenticatable
  extend ActiveSupport::Concern
  included do
    attr_reader :password
    attr_accessor :password_confirmation

    validates_presence_of     :password, if: :password_required?
    validates_confirmation_of :password, if: :password_required?
    validates_length_of       :password, within: 6..128, allow_blank: true
  end

  class_methods do
    Devise::Models.config(self, :pepper, :stretches)
  end

  def password=(new_password)
    @password = new_password
    self.encrypted_password = password_digest(@password) if @password.present?
  end

  def clean_up_passwords
    self.password = self.password_confirmation = nil
  end

  protected

  def password_digest(password)
    Devise::Encryptor.digest(self.class, password)
  end

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
end