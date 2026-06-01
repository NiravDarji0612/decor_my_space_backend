module Api
  module V1
    class SupportTicketsController < BaseController
      include Authenticatable

      def create
        ticket = SupportTicket.create!(
          user:     current_user,
          email:    current_user.email,
          category: ticket_params[:category],
          subject:  ticket_params[:subject],
          message:  ticket_params[:message]
        )
        render_success(
          data: { support_ticket: serialize(ticket, serializer: SupportTicketSerializer) },
          status: :created, message: "Support ticket submitted"
        )
      end

      private

      def ticket_params
        params.require(:support_ticket).permit(:category, :subject, :message)
      end
    end
  end
end
