class TescoAppointmentsController < ApplicationController
  layout 'tesco'

  before_action :set_breadcrumbs
  before_action :appointment
  before_action only: %i(new create) do
    retrieve_slots
  end

  def new
  end

  def create
    send("create_step_#{appointment.step}")
  end

  def confirmation
    @booking_reference = params[:booking_reference]
    @booking_date      = Time.zone.parse(params[:booking_date])
  end

  def footer?
    false
  end

  private

  def slot_selected?
    appointment.start_at
  end
  helper_method :slot_selected?

  def create_step_1
    appointment.advance! { render :new }
  end

  def create_step_2
    if request.xhr?
      render partial: 'times', locals: { times: @times }
    elsif slot_selected?
      appointment.advance! { render :new }
    else
      render :new
    end
  end

  def create_step_3
    redirect_to confirmation_tesco_appointments_path(
      booking_reference: '32830',
      booking_date: appointment.start_at
    )
  end

  def retrieve_slots
    slots   = TescoAppointments.new.slots

    @months = retrieve_months(slots)
    @times  = retrieve_times(slots)
  end

  def retrieve_months(slots)
    default_months = Hash.new { |h, k| h[k] = [] }
    available_days = slots.keys.map(&:to_date)

    available_days.each_with_object(default_months) do |day, months|
      months[day.beginning_of_month] << day
    end
  end

  def retrieve_times(slots)
    return unless appointment.selected_date
    key = appointment.selected_date.strftime('%Y-%m-%d')
    Array(slots[key]).map { |d| DateTime.parse(d).in_time_zone }
  end

  def appointment
    @appointment ||= TescoAppointment.new(appointment_params)
  end

  def appointment_params # rubocop:disable Metrics/MethodLength
    params
      .fetch(:appointment, {})
      .permit(
        :step,
        :selected_date,
        :start_at,
        :first_name,
        :last_name,
        :email,
        :phone,
        :memorable_word,
        :date_of_birth,
        :dc_pot_confirmed,
        :opt_out_of_market_research,
        :date_of_birth_year,
        :date_of_birth_month,
        :date_of_birth_day
      )
  end

  def set_breadcrumbs
    breadcrumb Breadcrumb.new(new_tesco_appointment_path, 'Book a free appointment')
    breadcrumb Breadcrumb.new(new_tesco_appointment_path, 'Tesco Sandy Superstore')
  end
end
