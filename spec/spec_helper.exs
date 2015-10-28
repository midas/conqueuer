ESpec.start

{:ok, files} = File.ls("spec/support")

Enum.each files, fn(file) ->
  Code.require_file "support/#{file}", __DIR__
end

ESpec.configure fn(config) ->
	config.before fn ->
		# {:ok, hello: :world}
	end

	config.finally fn(shared) ->

	end
end
