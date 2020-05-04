describe 'Generating a client' do
  it "works" do
    base_dir = Pathname.new(__dir__).join("../..")
    Dir.mktmpdir do |tmpdir|
      FileUtils.copy_entry(base_dir, tmpdir)
      Dir.chdir(tmpdir) do
        schema_mtime = File.mtime("schema.json")
        client_rb_mtime = File.mtime("lib/platform-api/client.rb")

        out = `rake build 2>&1`
        raise "Expected `rake build` to succeed but it did not:\n#{out}" unless $?.success?

        expect(schema_mtime).to_not eq(File.mtime("schema.json"))
        expect(client_rb_mtime).to_not eq(File.mtime("lib/platform-api/client.rb"))
      end
    end
  end
end
