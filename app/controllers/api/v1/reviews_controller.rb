module Api
  module V1
    class ReviewsController < BaseController
      include Authenticatable

      def create
        booking = policy_scope(Booking).find(params[:booking_id])
        authorize booking, :review?

        raise ValidationError.new("Only completed bookings can be reviewed") unless booking.completed?

        review = Review.create!(
          booking:    booking,
          user:       current_user,
          decorator:  booking.decorator,
          design:     booking.design,
          rating:     review_params[:rating],
          comment:    review_params[:comment],
          tags:       Array(review_params[:tags]),
          would_recommend: ActiveModel::Type::Boolean.new.cast(review_params[:would_recommend])
        )

        render_success(
          data: { review: serialize(review, serializer: ReviewSerializer) },
          message: "Thanks for your review",
          status: :created
        )
      end

      private

      def review_params
        params.require(:review).permit(:rating, :comment, :would_recommend, tags: [])
      end
    end
  end
end
