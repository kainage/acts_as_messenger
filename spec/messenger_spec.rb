require 'spec_helper'

describe ActiveRecord::Acts::MessengerAdditions do
  # puts ActiveRecord::Base.connection.execute("PRAGMA table_info(messages);")
  # Helper method to make messages quickly
  def msg(uzer, recip = false, read = false)
    if recip
      {
        sender_id: 1234, sender_type: 'User', receiver_id: uzer.id,
        receiver_type: 'User', content: 'Hello', viewed: read
      }
    else
      {
        sender_id: uzer.id, sender_type: 'User', receiver_id: 1234,
        receiver_type: 'User', content: 'Hello', viewed: read
      }
    end
  end

  before :each do
    @user1 = User.create!
    @user2 = User.create!
    @message = Message.create!(sender: @user1, receiver: @user2, content: 'Hello')
  end

  it "should return all sent messages" do
    @user1.sent_messages.count.should eql 1

    Message.create! msg(@user1)
    @user1.sent_messages.count.should eql 2

    Message.create! msg(@user1, true)
    @user1.sent_messages.count.should eql 2
  end

  it "should return all received messages"do
    @user1.received_messages.count.should eql 0

    Message.create! msg(@user1)
    @user1.received_messages.count.should eql 0

    Message.create! msg(@user1, true)
    @user1.received_messages.count.should eql 1
  end

  it "should return all messages" do
    @user1.messages.count.should eql 1

    Message.create! msg(@user1)
    @user1.messages.count.should eql 2

    Message.create! msg(@user1, true)
    @user1.messages.count.should eql 3
  end

  it "should return all new messages" do
    @user1.new_messages.count.should eql 0

    Message.create! msg(@user1, true)
    @user1.new_messages.count.should eql 1

    Message.create! msg(@user1, true, true)
    @user1.new_messages.count.should eql 1
  end

  it "should give all the messages between 2 models" do
    @user1.conversation_with(@user2).count.should eql 1

    Message.create!(sender: @user1, receiver: @user2, content: 'Hello')
    @user1.conversation_with(@user2).count.should eql 2

    Message.create!(msg(@user1)) # Different user
    @user1.conversation_with(@user2).count.should eql 2
  end
end