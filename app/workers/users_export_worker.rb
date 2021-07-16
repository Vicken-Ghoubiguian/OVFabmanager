# frozen_string_literal: true

# Will generate an excel file containing all the users.
# This file will be asynchronously generated by sidekiq and a notification will be sent to the requesting user when it's done.
class UsersExportWorker
  include Sidekiq::Worker

  def perform(export_id)
    export = Export.find(export_id)

    raise SecurityError, 'Not allowed to export' unless export.user.admin?
    raise KeyError, 'Wrong worker called' unless export.category == 'users'

    service = UsersExportService.new
    method_name = "export_#{export.export_type}"

    return unless %w[members subscriptions reservations].include?(export.export_type) && service.respond_to?(method_name)

    service.public_send(method_name, export)

    NotificationCenter.call type: :notify_admin_export_complete,
                            receiver: export.user,
                            attached_object: export
  end
end
