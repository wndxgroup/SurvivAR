describe 'Player' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Player entity' do
    Player.entity_description.name.should == 'Player'
  end
end
