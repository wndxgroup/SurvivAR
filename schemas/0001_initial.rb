
schema "0001 initial" do

  entity "Player" do
    integer16 :current_account, default: nil

    has_many :accounts
  end

  entity "Account" do
    string :username, optional: false
    datetime :created_on, optional: false
    integer16 :days
    integer16 :hours
    integer16 :minutes
    integer16 :seconds
    boolean :state, default: false
    datetime :start_time, default: nil
    integer16 :seconds_to_next_wave, default: nil

    belongs_to :player
  end

  entity "Wave" do
    integer16 :wave_number, default: 1

    has_many :enemies
  end

  entity "Enemy" do
    double :longitude
    double :latitude
    double :altitude

    belongs_to :wave
  end
end
