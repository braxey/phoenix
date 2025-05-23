class NotificationsController < ApplicationController
  def index
    @per_page = 4

    @current_page = params[:page].to_i || 1
    @current_page = 1 if @current_page < 1
    offset = (@current_page - 1) * @per_page

    @search_query = params[:search].to_s || ""
    @status_query = params[:status].to_s || "all"
    @status_query = "all" unless [ "all", "unread", "read" ].include?(@status_query)

    @query = session_user.notifications

    if @search_query.present?
      @query = @query.where("message LIKE ?", "%#{@search_query}%")
    end

    if @status_query != "all"
      @query = @query.where(read: @status_query == "read")
    end

    @total_notifications = @query.count
    @last_page = (@total_notifications/@per_page.to_f).ceil
    @start_number = [ offset + 1, @total_notifications ].min
    @end_number = [ offset + @per_page, @total_notifications ].min

    @notifications = @query.includes(:notifiable).order(created_at: :desc).limit(@per_page).offset(offset)
  end

  def mark_as_read
    @notification = Notification.where(id: params[:id], email_address: session_user.email_address).first
    if @notification
      @notification.update(read: true)
    end
  end
end
