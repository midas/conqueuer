defmodule ConqueuerSpec.Pool do

	use ESpec, async: true

  alias ConqueuerSpec.Helpers

  let! :pool, do: Helpers.start_pool

  it "should allow a worker check out" do
    :poolboy.transaction :something_workers, fn worker ->
      expect( is_pid( worker )).to be_true
    end
  end

end
