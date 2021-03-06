class RentalsController < ApplicationController

  def check_out
    customer = Customer.find_by(id: params[:customer_id])
    video = Video.find_by(id: params[:video_id])
    
    if customer.nil? || video.nil?
      render json: {
        errors: ["Not Found"]
      }, status: :not_found
      return
    end

    if video.available_inventory == 0
      render json: {
        errors: ["Bad Request. There is no video available."]
      }, status: :bad_request
      return
    end

    rental = Rental.new(
      customer_id: customer.id,
      video_id: video.id,
      due_date: Date.today + 7
    )
    
    if rental.save
    
      customer.videos_checked_out_count += 1
      customer.save
      video.available_inventory -= 1
      video.save

      render json: {
        customer_id: customer.id,
        video_id: video.id,
        due_date: rental.due_date,
        videos_checked_out_count: customer.videos_checked_out_count,
        available_inventory: video.available_inventory
        },status: :ok

      return    
    else
      render json: {
        errors: rental.errors.messages
      }, status: :bad_request
      return
    end
  end

  def check_in
    customer = Customer.find_by(id: params[:customer_id])
    video = Video.find_by(id: params[:video_id])
    if customer.nil? || video.nil? 
      render json: {
        errors: ["Not Found"]
      }, status: :not_found
      return
    else
      customer.videos_checked_out_count -= 1
      customer.save
      video.available_inventory += 1
      video.save

      render json: {
        customer_id: customer.id,
        video_id: video.id,
        videos_checked_out_count: customer.videos_checked_out_count,
        available_inventory: video.available_inventory
        }, status: :ok
        
        return
      end
  end

  private 
  def rental_params
    return params.permit(:customer_id, :video_id, :due_date)
  end

end
