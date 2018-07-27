schema "0001 initial" do

  entity "Player" do
    integer16 :current_account, default: nil

    has_many :accounts
  end

  entity "Account" do
    string :username, optional: false
    datetime :created_on, optional: false
    integer16 :hours
    integer16 :minutes
    double :seconds
    integer16 :kills, default: 0
    boolean :alive, default: true
    datetime :start_time, default: nil

    has_many :rounds
    belongs_to :player
  end

  entity "Round" do
    integer16 :kills
    string :survival_time
    datetime :completed_on

    belongs_to :account
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
