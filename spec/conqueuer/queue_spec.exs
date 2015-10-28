defmodule ConqueuerSpec.Queue do

	use ESpec, async: true

  alias Conqueuer.Queue

  before do
    {:ok, queue} = Queue.start_link([])
    {:ok, queue: queue, item: 1}
  end

  defmodule AnEmptyQueueSpec do

    use ESpec, shared: true

    it "should not agree the item is a member" do
      expect( Queue.member?( shared.queue, shared.item )).to eq( false )
    end

    it "should have a size of 0" do
      expect( Queue.size( shared.queue )).to eq( 0 )
    end

    it "should not provide a next item" do
      expect( Queue.next( shared.queue )).to eq( :empty )
    end

  end

  describe "when the queue is empty" do

    it_behaves_like AnEmptyQueueSpec

  end

  describe "when an item is enqueued" do

    before do
      Queue.enqueue( shared.queue, shared.item )
    end

    it "should agree the item is a member" do
      expect( Queue.member?( shared.queue, shared.item )).to eq( true )
    end

    it "should have a size of 1" do
      expect( Queue.size( shared.queue )).to eq( 1 )
    end

    it "should provide the item next" do
      {:ok, next_item} = Queue.next( shared.queue )
      expect( next_item ).to eq( shared.item )
    end

    describe "and then the queue is emptied" do

      before do
        Queue.empty( shared.queue )
      end

      it_behaves_like AnEmptyQueueSpec

    end

  end

end
