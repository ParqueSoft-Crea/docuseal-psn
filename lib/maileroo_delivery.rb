# frozen_string_literal: true

# Método de entrega de ActionMailer que envía por la API HTTPS de Maileroo (puerto 443),
# útil en plataformas que bloquean el SMTP saliente (p. ej. Railway fuera del plan Pro).
class MailerooDelivery
  ENDPOINT = 'https://smtp.maileroo.com/api/v2/emails'

  class DeliveryError < StandardError; end

  attr_reader :settings

  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    response = Faraday.new(request: { open_timeout: 15, timeout: 30 }).post(ENDPOINT) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "Bearer #{settings[:api_key]}"
      req.headers['X-API-Key'] = settings[:api_key]
      req.body = build_payload(mail).to_json
    end

    unless response.success?
      Rails.logger.error("MailerooDelivery: #{response.status} #{response.body.to_s.truncate(500)}")

      raise DeliveryError, "Maileroo respondió #{response.status}: #{response.body.to_s.truncate(300)}"
    end

    response
  end

  private

  def build_payload(mail)
    payload = {
      from: address_object(mail[:from].addrs.first),
      to: mail[:to].addrs.map { |a| address_object(a) },
      subject: mail.subject.to_s,
      html: html_body(mail),
      plain: plain_body(mail)
    }

    payload[:cc] = mail[:cc].addrs.map { |a| address_object(a) } if mail[:cc]
    payload[:bcc] = mail[:bcc].addrs.map { |a| address_object(a) } if mail[:bcc]
    payload[:reply_to] = address_object(mail[:reply_to].addrs.first) if mail[:reply_to]
    payload[:attachments] = mail.attachments.map { |a| attachment_object(a) } if mail.attachments.present?

    payload.compact_blank
  end

  def address_object(addr)
    { address: addr.address, display_name: addr.display_name }.compact_blank
  end

  def html_body(mail)
    return mail.html_part.decoded if mail.html_part
    return mail.body.decoded if mail.mime_type == 'text/html'

    nil
  end

  def plain_body(mail)
    return mail.text_part.decoded if mail.text_part
    return mail.body.decoded if mail.mime_type == 'text/plain'

    nil
  end

  def attachment_object(attachment)
    {
      file_name: attachment.filename,
      content_type: attachment.mime_type,
      content: Base64.strict_encode64(attachment.body.decoded),
      inline: attachment.inline?
    }
  end
end
