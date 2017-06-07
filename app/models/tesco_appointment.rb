class TescoAppointment
  include ActiveModel::Model

  attr_accessor(
    :id,
    :step,
    :selected_date,
    :start_at,
    :first_name,
    :last_name,
    :email,
    :phone,
    :memorable_word,
    :appointment_type,
    :date_of_birth,
    :opt_out_of_market_research,
    :dc_pot_confirmed,
    :date_of_birth_year,
    :date_of_birth_month,
    :date_of_birth_day
  )

  def advance!
    self.step += 1
    yield
  end

  def reset!
    self.step = 1
    yield
  end

  def date_of_birth
    parts = [
      date_of_birth_year,
      date_of_birth_month,
      date_of_birth_day
    ]

    return unless parts.all?(&:present?)

    parts.map!(&:to_i)

    Date.new(*parts)
  end

  def opt_out_of_market_research
    %w(1 true).include?(@opt_out_of_market_research)
  end

  def selected_date
    Time.zone.parse(@selected_date) if @selected_date.present?
  end

  def start_at
    Time.zone.parse(@start_at) if @start_at.present?
  end

  def step
    Integer(@step || 1)
  end

  def save
  end
end
