# frozen_string_literal: true

ActiveSupport.on_load(:action_mailer) do
  add_delivery_method :maileroo, MailerooDelivery
end
